import 'package:dd_app_ui/ui/app_navigator.dart';
import 'package:dd_app_ui/ui/icons_images/icons_icons.dart';
import 'package:flutter/material.dart';

class CustomBottomNavigationBar {
  static SizedBox create(
      {required BuildContext context,
      bool isHome = false,
      bool isUserProfile = false}) {
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
                  width: MediaQuery.of(context).size.width / 2,
                  child: IconButton(
                    onPressed: isHome ? () => {} : () => AppNavigator.toHome(),
                    icon: Icon(isHome ? MyIcons.home : MyIcons.homeOutline),
                  )),
              SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  child: IconButton(
                      onPressed: isUserProfile
                          ? () => {}
                          : () => AppNavigator.toUserProfile(),
                      icon: Icon(
                          isUserProfile ? MyIcons.user : MyIcons.userOutline))),
            ],
          ),
        ]));
  }
}
