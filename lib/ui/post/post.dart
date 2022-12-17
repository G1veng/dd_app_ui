import 'package:dd_app_ui/internal/config/app_config.dart';
import 'package:dd_app_ui/ui/custom_ui/custom_buttom_navigation_bar.dart';
import 'package:dd_app_ui/ui/post/post_view_model.dart';
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
          : SingleChildScrollView(
              child: Column(children: [
              SafeArea(
                child: viewModel.state.postFiles != null &&
                        viewModel.state.postFiles!.isNotEmpty
                    ? Container(
                        margin: const EdgeInsets.all(2.0),
                        child: Container(
                          height: (MediaQuery.of(context).size.width),
                          width: (MediaQuery.of(context).size.width),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: Image.network(
                                  "$baseUrl${viewModel.state.postFiles![0].link}",
                                  headers: viewModel.state.headers,
                                ).image,
                                fit: BoxFit.cover,
                                alignment: Alignment.center),
                          ),
                        ))
                    : SizedBox(
                        width: (MediaQuery.of(context).size.width),
                        child: Container(
                            margin: const EdgeInsets.all(5.0),
                            color: Colors.grey,
                            child: Text("${viewModel.state.post!.text}")),
                      ),
              ),
              Row(children: [
                viewModel.state.currentUser!.avatar != null
                    ? Container(
                        margin: const EdgeInsets.all(5.0),
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(
                            "$baseUrl${viewModel.state.currentUser!.avatar}",
                            headers: viewModel.state.headers,
                          ),
                          radius: (MediaQuery.of(context).size.width / 13),
                        ))
                    : Container(
                        margin: const EdgeInsets.all(5.0),
                        child: CircleAvatar(
                          backgroundColor: Colors.grey,
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
                              border: UnderlineInputBorder(),
                              hintText: "Enter comment"),
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
              ]),
              NotificationListener<ScrollNotification>(
                  onNotification: (scrollNotification) {
                    if (scrollNotification is ScrollEndNotification) {
                      viewModel.requestNextComments();
                      return true;
                    }
                    return false;
                  },
                  child: SingleChildScrollView(
                    child: Column(
                      children: viewModel.state.postCommentsWidget ?? [],
                    ),
                  ))
            ])),
      bottomNavigationBar: CustomBottomNavigationBar.create(context: context),
    );
  }

  static Widget create({required String postId}) =>
      ChangeNotifierProvider<PostViewModel>(
        create: (context) => PostViewModel(context: context, postId: postId),
        lazy: false,
        child: const PostWidget(),
      );
}
