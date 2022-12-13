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
import 'package:dd_app_ui/ui/custom_ui/custom_buttom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jiffy/jiffy.dart';
import 'package:dd_app_ui/ui/icons_images/icons_icons.dart';

class _UserProfileState {
  final User? user;
  final Map<String, String>? headers;
  final UserStatistics? userStatistics;
  final List<PostWithPostLikeState>? userPosts;

  _UserProfileState({
    this.user,
    this.headers,
    this.userStatistics,
    this.userPosts,
  });

  _UserProfileState clearUserPosts() {
    return _UserProfileState(
      user: user,
      headers: headers,
      userStatistics: null,
      userPosts: null,
    );
  }

  _UserProfileState copyWith({
    user,
    headers,
    userStatistics,
    userPosts,
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

    return _UserProfileState(
      user: user ?? this.user,
      headers:
          headers != null ? {"Authorization": "Bearer $headers"} : this.headers,
      userStatistics: userStatistics ?? this.userStatistics,
      userPosts: extendeUserPosts,
    );
  }
}

class _UserProfileViewModel extends ChangeNotifier {
  final BuildContext context;
  final List<String> ids = [];
  final List<GestureDetector> _allImages = [];
  var _state = _UserProfileState();
  final _authService = AuthService();
  final _apiService = ApiService();
  final _dataService = DataService();
  int take = 10, skip = 0;
  bool isLoading = true;
  bool isUpdating = false;
  bool isDelay = false;

  _UserProfileViewModel({required this.context}) {
    _asyncInit();
  }

  set state(_UserProfileState val) {
    _state = val;
    notifyListeners();
  }

  _UserProfileState get state => _state;

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
      userStatistics: await _dataService.getUserStatisctics(user.id),
      userPosts: await _dataService.getPostsWithLikeStatePostFilesById(
        user.id,
        take: take,
        skip: skip,
        orderBy: "created",
      ),
    );

    state = state.copyWith(user: user);

    if (headers != null) {
      state = state.copyWith(headers: headers);
    }

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
    var length = _allImages.length;

    for (int i = length; i < state.userPosts!.length; i++) {
      if (state.userPosts![i].postFiles!.isEmpty) {
        _allImages.add(GestureDetector(
            onTap: () => postPressed(state.userPosts![i].id!),
            child: Expanded(
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
                        ))))));
      } else {
        _allImages.add(GestureDetector(
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
      _allImages.clear();
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

  String getUserBirtDate() =>
      state.user == null ? '' : Jiffy(state.user!.birthDate, "yyyy-MM-dd").MMMd;

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
}

class UserProfileWidget extends StatelessWidget {
  static const double fontSize = 12;

  const UserProfileWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<_UserProfileViewModel>();

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: viewModel.state.user != null
              ? Text(viewModel.state.user!.name)
              : const Text(""),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              onPressed: viewModel.logout,
              icon: const Icon(MyIcons.logout),
            )
          ],
        ),
        body: SafeArea(
          child: GestureDetector(
            child: Column(
              children: <Widget>[
                IntrinsicHeight(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(10, 10, 5, 10),
                      child: (viewModel.state.headers != null &&
                              viewModel.state.user != null)
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(
                                "$baseUrl${viewModel.state.user!.avatar}",
                                headers: viewModel.state.headers,
                              ),
                              radius: 50.0,
                            )
                          : const CircleAvatar(
                              backgroundColor: Colors.grey,
                              radius: 50.0,
                            ),
                    ),
                    const SizedBox(
                        height: 75,
                        child: VerticalDivider(
                          width: 5,
                          color: Colors.grey,
                        )),
                    Flexible(
                      child: Container(
                          margin: const EdgeInsets.fromLTRB(5.0, 0, 0.0, 0.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                    Container(
                                        alignment: Alignment.center,
                                        child: const Text(
                                          "Post ",
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: fontSize,
                                          ),
                                        )),
                                    Container(
                                        alignment: Alignment.center,
                                        child: Text(
                                          viewModel.state.userStatistics == null
                                              ? 0.toString()
                                              : viewModel.state.userStatistics!
                                                  .userPostAmount
                                                  .toString(),
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: fontSize + 10,
                                          ),
                                        )),
                                  ])),
                              Expanded(
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                    Container(
                                        alignment: Alignment.center,
                                        child: const Text(
                                          "Followers ",
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: fontSize,
                                          ),
                                        )),
                                    Container(
                                        alignment: Alignment.center,
                                        child: Text(
                                          viewModel.state.userStatistics == null
                                              ? 0.toString()
                                              : viewModel.state.userStatistics!
                                                  .userSubscribersAmount
                                                  .toString(),
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: fontSize + 10,
                                          ),
                                        )),
                                  ])),
                              Expanded(
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                    Container(
                                        alignment: Alignment.center,
                                        child: const Text(
                                          "Followings ",
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: fontSize,
                                          ),
                                        )),
                                    Container(
                                        alignment: Alignment.center,
                                        child: Text(
                                          viewModel.state.userStatistics == null
                                              ? 0.toString()
                                              : viewModel.state.userStatistics!
                                                  .userSubscriptionsAmount
                                                  .toString(),
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: fontSize + 10,
                                          ),
                                        )),
                                  ])),
                            ],
                          )),
                    ),
                  ],
                )),
                if (viewModel.isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                Expanded(
                    child: NotificationListener<ScrollNotification>(
                        onNotification: (scrollNotification) {
                          if (scrollNotification is ScrollEndNotification) {
                            if (!viewModel.isDelay) {
                              viewModel.startDelay();
                              viewModel.requestNextPosts();
                            }
                            return true;
                          }
                          return false;
                        },
                        child: SingleChildScrollView(
                          child: Wrap(
                            runSpacing: 2.0,
                            spacing: 2.0,
                            direction: Axis.horizontal,
                            children: viewModel._allImages,
                          ),
                        ))),
              ],
            ),
            onVerticalDragUpdate: (details) =>
                details.delta.distance > 10.0 ? viewModel.updateScreen() : null,
          ),
        ),
        bottomNavigationBar: CustomBottomNavigationBar.create(
            context: context, isUserProfile: true));
  }

  static Widget create() => ChangeNotifierProvider<_UserProfileViewModel>(
        create: (context) => _UserProfileViewModel(context: context),
        lazy: false,
        child: const UserProfileWidget(),
      );
}
