import 'package:dd_app_ui/domain/enums/tab_item.dart';
import 'package:dd_app_ui/ui/navigation/tab_navigator.dart';
import 'package:dd_app_ui/ui/widgets/roots/app/app_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dd_app_ui/ui/widgets/common/navigation_bar_widget.dart'
    as nav_bar;

class AppWidget extends StatelessWidget {
  const AppWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<AppViewModel>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: WillPopScope(
          onWillPop: () async {
            var isFirstRouteInCurrentTab = !await viewModel
                .navigationKeys[viewModel.currentTab]!.currentState!
                .maybePop();
            if (isFirstRouteInCurrentTab) {
              if (viewModel.currentTab != TabEnums.defTab) {
                viewModel.selectTab(TabEnums.defTab);
              }
              return false;
            }
            return isFirstRouteInCurrentTab;
          },
          child: Scaffold(
            bottomNavigationBar: nav_bar.NavigationBar(
              currentTab: viewModel.currentTab,
              onSelectTab: viewModel.selectTab,
            ),
            body: Stack(
                children: TabItemEnum.values
                    .map((e) => _buildOffstageNavigator(context, e))
                    .toList()),
          )),
    );
  }

  static Widget create() => ChangeNotifierProvider<AppViewModel>(
        create: (context) => AppViewModel(context: context),
        child: const AppWidget(),
      );

  Widget _buildOffstageNavigator(BuildContext context, TabItemEnum tabItem) {
    var viewModel = context.watch<AppViewModel>();

    return Offstage(
      offstage: viewModel.currentTab != tabItem,
      child: TabNavigator(
        navigatorKey: viewModel.navigationKeys[tabItem]!,
        tabItem: tabItem,
      ),
    );
  }
}
