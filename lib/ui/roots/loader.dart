import 'package:dd_app_ui/data/services/auth_service.dart';
import 'package:dd_app_ui/ui/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class _VoewModel extends ChangeNotifier {
  BuildContext context;
  final _authService = AuthService();

  _VoewModel({required this.context}) {
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
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  static Widget create() => ChangeNotifierProvider<_VoewModel>(
        create: (context) => _VoewModel(context: context),
        lazy: false,
        child: const LoaderWidget(),
      );
}
