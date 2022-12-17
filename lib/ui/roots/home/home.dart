import 'package:dd_app_ui/ui/custom_ui/custom_buttom_navigation_bar.dart';
import 'package:dd_app_ui/ui/roots/home/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeWidget extends StatelessWidget {
  const HomeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<HomeViewModel>();

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            "NotInstagram",
          ),
          leading: viewModel.state.isRuning
              ? const CircularProgressIndicator(
                  color: Colors.red,
                  strokeWidth: 4.0,
                )
              : null,
        ),
        body: NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification is ScrollEndNotification) {
                viewModel.requestNextPosts;
                return true;
              }
              return false;
            },
            child: SingleChildScrollView(
                child: GestureDetector(
              child: Column(children: viewModel.state.postsWidgets ?? []),
              onVerticalDragUpdate: (details) =>
                  (details.delta.distance > 10.0 && !viewModel.isUpdating)
                      ? viewModel.updateScreenPosts(isUpdate: true)
                      : null,
            ))),
        bottomNavigationBar:
            CustomBottomNavigationBar.create(context: context, isHome: true));
  }

  static Widget create() => ChangeNotifierProvider<HomeViewModel>(
        create: (context) => HomeViewModel(context: context),
        lazy: false,
        child: const HomeWidget(),
      );
}
