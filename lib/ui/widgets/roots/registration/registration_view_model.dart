import 'package:dd_app_ui/data/services/auth_service.dart';
import 'package:dd_app_ui/data/services/data_service.dart';
import 'package:dd_app_ui/domain/models/user.dart';
import 'package:dd_app_ui/domain/exceptions/user_exists_excetion.dart';
import 'package:dd_app_ui/ui/navigation/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class RegistrationState {
  final String? name;
  final String? password;
  final String? email;
  final String? retryPassword;
  final String? errorMessage;
  final DateTime? birthDate;

  RegistrationState({
    this.birthDate,
    this.password,
    this.errorMessage,
    this.name,
    this.email,
    this.retryPassword,
  });

  RegistrationState copyWith({
    String? email,
    String? password,
    String? errorMessage,
    String? name,
    DateTime? birthDate,
    String? retryPassword,
  }) {
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
  final _dataService = DataService();

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
      state = state.copyWith(email: emailTec.text, errorMessage: null);
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
    String userId = const Uuid().v4().toString();
    String created = DateTime.now().toUtc().toString();

    try {
      await _authService.createUser(
        id: userId,
        name: state.name,
        email: state.email,
        password: state.password,
        retryPassword: state.retryPassword,
        birthDate: state.birthDate.toString().replaceAll(r" ", "T"),
        created: created.toString().replaceAll(r" ", "T"),
      );
    } on UserExistsException {
      state =
          state.copyWith(errorMessage: "User already exists try other login");
      return;
    }

    await _dataService.cuUser(User(
      avatar: null,
      id: userId,
      name: state.name!,
      email: state.email!,
      birthDate: state.birthDate!,
    ));

    AppNavigator.toAuth();
  }

  void selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: state.birthDate!,
      firstDate: DateTime(DateTime.now().year - 120),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != state.birthDate) {
      birthDateTec.text = picked.toString();
      state = state.copyWith(birthDate: picked);
    }
  }
}
