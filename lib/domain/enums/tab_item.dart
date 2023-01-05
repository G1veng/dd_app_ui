import 'package:dd_app_ui/ui/widgets/tab_direct/directs/directs_widget.dart';
import 'package:dd_app_ui/ui/widgets/tab_user_profile/user_profile_widget.dart';
import 'package:dd_app_ui/domain/icons_images/icons_icons.dart';
import 'package:dd_app_ui/ui/widgets/tab_home/home/home_widget.dart';
import 'package:dd_app_ui/ui/widgets/tab_users/users/users_widget.dart';
import 'package:flutter/material.dart';

enum TabItemEnum {
  home,
  search,
  direct,
  profile,
}

class TabEnums {
  static const TabItemEnum defTab = TabItemEnum.home;

  static Map<TabItemEnum, IconData> tabIcon = {
    TabItemEnum.home: MyIcons.homeOutline,
    TabItemEnum.search: MyIcons.userAddOutline,
    TabItemEnum.direct: MyIcons.comment,
    TabItemEnum.profile: MyIcons.userOutline,
  };

  static Map<TabItemEnum, IconData> selectedTabIcon = {
    TabItemEnum.home: MyIcons.home,
    TabItemEnum.search: MyIcons.userAdd,
    TabItemEnum.direct: MyIcons.chat,
    TabItemEnum.profile: MyIcons.user,
  };

  static Widget? tabRoots(TabItemEnum tabItem, {Object? arg}) {
    if (tabItem == TabItemEnum.home) {
      return TabHomeWidget.create();
    } else if (tabItem == TabItemEnum.search) {
      return UsersWidget.create();
    } else if (tabItem == TabItemEnum.profile) {
      return UserProfileWidget.create(arg);
    } else if (tabItem == TabItemEnum.direct) {
      return DirectWidget.create();
    }
    return null;
  }
}
