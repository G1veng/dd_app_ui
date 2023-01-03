import 'package:dd_app_ui/internal/config/app_config.dart';
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
          child: viewModel.state.isLoading == true
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  itemBuilder: (context, index) {
                    return Container(
                        margin: const EdgeInsets.only(right: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _createUserInfo(context, index),
                            _createProfileButton(context, index),
                          ],
                        ));
                  },
                  separatorBuilder: (context, index) => const Divider(),
                  itemCount: viewModel.state.users == null
                      ? 0
                      : viewModel.state.users!.length)),
    );
  }

  static Widget create() => ChangeNotifierProvider<UsersViewModel>(
        create: (context) => UsersViewModel(context: context),
        lazy: false,
        child: const UsersWidget(),
      );

  void _portraitModeOnly() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Widget _createUserInfo(BuildContext context, int index) {
    var viewModel = context.watch<UsersViewModel>();

    return Expanded(
        child: Row(
      children: [
        Container(
            margin: const EdgeInsets.fromLTRB(5, 2, 5, 0),
            child: CircleAvatar(
              backgroundColor: Colors.grey,
              foregroundImage: viewModel.state.users![index].avatar != null
                  ? Image.network(
                      "$baseUrl${viewModel.state.users![index].avatar}",
                      headers: viewModel.state.headers,
                    ).image
                  : Image.asset(
                      "images/empty_image.png",
                    ).image,
              radius: MediaQuery.of(context).size.width / 12,
            )),
        Flexible(
            child: Text(
          viewModel.state.users![index].name,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        )),
      ],
    ));
  }

  Widget _createProfileButton(BuildContext context, int index) {
    var viewModel = context.watch<UsersViewModel>();

    return ElevatedButton(
        onPressed: () =>
            viewModel.pressedGoToProfile(viewModel.state.users![index].id),
        child: const Text("Profile"));
  }
}
