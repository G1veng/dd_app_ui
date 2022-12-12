import 'package:dd_app_ui/data/services/api_service.dart';
import 'package:dd_app_ui/data/services/data_service.dart';
import 'package:dd_app_ui/domain/models/post.dart';
import 'package:dd_app_ui/domain/models/post_comment.dart';
import 'package:dd_app_ui/domain/models/post_file.dart';
import 'package:dd_app_ui/domain/models/post_like_state.dart';
import 'package:dd_app_ui/domain/models/user.dart';
import 'package:dd_app_ui/internal/config/app_config.dart';
import 'package:dd_app_ui/internal/config/shared_prefs.dart';
import 'package:dd_app_ui/internal/config/token_storage.dart';
import 'package:dd_app_ui/ui/custom_ui/custom_buttom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:provider/provider.dart';

class _PostState {
  final Map<String, String>? headers;
  final int pageCount = 0;
  final Post? post;
  final List<PostComment>? postComments;
  final List<PostFile>? postFiles;
  final List<Row>? postCommentsWidget;
  final List<User>? postCreators;
  final String? createCommentText;
  final User? currentUser;

  _PostState({
    this.headers,
    this.post,
    this.postComments,
    this.postFiles,
    this.postCommentsWidget,
    this.postCreators,
    this.createCommentText,
    this.currentUser,
  });

  _PostState copyWith(
      {headers,
      post,
      postComments,
      postFiles,
      postCommentsWidget,
      postCreators,
      createCommentText,
      currentUser}) {
    return _PostState(
      headers: headers ?? this.headers,
      post: post ?? this.post,
      postComments: postComments ?? this.postComments,
      postFiles: postFiles ?? postFiles,
      postCommentsWidget: postCommentsWidget ?? this.postCommentsWidget,
      postCreators: postCreators ?? this.postCreators,
      createCommentText: createCommentText ?? this.createCommentText,
      currentUser: currentUser ?? this.currentUser,
    );
  }
}

class _PostViewModel extends ChangeNotifier {
  BuildContext context;
  _PostState _state = _PostState();
  final String postId;
  final _api = ApiService();
  final _dataService = DataService();
  int take = 10, skip = 0;
  var createCommentTec = TextEditingController();

  _PostViewModel({required this.context, required this.postId}) {
    createCommentTec.addListener(() {
      state = state.copyWith(createCommentText: createCommentTec.text);
    });
    _asyncInit();
  }

  set state(_PostState val) {
    _state = val;
    notifyListeners();
  }

  _PostState get state => _state;

  void _asyncInit() async {
    var headers = await TokenStorage.getAccessToken();
    if (headers != null) {
      state = state.copyWith(headers: headers);
    }

    var post = await _api.getPost(postId: postId);
    if (post != null) {
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
              (await _api.getPostLikeState(postId: post.id!)) == true ? 1 : 0));

      var comments = await _api.getPostComments(postId: postId);
      if (comments != null) {
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
    var dbPostComments =
        await _dataService.getPostComments(postId, take, skip, "created ASC");
    if (dbPostComments != null) {
      for (var postComment in dbPostComments) {
        dbPostCommentCreators
            .add(await _dataService.getUser(postComment.authorId));
      }
    }

    state.copyWith(
        post: dbPost,
        postComments: dbPostComments,
        postFiles: dbPostFiles,
        postCreators: dbPostCommentCreators,
        currentUser: await SharedPrefs.getStoredUser());

    skip += take;
  }

  void addCommentWidgets() {
    var currentWidgets = state.postCommentsWidget;
    var startIndex = currentWidgets!.length;

    for (int i = startIndex; i < state.postComments!.length; i++) {
      currentWidgets.add(Row(
        children: [
          state.postCreators![i].avatar != null
              ? Container(
                  margin: const EdgeInsets.all(2.0),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(
                      "$baseUrl${state.postCreators![i].avatar}",
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
          Column(
            children: [
              Text(state.postCreators![i].name),
              Text(state.postComments![i].text),
            ],
          ),
        ],
      ));
    }

    state = state.copyWith(postCommentsWidget: currentWidgets);
  }

  void requestNextComments() {
    //TODO сделать запрос следующих комментариев
  }
}

class PostWidget extends StatelessWidget {
  const PostWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<_PostViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text("NotInstagram")),
      body: Row(
        children: [
          viewModel.state.postFiles != null
              ? Container(
                  margin: const EdgeInsets.all(2.0),
                  child: GestureDetector(
                    child: GFAvatar(
                      backgroundImage: Image.network(
                        "$baseUrl${viewModel.state.postFiles![0].link}",
                        headers: viewModel.state.headers,
                      ).image,
                    ),
                  ))
              : Container(
                  margin: const EdgeInsets.all(3),
                  color: const Color.fromARGB(255, 165, 165, 167),
                  child: Center(
                    child: Text(
                      viewModel.state.post!.text!,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.clip,
                      style: const TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  )),
          Row(children: [
            viewModel.state.currentUser != null
                ? CircleAvatar(
                    backgroundImage: NetworkImage(
                      "$baseUrl${viewModel.state.currentUser!.avatar}",
                      headers: viewModel.state.headers,
                    ),
                    radius: (MediaQuery.of(context).size.width / 15),
                  )
                : CircleAvatar(
                    backgroundColor: Colors.grey,
                    radius: (MediaQuery.of(context).size.width / 15),
                  ),
            TextField(
              controller: viewModel.createCommentTec,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), hintText: "Enter comment text"),
              textAlign: TextAlign.start,
            ),
          ]),
          Row(
            children: viewModel.state.postCommentsWidget ?? [],
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar.create(context: context),
    );
  }

  static Widget create({required String postId}) =>
      ChangeNotifierProvider<_PostViewModel>(
        create: (context) => _PostViewModel(context: context, postId: postId),
        lazy: false,
        child: const PostWidget(),
      );
}
