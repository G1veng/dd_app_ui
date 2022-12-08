import 'package:dd_app_ui/data/services/api_service.dart';
import 'package:dd_app_ui/domain/models/post_model_response.dart';
import 'package:dd_app_ui/domain/models/post_request.dart';
import 'package:dd_app_ui/domain/models/user.dart';
import 'package:dd_app_ui/internal/config/app_config.dart';
import 'package:dd_app_ui/internal/config/shared_prefs.dart';
import 'package:dd_app_ui/internal/config/token_storage.dart';
import 'package:dd_app_ui/ui/custom_ui/custom_buttom_navigation_bar.dart';
import 'package:dd_app_ui/ui/icons_images/icons_icons.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:provider/provider.dart';

class _HomeSate {
  final int counter;
  final bool isRuning;
  final User? user;
  final int currentPageIndex;
  final List<PostModelResponse>? subscriptionPosts;
  final Map<String, String>? headers;
  final List<Column>? posts;
  final List<bool>? likedPosts;
  final List<PostRequest?>? postsInfo;

  _HomeSate({
    this.counter = 0,
    this.isRuning = false,
    this.user,
    this.currentPageIndex = 0,
    this.headers,
    this.subscriptionPosts,
    this.posts,
    this.likedPosts,
    this.postsInfo,
  });

  _HomeSate copyWith({
    counter = 0,
    isRuning,
    user,
    currentPageIndex = 0,
    subscriptionPosts,
    headers,
    posts,
    likedPosts,
    postsInfo,
  }) {
    List<PostModelResponse>? resSubscriptionsPosts;

    if (this.subscriptionPosts != null) {
      resSubscriptionsPosts = this.subscriptionPosts;
    }

    if (subscriptionPosts != null) {
      if (resSubscriptionsPosts == null) {
        resSubscriptionsPosts = subscriptionPosts;
      } else {
        resSubscriptionsPosts.addAll(subscriptionPosts);
      }
    }

    return _HomeSate(
      counter: counter ?? this.counter,
      headers:
          headers != null ? {"Authorization": "Bearer $headers"} : this.headers,
      isRuning: isRuning ?? this.isRuning,
      user: user ?? this.user,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      subscriptionPosts: resSubscriptionsPosts,
      posts: posts ?? this.posts,
      likedPosts: likedPosts ?? this.likedPosts,
      postsInfo: postsInfo ?? this.postsInfo,
    );
  }
}

class _ViewModel extends ChangeNotifier {
  final BuildContext context;
  var _state = _HomeSate();
  final _api = ApiService();
  int take = 10, skip = 0;

  _ViewModel({required this.context}) {
    _asyncInit();
  }

  _HomeSate get state => _state;
  set state(_HomeSate val) {
    _state = val;
    notifyListeners();
  }

  void _asyncInit() async {
    state = state.copyWith(isRuning: true);

    var user = await SharedPrefs.getStoredUser();
    var headers = await TokenStorage.getAccessToken();

    if (user != null) {
      state = state.copyWith(user: user);
    }

    if (headers != null) {
      state = state.copyWith(headers: headers);
    }

    var posts = await _requestNextPosts(take, skip);

    if (posts == true || headers != null || user != null) {
      state = state.copyWith(isRuning: false);
    }
  }

  void postPressed(String postId) {}

  void postLikePressed(String postId, int index) async {
    var postsInfo = state.postsInfo;
    var likedPosts = state.likedPosts;

    await _api.changePostLikeState(postId: postId);

    likedPosts![index] ? likedPosts[index] = false : likedPosts[index] = true;

    postsInfo![index] = await _api.getPost(postId: postId);

    state = state.copyWith(likedPosts: likedPosts, postsInfo: postsInfo);
    _updateScreenPosts(0, isUpdate: true);
  }

  void _updateScreenPosts(int startIndex, {bool isUpdate = false}) {
    var posts = state.posts ?? [];
    if (isUpdate) {
      startIndex = 0;
      posts.clear();
    }

    for (int i = startIndex; i < state.subscriptionPosts!.length; i++) {
      if (state.subscriptionPosts![i].postFiles!.isEmpty) {
        posts.add(Column(children: [
          GestureDetector(
            onTap: () => postPressed(state.subscriptionPosts![i].id!),
            onDoubleTap: () =>
                postLikePressed(state.subscriptionPosts![i].id!, i),
            child: Expanded(
                child: SizedBox(
                    height: MediaQuery.of(context).size.width / 4,
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                        margin: const EdgeInsets.all(3),
                        color: const Color.fromARGB(255, 165, 165, 167),
                        child: Center(
                          child: Text(
                            state.subscriptionPosts![i].text!,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.clip,
                            style: const TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                        )))),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(
                margin: const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
                child: Row(
                  children: [
                    IconButton(
                      color: Colors.red,
                      onPressed: () =>
                          postLikePressed(state.subscriptionPosts![i].id!, i),
                      icon: state.likedPosts![i] == true
                          ? const Icon(MyIcons.heartFilled)
                          : const Icon(MyIcons.heartEmpty),
                    ),
                    Text("Likes ${state.postsInfo![i]!.likesAmount}")
                  ],
                )),
            Container(
                margin: const EdgeInsets.fromLTRB(3.0, 0.0, 5.0, 0.0),
                child: Text("Comments ${state.postsInfo![i]!.commentAmount}"))
          ]),
        ]));
      } else {
        posts.add(Column(children: [
          GestureDetector(
              onTap: () => postPressed(state.subscriptionPosts![i].id!),
              onDoubleTap: () =>
                  postLikePressed(state.subscriptionPosts![i].id!, i),
              child: GFAvatar(
                backgroundImage: Image.network(
                  "$baseUrl${state.subscriptionPosts![i].postFiles![0].link}",
                  headers: state.headers,
                ).image,
                radius: (MediaQuery.of(context).size.width - 1.0),
                shape: GFAvatarShape.square,
              )),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(
                margin: const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
                child: Row(
                  children: [
                    IconButton(
                      color: Colors.red,
                      onPressed: () =>
                          postLikePressed(state.subscriptionPosts![i].id!, i),
                      icon: state.likedPosts![i] == true
                          ? const Icon(MyIcons.heartFilled)
                          : const Icon(MyIcons.heartEmpty),
                    ),
                    Text("Likes ${state.postsInfo![i]!.likesAmount}")
                  ],
                )),
            Container(
                margin: const EdgeInsets.fromLTRB(3.0, 0.0, 5.0, 0.0),
                child: Text("Comments ${state.postsInfo![i]!.commentAmount}"))
          ]),
        ]));
      }
    }

    state = state.copyWith(posts: posts);
  }

  Future<bool> _requestNextPosts(int take, int skip) async {
    var posts = await _api.getSubscriptionPosts(take, skip);
    var likedPosts = state.likedPosts ?? [];
    var postsInfo = state.postsInfo ?? [];

    int startIndex = 0;

    if (posts != null) {
      for (int i = 0; i < posts.length; i++) {
        postsInfo.add(await _api.getPost(postId: posts[i].id!));
        likedPosts.add(await _api.getPostLikeState(postId: posts[i].id!));
      }

      if (state.subscriptionPosts != null) {
        startIndex = state.subscriptionPosts!.length;
      }

      state = state.copyWith(
          subscriptionPosts: posts,
          likedPosts: likedPosts,
          postsInfo: postsInfo);

      take += 10;
      skip += 10;

      _updateScreenPosts(startIndex);

      return true;
    }

    return false;
  }
}

class HomeWidget extends StatelessWidget {
  const HomeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<_ViewModel>();

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            "NotInstagram",
          ),
          leading: viewModel.state.isRuning
              ? const CircularProgressIndicator(
                  color: Colors.red,
                  strokeWidth: 4.0,
                )
              : null,
        ),
        body: Column(children: viewModel.state.posts ?? []),
        bottomNavigationBar:
            CustomBottomNavigationBar.create(context: context, isHome: true));
  }

  static Widget create() => ChangeNotifierProvider<_ViewModel>(
        create: (context) => _ViewModel(context: context),
        lazy: false,
        child: const HomeWidget(),
      );
}
