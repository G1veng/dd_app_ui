import 'package:dd_app_ui/ui/app_navigator.dart';
import 'package:dd_app_ui/ui/icons_images/icons_icons.dart';
import 'package:dd_app_ui/ui/roots/auth/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthWidget extends StatelessWidget {
  const AuthWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<AuthViewModel>();

    return Scaffold(
        body: Center(
            child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    createTextField("This field is required", "Enter login",
                        viewModel.loginTec),
                    createTextField("This field is required", "Enter password",
                        viewModel.passwordTec,
                        isObscureText: true),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      createElevatedButton(
                          "Sign in", viewModel.checkFields, viewModel.login),
                      createElevatedButton(
                          "Register", null, AppNavigator.toRegistration),
                    ]),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (viewModel.state.errorMessage != null)
                          const Icon(MyIcons.emoUnhappy),
                        if (viewModel.state.errorMessage == null)
                          const Icon(MyIcons.emoHappy),
                        if (viewModel.state.errorMessage != null)
                          Text(viewModel.state.errorMessage!),
                      ],
                    ),
                  ],
                ))));
  }

  Widget createTextField(
          String errorText, String hintText, TextEditingController tec,
          {bool isObscureText = false}) =>
      Container(
          margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
          alignment: Alignment.center,
          child: TextField(
            obscureText: isObscureText,
            controller: tec,
            decoration: InputDecoration(
                errorText: tec.text.isEmpty ? errorText : null,
                border: const OutlineInputBorder(),
                hintText: hintText),
            textAlign: TextAlign.start,
          ));

  Widget createElevatedButton(
          String text, bool Function()? check, void Function() goTo) =>
      Container(
          margin: const EdgeInsets.all(5.0),
          child: check != null
              ? ElevatedButton(
                  onPressed: check() ? goTo : null,
                  child: Text(text),
                )
              : ElevatedButton(
                  onPressed: () => goTo(),
                  child: Text(text),
                ));

  Widget create() => ChangeNotifierProvider<AuthViewModel>(
        create: (context) => AuthViewModel(context: context),
        lazy: false,
        child: const AuthWidget(),
      );
}
