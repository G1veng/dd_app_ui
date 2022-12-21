import 'package:dd_app_ui/domain/enums/tab_item.dart';
import 'package:dd_app_ui/ui/widgets/roots/app/app_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NavigationBar extends StatelessWidget {
  final TabItemEnum currentTab;
  final ValueChanged<TabItemEnum> onSelectTab;
  const NavigationBar(
      {Key? key, required this.currentTab, required this.onSelectTab})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var appModel = context.watch<AppViewModel>();
    return BottomNavigationBar(
      iconSize: 26,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.grey,
      currentIndex: TabItemEnum.values.indexOf(currentTab),
      items: TabItemEnum.values.map((e) => _buildItem(e, appModel)).toList(),
      onTap: (value) {
        FocusScope.of(context).unfocus();
        onSelectTab(TabItemEnum.values[value]);
      },
    );
  }

  BottomNavigationBarItem _buildItem(
      TabItemEnum tabItem, AppViewModel appmodel) {
    var isCurrent = currentTab == tabItem;
    var iconData = isCurrent
        ? TabEnums.selectedTabIcon[tabItem]
        : TabEnums.tabIcon[tabItem];
    Widget icon = Icon(
      iconData,
      color: Colors.black,
    );
    if (tabItem == TabItemEnum.profile) {
      icon = CircleAvatar(
        radius: 14,
        foregroundImage: appmodel.avatar?.image,
        backgroundColor: Colors.grey,
      );
    }
    return BottomNavigationBarItem(
        label: "",
        backgroundColor: isCurrent ? Colors.grey : Colors.transparent,
        icon: icon);
  }
}
