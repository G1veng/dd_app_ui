import 'package:dd_app_ui/domain/models/post_with_post_like_state.dart';
import 'package:dd_app_ui/internal/config/app_config.dart';
import 'package:dd_app_ui/internal/config/shared_prefs.dart';
import 'package:dd_app_ui/ui/widgets/common/page_indicator_widget.dart';
import 'package:dd_app_ui/domain/icons_images/icons_icons.dart';
import 'package:dd_app_ui/ui/widgets/tab_home/home/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TabHomeWidget extends StatelessWidget {
  const TabHomeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<HomeViewModel>();

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            "NotInstagram",
          ),
          leading: IconButton(
              icon: const Icon(MyIcons.addAPhoto),
              onPressed: () => viewModel.createPostPressed()),
        ),
        body: viewModel.state.postsInfo != null
            ? RefreshIndicator(
                onRefresh: viewModel.refresh,
                child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: viewModel.lvc,
                    itemBuilder: (_, listIndex) {
                      var post = viewModel.state.postsInfo![listIndex];

                      return Column(
                        children: [
                          _createPostPictures(post, listIndex, context),
                          CustomPageIndicator(
                              count: post.postFiles!.length,
                              current: viewModel.pager[listIndex]),
                          _createPostStatistics(post, listIndex, context),
                          _createPostDescription(post, listIndex, context),
                          listIndex == (viewModel.state.postsInfo!.length - 1)
                              ? viewModel.state.isLoading
                                  ? const LinearProgressIndicator()
                                  : const SizedBox.shrink()
                              : const SizedBox.shrink(),
                        ],
                      );
                    },
                    separatorBuilder: (context, index) => const Divider(),
                    itemCount: viewModel.state.postsInfo!.length))
            : const Center(child: CircularProgressIndicator()));
  }

  static Widget create() => ChangeNotifierProvider<HomeViewModel>(
        create: (context) => HomeViewModel(context: context),
        lazy: false,
        child: const TabHomeWidget(),
      );

  Widget _createPostPictures(
    PostWithPostLikeState post,
    int listIndex,
    BuildContext context,
  ) {
    var viewModel = context.read<HomeViewModel>();
    var size = MediaQuery.of(context).size;

    return GestureDetector(
        onTap: () => viewModel.postPressed(post.id!),
        child: Container(
          height: size.width,
          width: size.width,
          margin: const EdgeInsets.all(2.0),
          child: GestureDetector(
              onTap: () => viewModel.postPressed(post.id!),
              child: PageView.builder(
                itemCount:
                    viewModel.state.postsInfo![listIndex].postFiles!.length,
                onPageChanged: (value) =>
                    viewModel.onPageChanged(listIndex, value),
                itemBuilder: (_, pageViewIndex) {
                  return Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: viewModel.state.isInternetConnection == null ||
                                viewModel.state.isInternetConnection == false
                            ? Image.asset(
                                "images/empty_image.png",
                              ).image
                            : Image.network(
                                "$baseUrl${viewModel.state.postsInfo![listIndex].postFiles![pageViewIndex]!.link}",
                                headers: viewModel.state.headers,
                              ).image,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),
                    ),
                  );
                },
              )),
        ));
  }

  Widget _createPostStatistics(
      PostWithPostLikeState post, int listIndex, BuildContext context) {
    var viewModel = context.read<HomeViewModel>();

    return Container(
      margin: const EdgeInsets.all(5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => viewModel.postLikePressed(post.id!, listIndex),
            child: Row(
              children: [
                post.postLikeState == 0
                    ? const Icon(
                        MyIcons.heartEmpty,
                        color: Colors.red,
                      )
                    : const Icon(
                        MyIcons.heartFilled,
                        color: Colors.red,
                      ),
                Text(" ${post.likesAmount} Likes")
              ],
            ),
          ),
          GestureDetector(
            onTap: () => viewModel.postPressed(post.id!),
            child: Row(children: [
              Text("${post.commentAmount} Comments "),
              const Icon(
                MyIcons.comment,
                color: Colors.blue,
              ),
            ]),
          )
        ],
      ),
    );
  }

  Widget _createPostDescription(
      PostWithPostLikeState post, int listIndex, BuildContext context) {
    var viewModel = context.read<HomeViewModel>();

    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        margin: const EdgeInsets.all(2),
        child: GestureDetector(
            onTap: () => viewModel.pressedGoToProfile(post.authorId!),
            child: CircleAvatar(
              backgroundColor: Colors.grey,
              foregroundImage: post.authorAvatar != null
                  ? Image.network(
                      "$baseUrl${post.authorAvatar}",
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
                        text: "${viewModel.state.postAuthors?[listIndex]} ",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        )),
                    TextSpan(
                      text: "${post.text}",
                    ),
                  ],
                ),
              )))
    ]);
  }
}
