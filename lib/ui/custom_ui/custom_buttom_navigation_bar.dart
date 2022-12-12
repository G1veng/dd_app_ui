import 'package:dd_app_ui/ui/app_navigator.dart';
import 'package:dd_app_ui/ui/icons_images/icons_icons.dart';
import 'package:flutter/material.dart';

class CustomBottomNavigationBar {
  static const int elementsCount = 3;

  static SizedBox create({
    required BuildContext context,
    bool isHome = false,
    bool isUserProfile = false,
    bool isUsers = false,
  }) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.09,
        child: Column(children: [
          const Divider(
            color: Colors.grey,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                  width: MediaQuery.of(context).size.width / elementsCount,
                  child: IconButton(
                    onPressed: isHome ? () => {} : () => AppNavigator.toHome(),
                    icon: Icon(isHome ? MyIcons.home : MyIcons.homeOutline),
                  )),
              SizedBox(
                  width: MediaQuery.of(context).size.width / elementsCount,
                  child: IconButton(
                      onPressed: isUserProfile
                          ? () => {}
                          : () => AppNavigator.toUserProfile(),
                      icon: Icon(
                          isUserProfile ? MyIcons.user : MyIcons.userOutline))),
              SizedBox(
                  width: MediaQuery.of(context).size.width / elementsCount,
                  child: IconButton(
                      onPressed:
                          isUsers ? () => {} : () => AppNavigator.toUsers(),
                      icon: Icon(
                          isUsers ? MyIcons.userAdd : MyIcons.userAddOutline))),
            ],
          ),
        ]));
  }
}
