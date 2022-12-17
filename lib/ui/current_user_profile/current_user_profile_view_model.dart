import 'dart:io';
import 'package:dd_app_ui/data/services/api_service.dart';
import 'package:dd_app_ui/data/services/auth_service.dart';
import 'package:dd_app_ui/data/services/data_service.dart';
import 'package:dd_app_ui/domain/models/post.dart';
import 'package:dd_app_ui/domain/models/post_like_state.dart';
import 'package:dd_app_ui/domain/models/post_model.dart';
import 'package:dd_app_ui/domain/models/post_with_post_like_state.dart';
import 'package:dd_app_ui/domain/models/user.dart';
import 'package:dd_app_ui/domain/models/user_statistics.dart';
import 'package:dd_app_ui/exceptions/nonetwork_exception.dart';
import 'package:dd_app_ui/internal/config/app_config.dart';
import 'package:dd_app_ui/internal/config/shared_prefs.dart';
import 'package:dd_app_ui/internal/config/token_storage.dart';
import 'package:dd_app_ui/ui/app_navigator.dart';
import 'package:dd_app_ui/ui/common/cam_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CurrentUserProfileState {
  final User? user;
  final Map<String, String>? headers;
  final UserStatistics? userStatistics;
  final List<PostWithPostLikeState>? userPosts;
  final ImageProvider<Object>? avatar;

  CurrentUserProfileState({
    this.user,
    this.headers,
    this.userStatistics,
    this.userPosts,
    this.avatar,
  });

  CurrentUserProfileState clearUserPosts() {
    return CurrentUserProfileState(
      user: user,
      headers: headers,
      userStatistics: null,
      userPosts: null,
      avatar: avatar,
    );
  }

  CurrentUserProfileState copyWith({
    user,
    headers,
    userStatistics,
    userPosts,
    avatar,
  }) {
    List<PostWithPostLikeState>? extendeUserPosts;

    if (this.userPosts == null) {
      if (userPosts != null) {
        extendeUserPosts = userPosts;
      }
    } else {
      extendeUserPosts = this.userPosts;
      if (userPosts != null) {
        extendeUserPosts!.addAll(userPosts);
      }
    }

    return CurrentUserProfileState(
      user: user ?? this.user,
      headers:
          headers != null ? {"Authorization": "Bearer $headers"} : this.headers,
      userStatistics: userStatistics ?? this.userStatistics,
      userPosts: extendeUserPosts,
      avatar: avatar ?? this.avatar,
    );
  }
}

class CurrentUserProfileViewModel extends ChangeNotifier {
  final BuildContext context;
  final List<String> ids = [];
  final List<Widget> allImages = [];
  var _state = CurrentUserProfileState();
  final _authService = AuthService();
  final _apiService = ApiService();
  final _dataService = DataService();
  int take = 10, skip = 0;
  bool isLoading = true;
  bool isUpdating = false;
  bool isDelay = false;

  CurrentUserProfileViewModel({required this.context}) {
    _asyncInit();
  }

  set state(CurrentUserProfileState val) {
    _state = val;
    notifyListeners();
  }

  CurrentUserProfileState get state => _state;

  Future _asyncInit() async {
    take = 10;
    skip = 0;
    isLoading = true;
    User? user;
    String? headers;
    List<PostModel>? userPosts;

    user = await SharedPrefs.getStoredUser();
    headers = await TokenStorage.getAccessToken();
    try {
      userPosts = await _apiService.getCurrentUserPosts(take: take, skip: skip);
    } on NoNetworkException {
      _showDialog("Network error", "Network erorr, please try later");
    } on Exception {
      _showDialog("Error", "Happened unexpected error, please try later");
    }

    if (userPosts != null) {
      for (var post in userPosts) {
        await _dataService.cuPost(Post(
          id: post.id,
          created: post.created,
          text: post.text,
          authorId: post.authorId,
          authorAvatar: post.authorAvatar,
          commentAmount: post.commentAmount,
          likesAmount: post.likesAmount,
        ));

        if (post.postFiles != null) {
          for (var file in post.postFiles!) {
            await _dataService.cuPostFile(file!);
          }
        }

        _dataService.cuPostLikeState(PostLikeState(
            id: post.id!,
            isLiked:
                (await _apiService.getPostLikeState(postId: post.id!)) == true
                    ? 1
                    : 0));
      }
    }

    _dataService.cuUserStatistics(UserStatistics(
        id: user!.id,
        userPostAmount: await _apiService.getUserPostAmount(),
        userSubscribersAmount: await _apiService.getUserSubscribersAmount(),
        userSubscriptionsAmount:
            await _apiService.getUserSubscriptionsAmount()));

    state = state.copyWith(
      headers: headers,
      userStatistics: await _dataService.getUserStatisctics(user.id),
      userPosts: await _dataService.getPostsWithLikeStatePostFilesById(
        user.id,
        take: take,
        skip: skip,
        orderBy: "created DESC",
      ),
    );

    var img = await NetworkAssetBundle(Uri.parse("$baseUrl${user.avatar}"))
        .load("$baseUrl${user.avatar}?v=1");

    state = state.copyWith(
        avatar: Image.memory(
      img.buffer.asUint8List(),
      fit: BoxFit.fill,
    ).image);

    state = state.copyWith(user: user);

    if (userPosts != null) {
      addImages();

      skip += take;
    }

    if (userPosts != null) {
      isLoading = false;
    }
  }

  Future startDelay() async {
    isDelay = true;
    await Future.delayed(const Duration(seconds: 5));
    isDelay = false;
  }

  void _showDialog(String title, String description) {
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text(title),
              content: Text(description),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, 'Cancel'),
                  child: const Text('Ok'),
                ),
              ],
            ));
  }

  void addImages() {
    var length = allImages.length;

    for (int i = length; i < state.userPosts!.length; i++) {
      if (state.userPosts![i].postFiles!.isEmpty) {
        allImages.add(GestureDetector(
            onTap: () => postPressed(state.userPosts![i].id!),
            child: SizedBox(
                height: (MediaQuery.of(context).size.width / 3) - 2,
                width: (MediaQuery.of(context).size.width / 3) - 2,
                child: Container(
                    color: const Color.fromARGB(255, 165, 165, 167),
                    child: Center(
                      child: Text(
                        state.userPosts![i].text!,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.clip,
                        style: const TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                    )))));
      } else {
        allImages.add(GestureDetector(
            onTap: () => postPressed(state.userPosts![i].id!),
            child: Container(
              height: (MediaQuery.of(context).size.width / 3) - 2,
              width: (MediaQuery.of(context).size.width / 3) - 2,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: Image.network(
                      "$baseUrl${state.userPosts![i].postFiles![0]!.link}",
                      headers: state.headers,
                    ).image,
                    fit: BoxFit.cover,
                    alignment: Alignment.center),
              ),
            )));
      }
    }

    notifyListeners();
  }

  void updateScreen() async {
    if (!isUpdating) {
      isUpdating = true;
      _startDelay();
      allImages.clear();
      state = state.clearUserPosts();

      await _asyncInit();
    }
  }

  void _startDelay() async {
    await Future.delayed(const Duration(seconds: 1));
    isUpdating = false;
  }

  void logout() async {
    try {
      await _authService.logout();
    } on NoNetworkException {
      _showDialog("Network error", "No network, please try later");
    } on Exception {
      _showDialog("Error", "Happened unexpected error, please try later");
    }
    AppNavigator.toLoader();
  }

  void postPressed(String postId) => AppNavigator.toPost(postId: postId);

  Future requestNextPosts() async {
    List<PostModel>? userPosts;
    User? user = await SharedPrefs.getStoredUser();

    try {
      userPosts = await _apiService.getCurrentUserPosts(take: take, skip: skip);
    } on NoNetworkException {
      _showDialog("Network error", "Network erorr, please try later");
    } on Exception {
      _showDialog("Error", "Happened unexpected error, please try later");
    }

    if (userPosts != null) {
      for (var post in userPosts) {
        await _dataService.cuPost(Post(
          id: post.id,
          created: post.created,
          text: post.text,
          authorId: post.authorId,
          authorAvatar: post.authorAvatar,
          commentAmount: post.commentAmount,
          likesAmount: post.likesAmount,
        ));

        if (post.postFiles != null) {
          for (var file in post.postFiles!) {
            await _dataService.cuPostFile(file!);
          }
        }

        await _dataService.cuPostLikeState(PostLikeState(
            id: post.id!,
            isLiked:
                (await _apiService.getPostLikeState(postId: post.id!)) == true
                    ? 1
                    : 0));
      }

      state = state.copyWith(
        userStatistics: await _dataService.getUserStatisctics(user!.id),
        userPosts: await _dataService.getPostsWithLikeStatePostFilesById(
          user.id,
          take: take,
          skip: skip,
          orderBy: "created",
        ),
      );

      addImages();

      skip += take;
    }
  }

  Future changePhoto() async {
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
      var metaData = await _apiService.uploadFiles(files: [File(imagePath!)]);
      if (metaData!.isNotEmpty) {
        await _apiService.addUserAvatar(model: metaData.first);
        var img =
            await NetworkAssetBundle(Uri.parse("$baseUrl${state.user!.avatar}"))
                .load("$baseUrl${state.user!.avatar}?v=1");
        state = state.copyWith(
            avatar: Image.memory(img.buffer.asUint8List()).image);
      }
    }
  }
}
