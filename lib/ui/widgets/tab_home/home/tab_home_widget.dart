import 'package:dd_app_ui/internal/config/app_config.dart';
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
    var size = MediaQuery.of(context).size;

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
            ? viewModel.state.postsInfo!.isNotEmpty
                ? ListView.separated(
                    itemBuilder: (listContext, listIndex) {
                      var post = viewModel.state.postsInfo![listIndex];

                      return Column(
                        children: [
                          GestureDetector(
                              onTap: () => viewModel.postPressed(post.id!),
                              child: Container(
                                height: size.width,
                                width: size.width,
                                margin: const EdgeInsets.all(2.0),
                                child: GestureDetector(
                                    onTap: () =>
                                        viewModel.postPressed(post.id!),
                                    child: PageView.builder(
                                      itemCount: viewModel
                                          .state
                                          .postsInfo![listIndex]
                                          .postFiles!
                                          .length,
                                      onPageChanged: (value) => viewModel
                                          .onPageChanged(listIndex, value),
                                      itemBuilder:
                                          (pageViewContext, pageViewIndex) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: Image.network(
                                                "$baseUrl${viewModel.state.postsInfo![listIndex].postFiles![pageViewIndex]!.link}",
                                                headers:
                                                    viewModel.state.headers,
                                              ).image,
                                              fit: BoxFit.cover,
                                              alignment: Alignment.center,
                                            ),
                                          ),
                                        );
                                      },
                                    )),
                              )),
                          CustomPageIndicator(
                              count: post.postFiles!.length,
                              current: viewModel.pager[listIndex]),
                          Text(post.text!),
                        ],
                      );
                    },
                    separatorBuilder: (context, index) => const Divider(),
                    itemCount: viewModel.state.postsInfo!.length)
                : const SizedBox.shrink()
            : const Center(child: CircularProgressIndicator()));
  }

  static Widget create() => ChangeNotifierProvider<HomeViewModel>(
        create: (context) => HomeViewModel(context: context),
        lazy: false,
        child: const TabHomeWidget(),
      );
}
