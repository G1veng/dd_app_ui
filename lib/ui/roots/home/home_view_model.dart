import 'package:dd_app_ui/data/services/api_service.dart';
import 'package:dd_app_ui/data/services/data_service.dart';
import 'package:dd_app_ui/domain/models/post.dart';
import 'package:dd_app_ui/domain/models/post_like_state.dart';
import 'package:dd_app_ui/domain/models/post_with_post_like_state.dart';
import 'package:dd_app_ui/domain/models/user.dart';
import 'package:dd_app_ui/internal/config/app_config.dart';
import 'package:dd_app_ui/internal/config/shared_prefs.dart';
import 'package:dd_app_ui/internal/config/token_storage.dart';
import 'package:dd_app_ui/ui/icons_images/icons_icons.dart';
import 'package:flutter/material.dart';

class HomeSate {
  final int counter;
  final bool isRuning;
  final User? user;
  final Map<String, String>? headers;
  final List<Column>? postsWidgets;
  final List<PostWithPostLikeState>? postsInfo;

  HomeSate({
    this.counter = 0,
    this.isRuning = false,
    this.user,
    this.headers,
    this.postsWidgets,
    this.postsInfo,
  });

  HomeSate copyWith({
    counter = 0,
    isRuning,
    user,
    currentPageIndex = 0,
    headers,
    postsWidgets,
    Iterable<PostWithPostLikeState>? postsInfo,
  }) {
    List<PostWithPostLikeState>? expandedPostsInfo;

    if (this.postsInfo != null) {
      expandedPostsInfo = this.postsInfo!;
    }

    if (postsInfo != null) {
      if (expandedPostsInfo == null) {
        expandedPostsInfo = postsInfo.toList();
      } else {
        expandedPostsInfo.addAll(postsInfo);
      }
    }

    return HomeSate(
      counter: counter ?? this.counter,
      headers:
          headers != null ? {"Authorization": "Bearer $headers"} : this.headers,
      isRuning: isRuning ?? this.isRuning,
      user: user ?? this.user,
      postsWidgets: postsWidgets ?? this.postsWidgets,
      postsInfo: expandedPostsInfo ?? this.postsInfo,
    );
  }

  HomeSate clearPostInfo() {
    return HomeSate(
      counter: counter,
      headers: headers,
      isRuning: isRuning,
      user: user,
      postsWidgets: null,
      postsInfo: null,
    );
  }
}

class HomeViewModel extends ChangeNotifier {
  final BuildContext context;
  var _state = HomeSate();
  final _dataService = DataService();
  final _api = ApiService();
  int take = 10, skip = 0;
  bool isUpdating = false;

  HomeViewModel({required this.context}) {
    _asyncInit();
  }

  HomeSate get state => _state;
  set state(HomeSate val) {
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

    var posts = await requestNextPosts();

    if (posts == true || headers != null || user != null) {
      state = state.copyWith(isRuning: false);
    }
  }

  void postPressed(String postId) {}

  void postLikePressed(String postId, int index) async {
    var changeOn = state.postsInfo![index].postLikeState! == 1 ? 0 : 1;
    Post? changedPost;

    await _dataService.cuPostLikeState(PostLikeState(
      id: postId,
      isLiked: changeOn,
    ));

    changedPost = await _dataService.getPost(postId);

    await _dataService.cuPost(Post(
      id: changedPost!.id,
      created: changedPost.created,
      text: changedPost.text,
      authorId: changedPost.authorId,
      authorAvatar: changedPost.authorAvatar,
      commentAmount: changedPost.commentAmount,
      likesAmount: changeOn == 1
          ? changedPost.likesAmount! + 1
          : changedPost.likesAmount! - 1,
    ));

    _api.changePostLikeState(postId: postId);
    //Можно оставить без await, так как нам не нужно получать это изменения
    //такие ситуация в дальнейшем буду оставлять без комментариев

    var post = await _dataService.getPostWithLikeStatePostFiles(postId);
    if (post != null) {
      var postInfo = state.postsInfo;

      postInfo![index] = post;

      state = state.clearPostInfo();

      state = state.copyWith(postsInfo: postInfo);
    }

    updateScreenPosts(isUpdate: true);
  }

  Future _startDelay() async {
    isUpdating = true;
    await Future.delayed(const Duration(seconds: 3));
    isUpdating = false;
  }

  void updateScreenPosts({bool isUpdate = false}) {
    var posts = state.postsWidgets ?? [];

    if (isUpdate) {
      _startDelay();
      posts.clear();
      take = 10;
      skip = 0;
    }

    int length = posts.length;

    if (state.postsInfo == null) {
      return;
    }

    for (int i = length; i < state.postsInfo!.length; i++) {
      if (state.postsInfo![i].postFiles!.isEmpty) {
        posts.add(Column(children: [
          GestureDetector(
            onTap: () => postPressed(state.postsInfo![i].id!),
            onDoubleTap: () => postLikePressed(state.postsInfo![i].id!, i),
            child: Expanded(
                child: SizedBox(
                    height: MediaQuery.of(context).size.width / 4,
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                        margin: const EdgeInsets.all(3),
                        color: const Color.fromARGB(255, 165, 165, 167),
                        child: Center(
                          child: Text(
                            state.postsInfo![i].text!,
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
                          postLikePressed(state.postsInfo![i].id!, i),
                      icon: state.postsInfo![i].postLikeState == 1
                          ? const Icon(MyIcons.heartFilled)
                          : const Icon(MyIcons.heartEmpty),
                    ),
                    Text("Likes ${state.postsInfo![i].likesAmount}")
                  ],
                )),
            Container(
                margin: const EdgeInsets.fromLTRB(3.0, 0.0, 5.0, 0.0),
                child: Text("Comments ${state.postsInfo![i].commentAmount}"))
          ]),
        ]));
      } else {
        posts.add(Column(children: [
          GestureDetector(
              onTap: () => postPressed(state.postsInfo![i].id!),
              onDoubleTap: () => postLikePressed(state.postsInfo![i].id!, i),
              child: Container(
                height: (MediaQuery.of(context).size.width),
                width: (MediaQuery.of(context).size.width),
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: Image.network(
                        "$baseUrl${state.postsInfo![i].postFiles![0]!.link}",
                        headers: state.headers,
                      ).image,
                      fit: BoxFit.cover,
                      alignment: Alignment.center),
                ),
              )),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(
                margin: const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
                child: Row(
                  children: [
                    IconButton(
                      color: Colors.red,
                      onPressed: () =>
                          postLikePressed(state.postsInfo![i].id!, i),
                      icon: state.postsInfo![i].postLikeState == 1
                          ? const Icon(MyIcons.heartFilled)
                          : const Icon(MyIcons.heartEmpty),
                    ),
                    Text("Likes ${state.postsInfo![i].likesAmount}")
                  ],
                )),
            Container(
                margin: const EdgeInsets.fromLTRB(3.0, 0.0, 5.0, 0.0),
                child: Text("Comments ${state.postsInfo![i].commentAmount}"))
          ]),
        ]));
      }
    }

    state = state.copyWith(postsWidgets: posts);
  }

  Future<bool> requestNextPosts() async {
    List<PostWithPostLikeState> dbPosts = [];
    var posts = await _api.getSubscriptionPosts(take, skip);

    if (posts != null) {
      for (var post in posts) {
        var author = await _api.getUserById(userId: post.authorId!);

        if (author != null) {
          await _dataService.cuUser(User(
            id: author.id!,
            name: author.name!,
            email: author.email!,
            birthDate: author.birthDate!,
            avatar: author.avatar!,
          ));
        }

        if (post.postFiles != null) {
          for (var file in post.postFiles!) {
            await _dataService.cuPostFile(file!);
          }
        }

        var postLikeState = await _api.getPostLikeState(postId: post.id!);
        _dataService.cuPostLikeState(
            PostLikeState(id: post.id!, isLiked: postLikeState ? 1 : 0));

        await _dataService.cuPost(Post(
          id: post.id,
          created: post.created,
          text: post.text,
          authorId: post.authorId,
          authorAvatar: post.authorAvatar,
          commentAmount: post.commentAmount,
          likesAmount: post.likesAmount,
        ));
      }

      for (var post in posts) {
        var dbPost = await _dataService.getPostWithLikeStatePostFiles(post.id!);
        if (dbPost != null) {
          dbPosts.add(dbPost);
        }

        skip += take;
      }

      state = state.copyWith(postsInfo: dbPosts);

      updateScreenPosts();

      return true;
    }
    return false;
  }
}
