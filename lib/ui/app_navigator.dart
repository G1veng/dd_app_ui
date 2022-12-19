import 'package:dd_app_ui/ui/create_post/create_post.dart';
import 'package:dd_app_ui/ui/current_user_profile/current_user_profile.dart';
import 'package:dd_app_ui/ui/roots/auth/auth.dart';
import 'package:dd_app_ui/ui/roots/home/home.dart';
import 'package:dd_app_ui/ui/roots/loader/loader.dart';
import 'package:dd_app_ui/ui/post/post.dart';
import 'package:dd_app_ui/ui/roots/registration/registration.dart';
import 'package:dd_app_ui/ui/users/users.dart';
import 'package:flutter/cupertino.dart';

class NavigationRoutes {
  static const loader = "/";
  static const auth = "/auth";
  static const home = "/home";
  static const userProfile = "/app/user_profile";
  static const registration = "/registration";
  static const users = "/app/users";
  static const post = "/app/post";
  static const createPost = "/app/create_post";
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

  static Future toUsers() async {
    return await key.currentState?.pushNamed(NavigationRoutes.users);
  }

  static Future toUserProfile() async {
    return await key.currentState?.pushNamed(NavigationRoutes.userProfile);
  }

  static Future toPost({required String postId}) async {
    return await key.currentState
        ?.pushNamed(NavigationRoutes.post, arguments: postId);
  }

  static Future toCreatePost() async {
    return await key.currentState?.pushNamed(NavigationRoutes.createPost);
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
          pageBuilder: (_, __, ___) => CurrentUserProfileWidget.create(),
        );
      case NavigationRoutes.registration:
        return PageRouteBuilder(
            pageBuilder: (_, __, ___) => RegistrationWidget.create());
      case NavigationRoutes.users:
        return PageRouteBuilder(
            pageBuilder: (_, __, ___) => UsersWidget.create());
      case NavigationRoutes.post:
        return PageRouteBuilder(
            pageBuilder: (_, __, ___) =>
                PostWidget.create(postId: settings.arguments as String));
      case NavigationRoutes.createPost:
        return PageRouteBuilder(
            pageBuilder: (_, __, ___) => CreatePostWidget.create());
      default:
        return null;
    }
  }
}
