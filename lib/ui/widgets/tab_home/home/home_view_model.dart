import 'package:dd_app_ui/data/services/api_service.dart';
import 'package:dd_app_ui/data/services/data_service.dart';
import 'package:dd_app_ui/data/services/sync_service.dart';
import 'package:dd_app_ui/domain/enums/db_query.dart';
import 'package:dd_app_ui/domain/models/post_like_state.dart';
import 'package:dd_app_ui/domain/models/post_with_post_like_state.dart';
import 'package:dd_app_ui/domain/models/user.dart';
import 'package:dd_app_ui/internal/config/shared_prefs.dart';
import 'package:dd_app_ui/internal/config/token_storage.dart';
import 'package:dd_app_ui/ui/navigation/tab_navigator.dart';
import 'package:flutter/material.dart';

class HomeSate {
  final bool isLoading;
  final User? user;
  final Map<String, String>? headers;
  final List<PostWithPostLikeState>? postsInfo;
  final List<String>? postAuthors;

  HomeSate({
    this.postAuthors,
    this.isLoading = false,
    this.user,
    this.headers,
    this.postsInfo,
  });

  HomeSate copyWith({
    isLoading,
    user,
    currentPageIndex = 0,
    headers,
    List<String>? postAuthors,
    List<PostWithPostLikeState>? postsInfo,
  }) {
    return HomeSate(
      headers:
          headers != null ? {"Authorization": "Bearer $headers"} : this.headers,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      postsInfo: postsInfo ?? this.postsInfo,
      postAuthors: postAuthors ?? this.postAuthors,
    );
  }

  HomeSate clearPostInfo() {
    return HomeSate(
      headers: headers,
      isLoading: isLoading,
      user: user,
      postsInfo: null,
      postAuthors: null,
    );
  }
}

class HomeViewModel extends ChangeNotifier {
  final BuildContext context;
  var _state = HomeSate();
  final _dataService = DataService();
  final _syncService = SyncService();
  final _apiService = ApiService();
  int take = 2, skip = 0;
  Map<int, int> pager = <int, int>{};
  final lvc = ScrollController();

  HomeViewModel({required this.context}) {
    _asyncInit();

    lvc.addListener(() async {
      var max = lvc.position.maxScrollExtent;
      var current = lvc.offset;
      var percent = (current / max * 100);
      if (percent > 80) {
        if (!state.isLoading) {
          _startDelayAsync();
          await _requestNextPosts();
        }
      }
    });
  }

  HomeSate get state => _state;
  set state(HomeSate val) {
    _state = val;
    notifyListeners();
  }

  void postPressed(String postId) => {
        Navigator.of(context)
            .pushNamed(TabNavigatorRoutes.postDetails, arguments: postId)
      };

  Future pressedGoToProfile(String userId) async {
    return await Navigator.of(context)
        .pushNamed(TabNavigatorRoutes.userProfile, arguments: userId);
  }

  void postLikePressed(String postId, int index) async {
    var newLikeState = state.postsInfo![index].postLikeState! == 0 ? 1 : 0;

    await _dataService
        .cuPostLikeState(PostLikeState(id: postId, isLiked: newLikeState));

    var post = await _dataService.getPostWithLikeStatePostFiles(postId);

    var postsInfo = state.postsInfo;
    postsInfo![index] = post!;

    state = state.copyWith(postsInfo: postsInfo);
  }

  void onPageChanged(int listIndex, int pageIndex) {
    pager[listIndex] = pageIndex;
    notifyListeners();
  }

  void createPostPressed() =>
      {Navigator.of(context).pushNamed(TabNavigatorRoutes.createPost)};

  void _asyncInit() async {
    state = state.copyWith(isLoading: true);

    var user = await SharedPrefs.getStoredUser();
    var headers = await TokenStorage.getAccessToken();

    if (user != null) {
      state = state.copyWith(user: user, headers: headers);
    }

    await _requestNextPosts();

    state = state.copyWith(isLoading: false);
  }

  Future _requestNextPosts() async {
    state = state.copyWith(isLoading: true);
    List<String> postAuthors = [];

    await _syncService.syncPosts(take,
        lastPostCreated: state.postsInfo?.last.created, skip: skip);

    var posts = (await _dataService.getPostsWithLikeStatePostFilesById(
      state.postsInfo?.last.created == null
          ? {"authorId": state.user!.id}
          : {
              "created": state.postsInfo?.last.created,
              "authorId": state.user!.id
            },
      take: take,
      conds: state.postsInfo?.last.created == null
          ? [
              DbQueryEnum.notEqual,
            ]
          : [DbQueryEnum.isLess, DbQueryEnum.notEqual],
    ))
        ?.toList();

    if (posts != null) {
      for (var post in posts) {
        postAuthors.add(
            (await _apiService.getUserById(userId: post.authorId!))!.name!);
      }

      var extPostAuthors = state.postAuthors ?? [];
      var extPostsInfo = state.postsInfo ?? [];

      extPostAuthors.addAll(postAuthors);
      extPostsInfo.addAll(posts);

      state = state.copyWith(
          postsInfo: extPostsInfo,
          postAuthors: extPostAuthors,
          isLoading: false);

      //skip += take;
    }
  }

  Future _startDelayAsync({int duration = 1}) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(Duration(seconds: duration));
    state = state.copyWith(isLoading: false);
  }
}
