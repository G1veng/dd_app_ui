import 'package:dd_app_ui/ui/roots/auth.dart';
import 'package:dd_app_ui/ui/roots/home.dart';
import 'package:dd_app_ui/ui/roots/loader.dart';
import 'package:dd_app_ui/ui/roots/registration.dart';
import 'package:dd_app_ui/ui/roots/user_profile.dart';
import 'package:dd_app_ui/ui/roots/users.dart';
import 'package:flutter/cupertino.dart';

class NavigationRoutes {
  static const loader = "/";
  static const auth = "/auth";
  static const home = "/home";
  static const userProfile = "/user_profile";
  static const registration = "/registration";
  static const users = "/users";
}

class AppNavigator {
  static final key = GlobalKey<NavigatorState>();

  static void toLoader() {
    key.currentState
        ?.pushNamedAndRemoveUntil(NavigationRoutes.loader, (route) => false);
  }

  static void toRegistration() {
    key.currentState?.pushNamed(NavigationRoutes.registration);
  }

  static void toHome() {
    key.currentState
        ?.pushNamedAndRemoveUntil(NavigationRoutes.home, (route) => false);
  }

  static void toAuth() {
    key.currentState
        ?.pushNamedAndRemoveUntil(NavigationRoutes.auth, (route) => false);
  }

  static void toUsers() {
    key.currentState?.pushNamed(NavigationRoutes.users);
  }

  static void toUserProfile() {
    key.currentState?.pushNamed(NavigationRoutes.userProfile);
  }

  static Route<dynamic>? onGeneratedRoutes(RouteSettings settings, context) {
    switch (settings.name) {
      case NavigationRoutes.loader:
        return PageRouteBuilder(
          pageBuilder: ((_, __, ___) => LoaderWidget.create()),
        );
      case NavigationRoutes.home:
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => HomeWidget.create(),
        );
      case NavigationRoutes.auth:
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => const AuthWidget().create(),
        );
      case NavigationRoutes.userProfile:
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => UserProfileWidget.create(),
        );
      case NavigationRoutes.registration:
        return PageRouteBuilder(
            pageBuilder: (_, __, ___) => RegistrationWidget.create());
      case NavigationRoutes.users:
        return PageRouteBuilder(
            pageBuilder: (_, __, ___) => UsersWidget.create());
      default:
        return null;
    }
  }
}
