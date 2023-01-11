import 'package:dd_app_ui/data/services/api_service.dart';
import 'package:dd_app_ui/data/services/data_service.dart';
import 'package:dd_app_ui/data/services/sync_service.dart';
import 'package:dd_app_ui/domain/enums/db_query.dart';
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
  final bool? isInternetConnection;

  HomeSate({
    this.postAuthors,
    this.isLoading = false,
    this.user,
    this.headers,
    this.postsInfo,
    this.isInternetConnection,
  });

  HomeSate copyWith({
    isLoading,
    user,
    currentPageIndex = 0,
    headers,
    List<String>? postAuthors,
    List<PostWithPostLikeState>? postsInfo,
    isInternetConnection,
  }) {
    return HomeSate(
      headers:
          headers != null ? {"Authorization": "Bearer $headers"} : this.headers,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      postsInfo: postsInfo ?? this.postsInfo,
      postAuthors: postAuthors ?? this.postAuthors,
      isInternetConnection: isInternetConnection ?? this.isInternetConnection,
    );
  }

  HomeSate clearPostInfo() {
    return HomeSate(
      headers: headers,
      isLoading: isLoading,
      user: user,
      postsInfo: null,
      postAuthors: null,
      isInternetConnection: false,
    );
  }
}

class HomeViewModel extends ChangeNotifier {
  final BuildContext context;
  var _state = HomeSate();
  final _dataService = DataService();
  final _syncService = SyncService();
  final _apiService = ApiService();
  int take = 10, skip = 0;
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

  Future refresh() async {
    state = state.clearPostInfo();
    skip = 0;

    _asyncInit();
  }

  void postPressed(String postId) => {
        Navigator.of(context)
            .pushNamed(TabNavigatorRoutes.postDetails, arguments: postId)
      };

  Future pressedGoToProfile(String userId) async {
    return await Navigator.of(context)
        .pushNamed(TabNavigatorRoutes.userProfile, arguments: userId);
  }

  Future postLikePressed(String postId, int index) async {
    await _apiService.getUserById(
        userId: (await SharedPrefs.getStoredUser())!.id);
    if (!(await SharedPrefs.getConnectionState())) {
      return;
    }

    await _apiService.changePostLikeState(postId: postId);
    await _syncService.syncPostLikeState(postId: postId);
    await _syncService.syncPost(postId: postId);

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
    state = state.copyWith(
      isLoading: true,
      postsInfo: [],
      postAuthors: [],
      isInternetConnection: (await SharedPrefs.getConnectionState()),
    );

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

    await _syncService.syncSubscriptionsPosts(
        userId: (await SharedPrefs.getStoredUser())!.id,
        take,
        lastPostCreated: state.postsInfo == null || state.postsInfo!.isEmpty
            ? null
            : state.postsInfo!.last.created,
        skip: skip);

    var posts = (await _dataService.getCurrentUserSubscriptionsPosts(
        where: state.postsInfo == null || state.postsInfo!.isEmpty
            ? null
            : {
                "created": state.postsInfo?.last.created,
              },
        take: take,
        conds: state.postsInfo == null || state.postsInfo!.isEmpty
            ? null
            : [DbQueryEnum.isLess]));

    if (posts != null) {
      for (var post in posts) {
        postAuthors.add((await _dataService.getUser(post.authorId!))!.name);
      }

      var extPostAuthors = state.postAuthors ?? [];
      var extPostsInfo = state.postsInfo ?? [];

      extPostAuthors.addAll(postAuthors);
      extPostsInfo.addAll(posts);

      state = state.copyWith(
        postsInfo: extPostsInfo,
        postAuthors: extPostAuthors,
        isLoading: false,
      );
    }
  }

  Future _startDelayAsync({int duration = 1}) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(Duration(seconds: duration));
  }
}
