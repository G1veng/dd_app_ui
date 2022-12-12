import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class _OtherUserProfileState {}

class _OtherUserProfileViewModel extends ChangeNotifier {
  BuildContext context;

  _OtherUserProfileViewModel({required this.context});
}

class OtherUserProfileWidget extends StatelessWidget {
  const OtherUserProfileWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }

  static Widget create() => ChangeNotifierProvider<_OtherUserProfileViewModel>(
        create: (context) => _OtherUserProfileViewModel(context: context),
        lazy: false,
        child: const OtherUserProfileWidget(),
      );
}
