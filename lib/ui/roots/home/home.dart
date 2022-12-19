import 'package:dd_app_ui/internal/config/app_config.dart';
import 'package:dd_app_ui/ui/app_navigator.dart';
import 'package:dd_app_ui/ui/custom_ui/custom_buttom_navigation_bar.dart';
import 'package:dd_app_ui/ui/custom_ui/custom_page_indicator.dart';
import 'package:dd_app_ui/ui/icons_images/icons_icons.dart';
import 'package:dd_app_ui/ui/roots/home/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeWidget extends StatelessWidget {
  const HomeWidget({Key? key}) : super(key: key);

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
          leading: const IconButton(
              icon: Icon(MyIcons.addAPhoto),
              onPressed: AppNavigator.toCreatePost),
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
            : const Center(child: CircularProgressIndicator()),
        bottomNavigationBar:
            CustomBottomNavigationBar.create(context: context, isHome: true));
  }

  static Widget create() => ChangeNotifierProvider<HomeViewModel>(
        create: (context) => HomeViewModel(context: context),
        lazy: false,
        child: const HomeWidget(),
      );
}
