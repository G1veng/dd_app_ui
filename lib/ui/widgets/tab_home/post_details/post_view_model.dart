import 'package:dd_app_ui/data/services/api_service.dart';
import 'package:dd_app_ui/data/services/data_service.dart';
import 'package:dd_app_ui/data/services/sync_service.dart';
import 'package:dd_app_ui/domain/enums/db_query.dart';
import 'package:dd_app_ui/domain/models/create_post_comment_model.dart';
import 'package:dd_app_ui/domain/models/post.dart';
import 'package:dd_app_ui/domain/models/post_comment.dart';
import 'package:dd_app_ui/domain/models/post_file.dart';
import 'package:dd_app_ui/domain/models/user.dart';
import 'package:dd_app_ui/internal/config/app_config.dart';
import 'package:dd_app_ui/internal/config/shared_prefs.dart';
import 'package:dd_app_ui/internal/config/token_storage.dart';
import 'package:dd_app_ui/ui/navigation/tab_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

class PostState {
  final Map<String, String>? headers;
  final int pageCount = 0;
  final Post? post;
  final bool? postLikeState;
  final List<PostComment>? postComments;
  final List<PostFile>? postFiles;
  final List<User>? postCommentsCreators;
  final String? createCommentText;
  final User? currentUser;
  final bool isLoading;
  final bool isUpdating;
  final Image? avatar;
  final User? postCreator;

  PostState({
    this.headers,
    this.post,
    this.postComments,
    this.postFiles,
    this.postCommentsCreators,
    this.createCommentText,
    this.currentUser,
    this.isLoading = true,
    this.isUpdating = true,
    this.postLikeState = false,
    this.avatar,
    this.postCreator,
  });

  PostState copyWith({
    headers,
    post,
    postComments,
    postFiles,
    postCommentsCreators,
    createCommentText,
    currentUser,
    isLoading,
    isUpdating,
    postLikeState,
    avatar,
    postCreator,
  }) {
    return PostState(
      headers:
          headers != null ? {"Authorization": "Bearer $headers"} : this.headers,
      post: post ?? this.post,
      postComments: postComments ?? this.postComments,
      postFiles: postFiles ?? this.postFiles,
      postCommentsCreators: postCommentsCreators ?? this.postCommentsCreators,
      createCommentText: createCommentText ?? this.createCommentText,
      currentUser: currentUser ?? this.currentUser,
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      postLikeState: postLikeState ?? this.postLikeState,
      avatar: avatar ?? this.avatar,
      postCreator: postCreator ?? this.postCreator,
    );
  }
}

class PostViewModel extends ChangeNotifier {
  final BuildContext context;
  final String? postId;
  final _api = ApiService();
  final _dataService = DataService();
  final lvc = ScrollController();
  final _syncService = SyncService();
  PostState _state = PostState();
  int take = 3, skip = 0;
  var createCommentTec = TextEditingController();
  Map<int, int> pager = <int, int>{};

  PostViewModel({required this.context, required this.postId}) {
    createCommentTec.addListener(() {
      state = state.copyWith(createCommentText: createCommentTec.text);
    });
    _asyncInit();

    lvc.addListener(() async {
      var max = lvc.position.maxScrollExtent;
      var current = lvc.offset;
      var percent = (current / max * 100);
      if (percent > 80) {
        if (!state.isUpdating) {
          _startDelayAsync();
          await _requestNextComments();
        }
      }
    });
  }

  set state(PostState val) {
    _state = val;
    notifyListeners();
  }

  PostState get state => _state;

  void createPostComment() async {
    var postComment = PostComment(
        id: const Uuid().v4(),
        text: state.createCommentText!,
        created: DateTime.now().toUtc().toString().replaceAll(r' ', 'T'),
        likes: 0,
        authorId: state.currentUser!.id,
        postId: postId!);

    await _dataService.cuPostComment(postComment);

    await _api.createPostComment(
        model: CreatePostCommentModel(
            created: postComment.created,
            id: postComment.id,
            postId: postComment.postId,
            text: postComment.text));

    _addCreatedComment(postComment);

    createCommentTec.clear();
  }

  Future postLikePressed(String postId) async {
    var newLikeState = !state.postLikeState!;

    await _api.changePostLikeState(postId: postId);
    await _syncService.syncPostLikeState(postId: postId);
    await _syncService.syncPost(postId: postId);
    var post = await _dataService.getPost(postId: postId);

    state = state.copyWith(postLikeState: newLikeState, post: post);
  }

  Future pressedGoToProfile({String? userId}) async {
    return await Navigator.of(context).pushNamed(
      TabNavigatorRoutes.userProfile,
      arguments: userId,
    );
  }

  void onPageChanged(int listIndex, int pageIndex) {
    pager[listIndex] = pageIndex;
    notifyListeners();
  }

  Future loadAvatar() async {
    var user = await SharedPrefs.getStoredUser();
    var img = await NetworkAssetBundle(Uri.parse("$baseUrl${user!.avatar}"))
        .load("$baseUrl${user.avatar}?v=1");
    state = state.copyWith(
        avatar: Image.memory(
      img.buffer.asUint8List(),
      fit: BoxFit.fill,
    ));
  }

  void _asyncInit() async {
    state = state.copyWith(
      isLoading: true,
      isUpdating: false,
    );

    await loadAvatar();

    var headers = await TokenStorage.getAccessToken();

    var post = await _api.getPost(postId: postId!);
    if (post != null) {
      await _dataService.cuPost(Post.fromJson(post.toJson()));

      var postAuthor = await _api.getUserById(userId: post.authorId!);
      if (postAuthor != null) {
        await _dataService.cuUser(User.fromJson(postAuthor.toJson()));
      }

      var postFiles = (await _dataService.getPostFiles(postId!))!.toList();
      var currentUser = await _dataService.getUser(post.authorId!);

      state = state.copyWith(
        postFiles: postFiles,
        headers: headers,
        post: Post.fromJson(post.toJson()),
        currentUser: currentUser,
        postCreator: (await _dataService.getUser(postAuthor!.id!)),
      );

      await _requestNextComments();
      var postLikeState =
          (await _dataService.getPostLikeState(postId!))?.isLiked ?? 0;

      state = state.copyWith(
          isLoading: false, postLikeState: postLikeState == 1 ? true : false);
    }
  }

  Future _requestNextComments() async {
    List<User> postCommentsCreators = state.postCommentsCreators ?? [];

    await _syncService.syncPostComments(
        lastPostCreated: state.postComments?.last.created,
        take,
        postId: postId!);

    List<PostComment> postComments = state.postComments ?? [];
    var newComments = await _dataService.getPostComments(
        state.postComments?.last.created == null
            ? {"postId": state.post!.id}
            : {
                "postId": state.post!.id,
                "created": state.postComments?.last.created
              },
        conds: state.postComments?.last.created == null
            ? [DbQueryEnum.equal]
            : [DbQueryEnum.equal, DbQueryEnum.isLess],
        take: take);
    if (newComments != null) {
      postComments.addAll(newComments);

      for (var postComment in newComments) {
        postCommentsCreators
            .add((await _dataService.getUser(postComment.authorId))!);
      }
    }

    state = state.copyWith(
        postComments: postComments, postCommentsCreators: postCommentsCreators);
  }

  Future _startDelayAsync({int duration = 2}) async {
    state = state.copyWith(isUpdating: true);
    await Future.delayed(Duration(seconds: duration));
    state = state.copyWith(isUpdating: false);
  }

  void _addCreatedComment(PostComment postComment) {
    List<PostComment> postComments = [postComment];
    List<User> postCommentsAuthors = [state.currentUser!];

    postComments.addAll(state.postComments!);
    postCommentsAuthors.addAll(state.postCommentsCreators!);

    state = state.copyWith(
        postComments: postComments, postCommentsCreators: postCommentsAuthors);
  }
}
