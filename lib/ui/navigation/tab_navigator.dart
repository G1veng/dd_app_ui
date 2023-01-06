import 'package:dd_app_ui/domain/enums/tab_item.dart';
import 'package:dd_app_ui/ui/widgets/tab_direct/direct/direct_widget.dart';
import 'package:dd_app_ui/ui/widgets/tab_home/create_post/create_post_widget.dart';
import 'package:dd_app_ui/ui/widgets/tab_home/post_details/post_widget.dart';
import 'package:dd_app_ui/ui/widgets/tab_user_profile/user_profile_widget.dart';
import 'package:flutter/material.dart';

class TabNavigatorRoutes {
  static const String root = '/app/';
  static const String postDetails = "/app/postDetails";
  static const String createPost = "/app/createPost";
  static const String userProfile = "/user/userProfile";
  static const String direct = "/directs/direct";
}

class TabNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final TabItemEnum tabItem;
  const TabNavigator({
    Key? key,
    required this.navigatorKey,
    required this.tabItem,
  }) : super(key: key);

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context,
          {Object? arg}) =>
      {
        TabNavigatorRoutes.root: (context) =>
            TabEnums.tabRoots(tabItem) ??
            SafeArea(
              child: Text(tabItem.name),
            ),
        TabNavigatorRoutes.postDetails: (context) =>
            PostWidget.create(arg: arg),
        TabNavigatorRoutes.createPost: (context) => CreatePostWidget.create(),
        TabNavigatorRoutes.userProfile: (context) =>
            UserProfileWidget.create(arg),
        TabNavigatorRoutes.direct: (context) =>
            DirectWidget.create(context: context, arg: arg),
      };

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      initialRoute: TabNavigatorRoutes.root,
      onGenerateRoute: (settings) {
        var rb = _routeBuilders(context, arg: settings.arguments);
        if (rb.containsKey(settings.name)) {
          return MaterialPageRoute(
              builder: (context) => rb[settings.name]!(context));
        }

        return null;
      },
    );
  }
}
