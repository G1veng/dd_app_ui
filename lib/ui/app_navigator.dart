import 'package:dd_app_ui/ui/roots/auth.dart';
import 'package:dd_app_ui/ui/roots/home.dart';
import 'package:dd_app_ui/ui/roots/loader.dart';
import 'package:flutter/cupertino.dart';

class NavigationRoutes {
  static const loader = "/";
  static const auth = "/auth";
  static const home = "/home";
}

class AppNavigator {
  static final key = GlobalKey<NavigatorState>();

  static void toLoader() {
    key.currentState
        ?.pushNamedAndRemoveUntil(NavigationRoutes.loader, (route) => false);
  }

  static void toHome() {
    key.currentState
        ?.pushNamedAndRemoveUntil(NavigationRoutes.home, (route) => false);
  }

  static void toAuth() {
    key.currentState
        ?.pushNamedAndRemoveUntil(NavigationRoutes.auth, (route) => false);
  }

  static Route<dynamic>? onGeneratedRoutes(RouteSettings settings, context) {
    switch (settings.name) {
      case NavigationRoutes.loader:
        return PageRouteBuilder(
            pageBuilder: ((_, __, ___) => LoaderWidget.create()));
      case NavigationRoutes.home:
        return PageRouteBuilder(
            pageBuilder: (_, __, ___) => HomeWidget.create("home"));
      case NavigationRoutes.auth:
        return PageRouteBuilder(
            pageBuilder: (_, __, ___) => const AuthWidget().create());
      default:
        return null;
    }
  }
}
