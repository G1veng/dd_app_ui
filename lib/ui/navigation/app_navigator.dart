import 'package:dd_app_ui/ui/widgets/roots/auth/auth_widget.dart';
import 'package:dd_app_ui/ui/widgets/roots/app/app_widget.dart';
import 'package:dd_app_ui/ui/widgets/roots/loader/loader_widget.dart';
import 'package:dd_app_ui/ui/widgets/roots/registration/registration_widget.dart';
import 'package:flutter/cupertino.dart';

class NavigationRoutes {
  static const loader = "/";
  static const auth = "/auth";
  static const home = "/app";
  static const registration = "/registration";
}

class AppNavigator {
  static final key = GlobalKey<NavigatorState>();

  static Future toLoader() async {
    return await key.currentState
        ?.pushNamedAndRemoveUntil(NavigationRoutes.loader, (route) => false);
  }

  static Future toRegistration() async {
    return await key.currentState?.pushNamed(NavigationRoutes.registration);
  }

  static Future toHome() async {
    return await key.currentState
        ?.pushNamedAndRemoveUntil(NavigationRoutes.home, (route) => false);
  }

  static Future toAuth() async {
    return await key.currentState
        ?.pushNamedAndRemoveUntil(NavigationRoutes.auth, (route) => false);
  }

  static Route<dynamic>? onGeneratedRoutes(RouteSettings settings, context) {
    switch (settings.name) {
      case NavigationRoutes.loader:
        return PageRouteBuilder(
          pageBuilder: ((_, __, ___) => LoaderWidget.create()),
        );
      case NavigationRoutes.home:
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => AppWidget.create(),
        );
      case NavigationRoutes.auth:
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => const AuthWidget().create(),
        );
      case NavigationRoutes.registration:
        return PageRouteBuilder(
            pageBuilder: (_, __, ___) => RegistrationWidget.create());
      default:
        return null;
    }
  }
}
