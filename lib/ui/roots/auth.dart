import 'package:dd_app_ui/data/auth_service.dart';
import 'package:dd_app_ui/ui/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class _ViewModelState {
  final String? password;
  final String? login;

  _ViewModelState({this.password, this.login});

  _ViewModelState copyWith({String? login, String? password}) {
    return _ViewModelState(
      login: login ?? this.login,
      password: password ?? this.password,
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
    await _authService
        .auth(state.login, state.password)
        .then((value) => AppNavigator.toLoader());
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
                    TextField(
                      controller: viewModel.loginTec,
                      decoration:
                          const InputDecoration(hintText: "Enter login"),
                    ),
                    TextField(
                      obscureText: true,
                      controller: viewModel.passwordTec,
                      decoration:
                          const InputDecoration(hintText: "Enter password"),
                    ),
                    ElevatedButton(
                      onPressed:
                          viewModel.checkFields() ? viewModel.login : null,
                      child: const Text("Login"),
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
