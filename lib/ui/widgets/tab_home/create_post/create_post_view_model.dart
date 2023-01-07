import 'dart:convert';
import 'dart:io';

import 'package:dd_app_ui/data/services/api_service.dart';
import 'package:dd_app_ui/data/services/data_service.dart';
import 'package:dd_app_ui/domain/models/create_post_model.dart';
import 'package:dd_app_ui/domain/models/post.dart';
import 'package:dd_app_ui/domain/models/send_push_model.dart';
import 'package:dd_app_ui/domain/models/user.dart';
import 'package:dd_app_ui/internal/config/shared_prefs.dart';
import 'package:dd_app_ui/ui/navigation/app_navigator.dart';
import 'package:dd_app_ui/ui/navigation/tab_navigator.dart';
import 'package:dd_app_ui/ui/widgets/common/cam_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

class CreatePostState {
  final User? user;
  final List<String>? imagesPaths;
  final List<Image>? images;
  final bool isLoading;
  final String? postText;

  CreatePostState({
    this.imagesPaths,
    this.postText,
    this.user,
    this.images,
    this.isLoading = true,
  });

  CreatePostState copyWith({
    imagesPaths,
    user,
    images,
    imagesWidgets,
    isLoading,
    postText,
  }) {
    return CreatePostState(
      imagesPaths: imagesPaths ?? this.imagesPaths,
      user: user ?? this.user,
      images: images ?? this.images,
      isLoading: isLoading ?? this.isLoading,
      postText: postText ?? this.postText,
    );
  }
}

class CreatePostViewModel extends ChangeNotifier {
  BuildContext context;
  CreatePostState _state = CreatePostState();
  var postText = TextEditingController();
  final _apiService = ApiService();
  final _dataService = DataService();

  CreatePostViewModel({required this.context}) {
    postText.addListener(() {
      state = state.copyWith(postText: postText.text);
    });

    _asyncInit();
  }

  CreatePostState get state => _state;
  set state(CreatePostState val) {
    _state = val;
    notifyListeners();
  }

  Future _asyncInit() async {
    state = state.copyWith(isLoading: true);

    var user = await SharedPrefs.getStoredUser();
    if (user != null) {
      state = state.copyWith(user: user);
    }

    state = state.copyWith(isLoading: false);
  }

  Future takePicture() async {
    String? imagePath;

    await Navigator.of(AppNavigator.key.currentState!.context)
        .push(MaterialPageRoute(
      builder: (newContext) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.black),
        body: SafeArea(
          child: CamWidget(
            onFile: (file) {
              imagePath = file.path;
              Navigator.of(newContext).pop();
            },
          ),
        ),
      ),
    ));

    if (imagePath != null) {
      var images = state.images ?? [];
      var imagesPaths = state.imagesPaths ?? [];

      images.add(await _convertFileToImage(File(imagePath!)));
      imagesPaths.add(imagePath!);

      state = state.copyWith(
        images: images,
        imagesPaths: imagesPaths,
      );
    }
  }

  Future<Image> _convertFileToImage(File picture) async {
    List<int> imageBase64 = picture.readAsBytesSync();
    String imageAsString = base64Encode(imageBase64);
    Uint8List uint8list = base64.decode(imageAsString);
    Image image = Image.memory(uint8list);
    return image;
  }

  Future createPost() async {
    if (state.images != null && state.images!.isNotEmpty) {
      String postId = const Uuid().v4();
      String created = DateTime.now().toUtc().toString();
      User? user = await SharedPrefs.getStoredUser();

      List<File> files = [];
      for (var path in state.imagesPaths!) {
        files.add(File(path));
      }

      var metaData = await _apiService.uploadFiles(files: files);
      await _dataService.cuPost(Post(
          id: postId,
          created: created,
          text: state.postText,
          authorId: user!.id,
          authorAvatar: user.avatar,
          commentAmount: 0,
          likesAmount: 0));

      await _apiService.createPost(
          model: CreatePostModel(
              id: postId,
              text: state.postText!,
              files: metaData!,
              created: created.replaceAll(r' ', 'T')));

      _sendNotificationsAsync(
        state.postText!,
        postId,
      );

      _goToProfile();
    }
  }

  Future _sendNotificationsAsync(String message, String postId) async {
    var subscribers = await _dataService.getSusbcriptions(
      userId: state.user!.id,
    );

    if (subscribers == null) {
      return;
    }

    var alert = Alert(
      title: "New post from ${state.user!.name}",
      body: message,
    );
    var customData = CustomData(
      additionalProp1: postId,
      additionalProp2: TabNavigatorRoutes.postDetails,
      additionalProp3: "",
    );
    var push = Push(
      alert: alert,
      customData: customData,
    );

    for (var subscriber in subscribers) {
      var model = SendPushModel(
        userId: subscriber.subscriberId,
        push: push,
      );

      await _apiService.sendPush(model: model);
    }
  }

  void _goToProfile() {
    Navigator.of(context)
        .pushNamedAndRemoveUntil(TabNavigatorRoutes.root, (___) => false);
  }

  void close() {
    Navigator.of(context).pop();
  }
}
