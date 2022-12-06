import 'package:dd_app_ui/data/services/auth_service.dart';
import 'package:dd_app_ui/exceptions/nonetwork_exception.dart';
import 'package:dd_app_ui/exceptions/wrong_credential_exception.dart';
import 'package:dd_app_ui/ui/app_navigator.dart';
import 'package:dd_app_ui/ui/icons_images/icons_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class _ViewModelState {
  final String? password;
  final String? login;
  final String? errorMessage;

  _ViewModelState({this.password, this.login, this.errorMessage});

  _ViewModelState copyWith(
      {String? login, String? password, String? errorMessage}) {
    return _ViewModelState(
      login: login ?? this.login,
      password: password ?? this.password,
      errorMessage: errorMessage,
    );
  }
}

class _ViewModel extends ChangeNotifier {
  var loginTec = TextEditingController();
  var passwordTec = TextEditingController();
  final _authService = AuthService();

  var _state = _ViewModelState();
  _ViewModelState get state => _state;
  set state(_ViewModelState val) {
    _state = val;
    notifyListeners();
  }

  BuildContext context;
  _ViewModel({required this.context}) {
    loginTec.addListener(() {
      state = state.copyWith(login: loginTec.text);
    });
    passwordTec.addListener(() {
      state = state.copyWith(password: passwordTec.text);
    });
  }

  bool checkFields() {
    return (state.login?.isNotEmpty ?? false) &&
        (state.password?.isNotEmpty ?? false);
  }

  void login() async {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }

    try {
      await _authService
          .auth(state.login, state.password)
          .then((value) => AppNavigator.toLoader());
    } on NoNetworkException {
      state = state.copyWith(errorMessage: "No network");
    } on WrongCredentionalException {
      state = state.copyWith(errorMessage: "Wrong login or password");
    }
  }
}

class AuthWidget extends StatelessWidget {
  const AuthWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<_ViewModel>();

    return Scaffold(
        body: Center(
            child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                        alignment: Alignment.center,
                        child: TextField(
                          controller: viewModel.loginTec,
                          decoration: InputDecoration(
                              errorText: viewModel.loginTec.text.isEmpty
                                  ? "This field is required"
                                  : null,
                              border: const OutlineInputBorder(),
                              hintText: "Enter login"),
                          textAlign: TextAlign.start,
                        )),
                    Container(
                        margin: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                        child: TextField(
                          obscureText: true,
                          controller: viewModel.passwordTec,
                          decoration: InputDecoration(
                              errorText: viewModel.passwordTec.text.isEmpty
                                  ? "This field is required"
                                  : null,
                              border: const OutlineInputBorder(),
                              hintText: "Enter password"),
                        )),
                    ElevatedButton(
                      onPressed:
                          viewModel.checkFields() ? viewModel.login : null,
                      child: const Text("Login"),
                    ),
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

  Widget create() => ChangeNotifierProvider<_ViewModel>(
        create: (context) => _ViewModel(context: context),
        lazy: false,
        child: const AuthWidget(),
      );
}
