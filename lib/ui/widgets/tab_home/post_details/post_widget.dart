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
          : ListView.separated(
              controller: viewModel.lvc,
              itemBuilder: (_, index) {
                if (index == 0) {
                  return Column(
                    children: [
                      _createPostImages(context),
                      CustomPageIndicator(
                        count: viewModel.state.postFiles!.length,
                        current: viewModel.pager[0],
                      ),
                      _createPostStatistics(context),
                      _createFieldAddComment(context),
                    ],
                  );
                } else {
                  if (index == viewModel.state.postComments!.length &&
                      viewModel.state.isUpdating) {
                    return Column(children: [
                      _cretePostComment(context, index),
                      const LinearProgressIndicator()
                    ]);
                  }
                  return _cretePostComment(context, index);
                }
              },
              itemCount: viewModel.state.postComments!.length + 1,
              separatorBuilder: (context, index) => const Divider(),
            ),
    );
  }

  static Widget create({required Object? postId}) =>
      ChangeNotifierProvider<PostViewModel>(
        create: (context) =>
            PostViewModel(context: context, postId: postId as String),
        lazy: false,
        child: const PostWidget(),
      );

  Row _createPostStatistics(BuildContext context) {
    return Row();
  }

  Row _cretePostComment(BuildContext context, int index) {
    var viewModel = context.read<PostViewModel>();

    return Row(
      children: [
        Container(
            margin: const EdgeInsets.all(2.0),
            child: CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage: Image.network(
                "$baseUrl${viewModel.state.postCommentsCreators![index - 1].avatar}",
                headers: viewModel.state.headers,
              ).image,
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
                  text: "${viewModel.state.currentUser!.name} ",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  )),
              TextSpan(
                text: viewModel.state.postComments![index - 1].text,
              ),
            ],
          ),
        ))
      ],
    );
  }

  Row _createFieldAddComment(BuildContext context) {
    var viewModel = context.read<PostViewModel>();

    return Row(children: [
      Container(
          margin: const EdgeInsets.all(5.0),
          child: CircleAvatar(
            backgroundColor: Colors.grey,
            backgroundImage: Image.network(
              "$baseUrl${viewModel.state.currentUser?.avatar}",
              headers: viewModel.state.headers,
            ).image,
            radius: (MediaQuery.of(context).size.width / 13),
          )),
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
                    border: UnderlineInputBorder(), hintText: "Enter comment"),
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

  SizedBox _createPostImages(BuildContext context) {
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
