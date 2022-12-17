import 'package:dd_app_ui/data/services/auth_service.dart';
import 'package:dd_app_ui/exceptions/nonetwork_exception.dart';
import 'package:dd_app_ui/exceptions/wrong_credential_exception.dart';
import 'package:dd_app_ui/ui/app_navigator.dart';
import 'package:flutter/material.dart';

class AuthState {
  final String? password;
  final String? login;
  final String? errorMessage;

  AuthState({this.password, this.login, this.errorMessage});

  AuthState copyWith({String? login, String? password, String? errorMessage}) {
    return AuthState(
      login: login ?? this.login,
      password: password ?? this.password,
      errorMessage: errorMessage,
    );
  }
}

class AuthViewModel extends ChangeNotifier {
  var loginTec = TextEditingController();
  var passwordTec = TextEditingController();
  final _authService = AuthService();

  var _state = AuthState();
  AuthState get state => _state;
  set state(AuthState val) {
    _state = val;
    notifyListeners();
  }

  BuildContext context;
  AuthViewModel({required this.context}) {
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
