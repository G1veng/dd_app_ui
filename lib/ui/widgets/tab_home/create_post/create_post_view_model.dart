import 'dart:convert';
import 'dart:io';

import 'package:dd_app_ui/data/services/api_service.dart';
import 'package:dd_app_ui/data/services/data_service.dart';
import 'package:dd_app_ui/domain/models/create_post_model.dart';
import 'package:dd_app_ui/domain/models/post.dart';
import 'package:dd_app_ui/domain/models/user.dart';
import 'package:dd_app_ui/internal/config/shared_prefs.dart';
import 'package:dd_app_ui/ui/navigation/tab_navigator.dart';
import 'package:dd_app_ui/ui/widgets/common/cam_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

class CreatePostState {
  final User? user;
  final List<String>? imagesPaths;
  final List<Image>? images;
  final List<Widget>? imagesWidgets;
  final bool isLoading;
  final String? postText;

  CreatePostState({
    this.imagesPaths,
    this.postText,
    this.user,
    this.images,
    this.imagesWidgets,
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
      imagesWidgets: imagesWidgets ?? this.imagesWidgets,
      isLoading: isLoading ?? this.isLoading,
      postText: postText ?? this.postText,
    );
  }
}

class CreatePostViewModel extends ChangeNotifier {
  BuildContext context;
  CreatePostState _state = CreatePostState();
  var postText = TextEditingController();
  final _api = ApiService();
  final _data = DataService();

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

    state = state.copyWith(imagesWidgets: _createPlus(), isLoading: false);
  }

  Future _takePicture() async {
    String? imagePath;

    await Navigator.of(context).push(MaterialPageRoute(
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

      _showImages();
    }
  }

  Future<Image> _convertFileToImage(File picture) async {
    List<int> imageBase64 = picture.readAsBytesSync();
    String imageAsString = base64Encode(imageBase64);
    Uint8List uint8list = base64.decode(imageAsString);
    Image image = Image.memory(uint8list);
    return image;
  }

  List<Widget> _createPlus() {
    var imagesWidgets = <Widget>[];
    var size = MediaQuery.of(context).size;

    imagesWidgets.add(GestureDetector(
        onTap: _takePicture,
        child: Container(
          margin: const EdgeInsets.all(0.5),
          height: size.width / 3 - 1,
          width: size.width / 3 - 1,
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          child: Container(
            padding: const EdgeInsets.all(10.0),
            child: Icon(
              Icons.add,
              size: size.width / 10,
            ),
          ),
        )));

    return imagesWidgets;
  }

  Future _showImages() async {
    var imagesWidgets = state.imagesWidgets;
    var startIndex = imagesWidgets!.length - 1;
    var endIndex = state.images!.length;

    for (int i = startIndex; i < endIndex; i++) {
      imagesWidgets.add(GestureDetector(
          onTap: () {}, //TODO сделать показ картинки в полный экран
          child: Container(
            margin: const EdgeInsets.all(0.5),
            height: (MediaQuery.of(context).size.width / 3) - 1,
            width: (MediaQuery.of(context).size.width / 3) - 1,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: state.images![i].image,
                  fit: BoxFit.cover,
                  alignment: Alignment.center),
            ),
          )));
    }
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

      var metaData = await _api.uploadFiles(files: files);
      await _data.cuPost(Post(
          id: postId,
          created: created,
          text: state.postText,
          authorId: user!.id,
          authorAvatar: user.avatar,
          commentAmount: 0,
          likesAmount: 0));

      await _api.createPost(
          model: CreatePostModel(
              id: postId,
              text: state.postText!,
              files: metaData!,
              created: created.replaceAll(r' ', 'T')));

      _goToProfile();
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
