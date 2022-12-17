import 'package:dd_app_ui/data/services/auth_service.dart';
import 'package:dd_app_ui/ui/app_navigator.dart';
import 'package:flutter/material.dart';

class LoaderModel extends ChangeNotifier {
  BuildContext context;
  final _authService = AuthService();

  LoaderModel({required this.context}) {
    _asyncInit();
  }

  Future _asyncInit() async {
    if (await _authService.checkAuth()) {
      AppNavigator.toHome();
    } else {
      AppNavigator.toAuth();
    }
  }
}
