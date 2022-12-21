import 'package:dd_app_ui/ui/widgets/tab_users/users/users_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class UsersWidget extends StatelessWidget {
  const UsersWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _portraitModeOnly();
    var viewModel = context.watch<UsersViewModel>();

    return Scaffold(
      body: SafeArea(
          child: Column(
              children: viewModel.state.usersWidgets ??
                  [
                    const Center(
                        child: CircularProgressIndicator(
                      color: Colors.blue,
                    )),
                  ])),
    );
  }

  void _portraitModeOnly() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  static Widget create() => ChangeNotifierProvider<UsersViewModel>(
        create: (context) => UsersViewModel(context: context),
        lazy: false,
        child: const UsersWidget(),
      );
}
