import 'package:dd_app_ui/ui/widgets/tab_current_user_profile/current_user_profile.dart';
import 'package:dd_app_ui/domain/icons_images/icons_icons.dart';
import 'package:dd_app_ui/ui/widgets/tab_home/home/tab_home_widget.dart';
import 'package:dd_app_ui/ui/widgets/tab_users/users/users_widget.dart';
import 'package:flutter/material.dart';

enum TabItemEnum {
  home,
  search,
  profile,
}

class TabEnums {
  static const TabItemEnum defTab = TabItemEnum.home;

  static Map<TabItemEnum, IconData> tabIcon = {
    TabItemEnum.home: MyIcons.homeOutline,
    TabItemEnum.search: MyIcons.userAddOutline,
    TabItemEnum.profile: MyIcons.userOutline,
  };

  static Map<TabItemEnum, IconData> selectedTabIcon = {
    TabItemEnum.home: MyIcons.home,
    TabItemEnum.search: MyIcons.userAdd,
    TabItemEnum.profile: MyIcons.user,
  };

  static Map<TabItemEnum, Widget> tabRoots = {
    TabItemEnum.home: TabHomeWidget.create(),
    TabItemEnum.search: UsersWidget.create(),
    TabItemEnum.profile: CurrentUserProfileWidget.create(),
  };
}
