import 'package:dd_app_ui/internal/config/app_config.dart';
import 'package:dd_app_ui/ui/custom_ui/custom_buttom_navigation_bar.dart';
import 'package:dd_app_ui/ui/custom_ui/custom_page_indicator.dart';
import 'package:dd_app_ui/ui/post/post_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PostWidget extends StatelessWidget {
  const PostWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<PostViewModel>();
    var size = MediaQuery.of(context).size;

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
          : ListView(controller: viewModel.lvc, children: [
              SizedBox(
                  width: size.width,
                  height: size.width,
                  child: PageView.builder(
                      onPageChanged: (value) =>
                          viewModel.onPageChanged(0, value),
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
                      })),
              CustomPageIndicator(
                count: viewModel.state.postFiles!.length,
                current: viewModel.pager[0],
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
            ]),
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
