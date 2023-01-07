import 'package:dd_app_ui/domain/icons_images/icons_icons.dart';
import 'package:dd_app_ui/internal/config/app_config.dart';
import 'package:dd_app_ui/ui/widgets/common/page_indicator_widget.dart';
import 'package:dd_app_ui/ui/widgets/tab_home/post_details/post_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PostWidget extends StatelessWidget {
  const PostWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<PostViewModel>();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
          title: const Text(
        "NotInstagram",
        textAlign: TextAlign.center,
      )),
      body: viewModel.state.isLoading
          ? const SafeArea(
              child: Center(
                  child: SizedBox(
              child: CircularProgressIndicator(),
            )))
          : Column(
              children: [
                _createPostComments(context),
                _createFieldAddComment(context),
              ],
            ),
    );
  }

  static Widget create({required Object? arg}) {
    String? postId;
    if (arg != null && arg is String) postId = arg;

    return ChangeNotifierProvider<PostViewModel>(
      create: (context) => PostViewModel(context: context, postId: postId),
      lazy: false,
      child: const PostWidget(),
    );
  }

  Widget _createPostDescription(BuildContext context) {
    var viewModel = context.read<PostViewModel>();

    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        margin: const EdgeInsets.all(2),
        child: GestureDetector(
            onTap: () => viewModel.pressedGoToProfile(
                userId: viewModel.state.post!.authorId!),
            child: CircleAvatar(
              backgroundColor: Colors.grey,
              foregroundImage: viewModel.state.post!.authorAvatar != null
                  ? Image.network(
                      "$baseUrl${viewModel.state.post!.authorAvatar}",
                      headers: viewModel.state.headers,
                    ).image
                  : Image.asset(
                      "images/empty_image.png",
                    ).image,
              radius: MediaQuery.of(context).size.width / 20,
            )),
      ),
      Expanded(
          child: Container(
              margin: const EdgeInsets.only(right: 5, left: 5),
              child: RichText(
                maxLines: null,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                        text: "${viewModel.state.postCreator!.name} ",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        )),
                    TextSpan(
                      text: "${viewModel.state.post!.text}",
                    ),
                  ],
                ),
              )))
    ]);
  }

  Widget _createPostComments(BuildContext context) {
    var viewModel = context.read<PostViewModel>();

    return Expanded(
        child: ListView.separated(
      controller: viewModel.lvc,
      itemBuilder: (_, index) {
        if (index == viewModel.state.postComments!.length &&
            viewModel.state.isUpdating) {
          return Column(children: [
            _cretePostComment(context, index - 1),
            const LinearProgressIndicator()
          ]);
        }
        if (index == 0) {
          return Column(
            children: [
              _createPostImages(context),
              CustomPageIndicator(
                count: viewModel.state.postFiles!.length,
                current: viewModel.pager[0],
              ),
              _createPostStatistics(context),
              _createPostDescription(context),
            ],
          );
        } else {
          return _cretePostComment(context, index - 1);
        }
      },
      itemCount: viewModel.state.postComments == null
          ? 1
          : viewModel.state.postComments!.length + 1,
      separatorBuilder: (context, index) => const Divider(),
    ));
  }

  Widget _createPostStatistics(BuildContext context) {
    var viewModel = context.watch<PostViewModel>();

    return Container(
      margin: const EdgeInsets.all(5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => viewModel.postLikePressed(viewModel.state.post!.id!),
            child: Row(
              children: [
                viewModel.state.postLikeState == false
                    ? const Icon(
                        MyIcons.heartEmpty,
                        color: Colors.red,
                      )
                    : const Icon(
                        MyIcons.heartFilled,
                        color: Colors.red,
                      ),
                Text(" ${viewModel.state.post?.likesAmount ?? 0} Likes")
              ],
            ),
          ),
          Row(children: [
            Text("${viewModel.state.post?.commentAmount ?? 0} Comments "),
            const Icon(
              MyIcons.comment,
              color: Colors.blue,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _cretePostComment(BuildContext context, int index) {
    var viewModel = context.read<PostViewModel>();

    return Row(
      children: [
        GestureDetector(
            onTap: () => viewModel.pressedGoToProfile(
                userId: viewModel.state.postCommentsCreators![index].id),
            child: Container(
                margin: const EdgeInsets.all(2.0),
                child: CircleAvatar(
                  backgroundColor: Colors.grey,
                  backgroundImage: Image.network(
                    "$baseUrl${viewModel.state.postCommentsCreators![index].avatar}",
                    headers: viewModel.state.headers,
                  ).image,
                  radius: (MediaQuery.of(context).size.width / 15),
                ))),
        RichText(
          maxLines: null,
          text: TextSpan(
            style: const TextStyle(
              fontSize: 14.0,
              color: Colors.black,
            ),
            children: <TextSpan>[
              TextSpan(
                  text: "${viewModel.state.postCommentsCreators![index].name} ",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  )),
              TextSpan(
                text: viewModel.state.postComments![index].text,
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _createFieldAddComment(BuildContext context) {
    var viewModel = context.read<PostViewModel>();

    return Row(children: [
      GestureDetector(
          onTap: () => viewModel.pressedGoToProfile(),
          child: Container(
              margin: const EdgeInsets.all(5.0),
              child: CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: viewModel.state.avatar != null
                    ? viewModel.state.avatar!.image
                    : Image.asset(
                        "images/empty_image.png",
                      ).image,
                radius: (MediaQuery.of(context).size.width / 13),
              ))),
      Flexible(
          child: Container(
              margin: const EdgeInsets.all(10.0),
              child: TextField(
                maxLength: 100,
                textCapitalization: TextCapitalization.sentences,
                textAlignVertical: TextAlignVertical.bottom,
                controller: viewModel.createCommentTec,
                maxLines: null,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  hintText: "Enter comment",
                  counterText: "",
                ),
                textAlign: TextAlign.start,
              ))),
      Container(
          margin: const EdgeInsets.all(5.0),
          child: ElevatedButton(
              onPressed: viewModel.state.createCommentText != null &&
                      viewModel.state.createCommentText!.isNotEmpty
                  ? () => viewModel.createPostComment()
                  : null,
              child: const Icon(Icons.send)))
    ]);
  }

  Widget _createPostImages(BuildContext context) {
    var viewModel = context.read<PostViewModel>();
    var size = MediaQuery.of(context).size;

    return SizedBox(
        width: size.width,
        height: size.width,
        child: PageView.builder(
            onPageChanged: (value) => viewModel.onPageChanged(0, value),
            itemCount: viewModel.state.postFiles!.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.all(2.0),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: Image.network(
                      "$baseUrl${viewModel.state.postFiles![index].link}",
                      headers: viewModel.state.headers,
                    ).image,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                ),
              );
            }));
  }
}
