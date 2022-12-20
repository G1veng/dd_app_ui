import 'package:dd_app_ui/data/services/auth_service.dart';
import 'package:dd_app_ui/ui/app_navigator.dart';
import 'package:flutter/material.dart';

class RegistrationState {
  final String? name;
  final String? password;
  final String? email;
  final String? retryPassword;
  final String? errorMessage;
  final DateTime? birthDate;

  RegistrationState(
      {this.birthDate,
      this.password,
      this.errorMessage,
      this.name,
      this.email,
      this.retryPassword});

  RegistrationState copyWith(
      {String? email,
      String? password,
      String? errorMessage,
      String? name,
      DateTime? birthDate,
      String? retryPassword}) {
    return RegistrationState(
      email: email ?? this.email,
      password: password ?? this.password,
      errorMessage: errorMessage,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      retryPassword: retryPassword ?? this.retryPassword,
    );
  }
}

class RegistrationViewModel extends ChangeNotifier {
  var emailTec = TextEditingController();
  var passwordTec = TextEditingController();
  var nameTec = TextEditingController();
  var retryPasswordTec = TextEditingController();
  var birthDateTec = TextEditingController();
  final _authService = AuthService();

  var _state = RegistrationState();
  RegistrationState get state => _state;
  set state(RegistrationState val) {
    _state = val;
    notifyListeners();
  }

  BuildContext context;
  RegistrationViewModel({required this.context}) {
    birthDateTec.text = DateTime.now().toString();

    emailTec.addListener(() {
      state = state.copyWith(email: emailTec.text);
    });
    passwordTec.addListener(() {
      state = state.copyWith(password: passwordTec.text);
    });
    retryPasswordTec.addListener(() {
      state = state.copyWith(retryPassword: retryPasswordTec.text);
    });
    nameTec.addListener(() {
      state = state.copyWith(name: nameTec.text);
    });
    birthDateTec.addListener(() {
      state = state.copyWith(birthDate: DateTime.parse(birthDateTec.text));
    });
    state = state.copyWith(birthDate: DateTime.parse(birthDateTec.text));
  }

  bool checkFields() {
    return ((state.email?.isNotEmpty ?? false) &&
        (state.password?.isNotEmpty ?? false) &&
        (state.retryPassword?.isNotEmpty ?? false) &&
        (state.name?.isNotEmpty ?? false));
  }

  void register() async {
    var r = state.birthDate.toString();

    await _authService.createUser(
        name: state.name,
        email: state.email,
        password: state.password,
        retryPassword: state.retryPassword,
        birthDate: state.birthDate.toString().replaceAll(r" ", "T"));

    AppNavigator.toAuth();
  }

  void selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: state.birthDate!,
      firstDate: DateTime(1922),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != state.birthDate) {
      birthDateTec.text = picked.toString();
      state = state.copyWith(birthDate: picked);
    }
  }
}
