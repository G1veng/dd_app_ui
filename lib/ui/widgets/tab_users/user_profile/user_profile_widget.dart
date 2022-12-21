import 'package:dd_app_ui/ui/widgets/tab_users/user_profile/user_profile_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OtherUserProfileWidget extends StatelessWidget {
  const OtherUserProfileWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }

  static Widget create() => ChangeNotifierProvider<OtherUserProfileViewModel>(
        create: (context) => OtherUserProfileViewModel(context: context),
        lazy: false,
        child: const OtherUserProfileWidget(),
      );
}
