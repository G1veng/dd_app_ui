import 'package:dd_app_ui/data/services/api_service.dart';
import 'package:dd_app_ui/data/services/data_service.dart';
import 'package:dd_app_ui/domain/models/create_post_comment_model.dart';
import 'package:dd_app_ui/domain/models/post.dart';
import 'package:dd_app_ui/domain/models/post_comment.dart';
import 'package:dd_app_ui/domain/models/post_file.dart';
import 'package:dd_app_ui/domain/models/post_like_state.dart';
import 'package:dd_app_ui/domain/models/user.dart';
import 'package:dd_app_ui/internal/config/app_config.dart';
import 'package:dd_app_ui/internal/config/shared_prefs.dart';
import 'package:dd_app_ui/internal/config/token_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class PostState {
  final Map<String, String>? headers;
  final int pageCount = 0;
  final Post? post;
  final List<PostComment>? postComments;
  final List<PostFile>? postFiles;
  final List<Row>? postCommentsWidget;
  final List<User?>? postCommentsCreators;
  final String? createCommentText;
  final User? currentUser;
  final bool isLoading;

  PostState(
      {this.headers,
      this.post,
      this.postComments,
      this.postFiles,
      this.postCommentsWidget,
      this.postCommentsCreators,
      this.createCommentText,
      this.currentUser,
      this.isLoading = true});

  PostState copyWith({
    headers,
    post,
    postComments,
    postFiles,
    postCommentsWidget,
    postCommentsCreators,
    createCommentText,
    currentUser,
    isLoading,
  }) {
    return PostState(
        headers: headers != null
            ? {"Authorization": "Bearer $headers"}
            : this.headers,
        post: post ?? this.post,
        postComments: postComments ?? this.postComments,
        postFiles: postFiles ?? this.postFiles,
        postCommentsWidget: postCommentsWidget ?? this.postCommentsWidget,
        postCommentsCreators: postCommentsCreators ?? this.postCommentsCreators,
        createCommentText: createCommentText ?? this.createCommentText,
        currentUser: currentUser ?? this.currentUser,
        isLoading: isLoading ?? this.isLoading);
  }
}

class PostViewModel extends ChangeNotifier {
  BuildContext context;
  PostState _state = PostState();
  final String postId;
  final _api = ApiService();
  final _dataService = DataService();
  int take = 2, skip = 0;
  var createCommentTec = TextEditingController();
  Map<int, int> pager = <int, int>{};
  final lvc = ScrollController();

  PostViewModel({required this.context, required this.postId}) {
    createCommentTec.addListener(() {
      state = state.copyWith(createCommentText: createCommentTec.text);
    });
    _asyncInit();
  }

  set state(PostState val) {
    _state = val;
    notifyListeners();
  }

  PostState get state => _state;

  void _asyncInit() async {
    state = state.copyWith(isLoading: true);

    lvc.addListener(() async {
      var max = lvc.position.maxScrollExtent;
      var current = lvc.offset;
      var percent = (current / max * 100);
      if (percent > 80) {
        if (!state.isLoading) {
          //state.isLoading = true;
          Future.delayed(const Duration(seconds: 1)).then((value) {
            //TODO запрос на получение новых комментариев
          });

          //isLoading = false;

          addCommentWidgets();
        }
      }
    });

    var headers = await TokenStorage.getAccessToken();
    if (headers != null) {
      state = state.copyWith(headers: headers);
    }

    var post = await _api.getPost(postId: postId);
    if (post != null) {
      var postAuthor = await _api.getUserById(userId: post.authorId!);
      var test = User.fromJson(postAuthor!.toJson());
      await _dataService.cuUser(test);

      await _dataService.cuPost(Post(
        id: post.id,
        created: post.created,
        text: post.text,
        authorId: post.authorId,
        authorAvatar: post.authorAvatar,
        commentAmount: post.commentAmount,
        likesAmount: post.likesAmount,
      ));

      if (post.postFiles != null && post.postFiles!.isNotEmpty) {
        for (var file in post.postFiles!) {
          await _dataService.cuPostFile(file!);
        }
      }

      await _dataService.cuPostLikeState(PostLikeState(
          id: post.id!,
          isLiked:
              (await _api.getPostLikeState(postId: post.id!)) == true ? 1 : 0));

      var comments = await _api.getPostComments(
        postId: postId,
        take: take,
        skip: skip,
      );
      if (comments != null && comments.isNotEmpty) {
        for (var comment in comments) {
          var user = await _api.getUserById(userId: comment.authorId);
          if (user != null) {
            await _dataService.cuUser(User(
              id: user.id!,
              name: user.name!,
              email: user.email!,
              birthDate: user.birthDate!,
              avatar: user.avatar,
            ));
          }
        }

        await _dataService.cuPostComments(comments);
      }
    }

    List<User?> dbPostCommentCreators = [];
    var dbPost = await _dataService.getPost(postId);
    var dbPostFiles = await _dataService.getPostFiles(postId);
    var dbPostComments = (await _dataService.getPostComments(
        postId, take, skip, '"Created" DESC'));

    if (dbPostComments != null) {
      for (var postComment in dbPostComments) {
        dbPostCommentCreators
            .add(await _dataService.getUser(postComment.authorId));
      }
    }

    state = state.copyWith(
        post: dbPost,
        postComments: dbPostComments == null || dbPostComments.isEmpty
            ? null
            : dbPostComments.toList(),
        postFiles: dbPostFiles == null || dbPostFiles.isEmpty
            ? null
            : dbPostFiles.toList(),
        postCommentsCreators: dbPostCommentCreators.isEmpty
            ? null
            : dbPostCommentCreators.toList(),
        currentUser: await SharedPrefs.getStoredUser(),
        isLoading: false);

    skip += take;
    addCommentWidgets();
  }

  void addCreatedComment(PostComment postComment) {
    var currentWidgets = state.postCommentsWidget ?? [];

    List<Row> tempRow = [];
    tempRow.add(Row(
      children: [
        state.currentUser!.avatar != null
            ? Container(
                margin: const EdgeInsets.all(2.0),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(
                    "$baseUrl${state.currentUser!.avatar}",
                    headers: state.headers,
                  ),
                  radius: (MediaQuery.of(context).size.width / 15),
                ))
            : Container(
                margin: const EdgeInsets.all(2.0),
                child: CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: (MediaQuery.of(context).size.width / 15),
                )),
        Expanded(
            child: RichText(
          maxLines: null,
          text: TextSpan(
            style: const TextStyle(
              fontSize: 14.0,
              color: Colors.black,
            ),
            children: <TextSpan>[
              TextSpan(
                  text: "${state.currentUser!.name} ",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  )),
              TextSpan(
                text: postComment.text,
              ),
            ],
          ),
        ))
      ],
    ));

    tempRow.addAll(currentWidgets);

    state = state.copyWith(postCommentsWidget: tempRow);
  }

  void addCommentWidgets() {
    var currentWidgets = state.postCommentsWidget ?? [];
    var startIndex = currentWidgets.length;

    for (int i = startIndex; i < state.postComments!.length; i++) {
      currentWidgets.add(Row(
        children: [
          state.postCommentsCreators![i]!.avatar != null
              ? Container(
                  margin: const EdgeInsets.all(2.0),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(
                      "$baseUrl${state.postCommentsCreators![i]!.avatar}",
                      headers: state.headers,
                    ),
                    radius: (MediaQuery.of(context).size.width / 15),
                  ))
              : Container(
                  margin: const EdgeInsets.all(2.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.grey,
                    radius: (MediaQuery.of(context).size.width / 15),
                  )),
          Expanded(
              child: RichText(
            maxLines: null,
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14.0,
                color: Colors.black,
              ),
              children: <TextSpan>[
                TextSpan(
                    text: "${state.postCommentsCreators![i]!.name} ",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    )),
                TextSpan(
                  text: state.postComments![i].text,
                ),
              ],
            ),
          ))
        ],
      ));
    }

    state = state.copyWith(postCommentsWidget: currentWidgets);
  }

  Future requestNextComments() async {
    var postCommentsCreators = state.postCommentsCreators ?? [];
    var postComments = state.postComments ?? [];
    var comments =
        await _api.getPostComments(postId: postId, take: take, skip: skip);

    if (comments != null) {
      for (var comment in comments) {
        var author = await _api.getUserById(userId: comment.authorId);
        await _dataService.cuUser(User(
          id: author!.id!,
          name: author.name!,
          email: author.email!,
          birthDate: author.birthDate!,
          avatar: author.avatar,
        ));
        postCommentsCreators.add(await _dataService.getUser(author.id!));

        await _dataService.cuPostComment(comment);
        postComments.add((await _dataService.getPostComment(comment.id))!);
      }
    }

    state = state.copyWith(
      postCommentsCreators: postCommentsCreators,
      postComments: postComments,
    );
  }

  void createPostComment() async {
    var postComment = PostComment(
        id: const Uuid().v4(),
        text: state.createCommentText!,
        created: DateTime.now().toUtc().toString().replaceAll(r' ', 'T'),
        likes: 0,
        authorId: state.currentUser!.id,
        postId: postId);

    await _dataService.cuPostComment(postComment);

    await _api.createPostComment(
        model: CreatePostCommentModel(
            created: postComment.created,
            id: postComment.id,
            postId: postComment.postId,
            text: postComment.text));

    addCreatedComment(postComment);

    createCommentTec.clear();
  }

  void onPageChanged(int listIndex, int pageIndex) {
    pager[listIndex] = pageIndex;
    notifyListeners();
  }
}
