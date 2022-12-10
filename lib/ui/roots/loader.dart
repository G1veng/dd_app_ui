import 'package:dd_app_ui/data/services/auth_service.dart';
import 'package:dd_app_ui/ui/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class _LoaderModel extends ChangeNotifier {
  BuildContext context;
  final _authService = AuthService();

  _LoaderModel({required this.context}) {
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

class LoaderWidget extends StatelessWidget {
  const LoaderWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _portraitModeOnly();

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void _portraitModeOnly() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  static Widget create() => ChangeNotifierProvider<_LoaderModel>(
        create: (context) => _LoaderModel(context: context),
        lazy: false,
        child: const LoaderWidget(),
      );
}
