import 'package:dd_app_ui/data/services/auth_service.dart';
import 'package:dd_app_ui/ui/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class _RegistrationState {
  final String? name;
  final String? password;
  final String? email;
  final String? retryPassword;
  final String? errorMessage;
  final String? birthDate;

  _RegistrationState(
      {this.password,
      this.errorMessage,
      this.name,
      this.email,
      this.birthDate,
      this.retryPassword});

  _RegistrationState copyWith(
      {String? email,
      String? password,
      String? errorMessage,
      String? name,
      String? birthDate,
      String? retryPassword}) {
    return _RegistrationState(
      email: email ?? this.email,
      password: password ?? this.password,
      errorMessage: errorMessage,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      retryPassword: retryPassword ?? this.retryPassword,
    );
  }
}

class _RegistrationViewModel extends ChangeNotifier {
  var emailTec = TextEditingController();
  var passwordTec = TextEditingController();
  var nameTec = TextEditingController();
  var retryPasswordTec = TextEditingController();
  var birthDateTec = TextEditingController();
  final _authService = AuthService();

  var _state = _RegistrationState();
  _RegistrationState get state => _state;
  set state(_RegistrationState val) {
    _state = val;
    notifyListeners();
  }

  BuildContext context;
  _RegistrationViewModel({required this.context}) {
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
      state = state.copyWith(birthDate: birthDateTec.text);
    });
  }

  bool checkFields() {
    return ((state.email?.isNotEmpty ?? false) &&
        (state.password?.isNotEmpty ?? false) &&
        (state.retryPassword?.isNotEmpty ?? false) &&
        (state.name?.isNotEmpty ?? false) &&
        (state.birthDate?.isNotEmpty ?? false) &&
        DateTime.tryParse(state.birthDate!) != null);
  }

  void register() async {
    await _authService.createUser(
        name: state.name,
        email: state.email,
        password: state.password,
        retryPassword: state.retryPassword,
        birthDate: "${state.birthDate!}T00:00:00.000");

    AppNavigator.toAuth();
  }
}

class RegistrationWidget extends StatelessWidget {
  const RegistrationWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<_RegistrationViewModel>();

    return Scaffold(
        body: SafeArea(
            child: Center(
                child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                margin: const EdgeInsets.fromLTRB(
                                    0.0, 0.0, 0.0, 10.0),
                                alignment: Alignment.center,
                                child: TextField(
                                  keyboardType: TextInputType.emailAddress,
                                  controller: viewModel.emailTec,
                                  decoration: InputDecoration(
                                      errorText: viewModel.emailTec.text.isEmpty
                                          ? "This field is required"
                                          : null,
                                      border: const OutlineInputBorder(),
                                      hintText: "Enter login"),
                                  textAlign: TextAlign.start,
                                )),
                            Container(
                                margin: const EdgeInsets.fromLTRB(
                                    0.0, 0.0, 0.0, 10.0),
                                child: TextField(
                                  obscureText: true,
                                  controller: viewModel.passwordTec,
                                  decoration: InputDecoration(
                                      errorText:
                                          viewModel.passwordTec.text.isEmpty
                                              ? "This field is required"
                                              : null,
                                      border: const OutlineInputBorder(),
                                      hintText: "Enter password"),
                                )),
                            Container(
                                margin: const EdgeInsets.fromLTRB(
                                    0.0, 0.0, 0.0, 10.0),
                                alignment: Alignment.center,
                                child: TextField(
                                  obscureText: true,
                                  controller: viewModel.retryPasswordTec,
                                  decoration: InputDecoration(
                                      errorText: viewModel
                                              .retryPasswordTec.text.isEmpty
                                          ? "This field is required"
                                          : null,
                                      border: const OutlineInputBorder(),
                                      hintText: "Retry password"),
                                  textAlign: TextAlign.start,
                                )),
                            Container(
                                margin: const EdgeInsets.fromLTRB(
                                    0.0, 0.0, 0.0, 10.0),
                                alignment: Alignment.center,
                                child: TextField(
                                  keyboardType: TextInputType.name,
                                  controller: viewModel.nameTec,
                                  decoration: InputDecoration(
                                      errorText: viewModel.nameTec.text.isEmpty
                                          ? "This field is required"
                                          : null,
                                      border: const OutlineInputBorder(),
                                      hintText: "Enter name"),
                                  textAlign: TextAlign.start,
                                )),
                            Container(
                                margin: const EdgeInsets.fromLTRB(
                                    0.0, 0.0, 0.0, 10.0),
                                alignment: Alignment.center,
                                child: TextField(
                                  keyboardType: TextInputType.datetime,
                                  controller: viewModel.birthDateTec,
                                  decoration: InputDecoration(
                                      errorText: (viewModel
                                                  .birthDateTec.text.isEmpty ||
                                              DateTime.tryParse(viewModel
                                                      .birthDateTec.text) ==
                                                  null)
                                          ? "This field is required, use '-'"
                                          : null,
                                      border: const OutlineInputBorder(),
                                      hintText: "Enter your birh date 'y-m-d'"),
                                  textAlign: TextAlign.start,
                                )),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                      margin: const EdgeInsets.all(5),
                                      child: ElevatedButton(
                                        onPressed: viewModel.checkFields()
                                            ? viewModel.register
                                            : null,
                                        child: const Text("Register"),
                                      )),
                                  Container(
                                      margin: const EdgeInsets.all(5),
                                      child: ElevatedButton(
                                          onPressed: () =>
                                              AppNavigator.toAuth(),
                                          child: const Text("Go to login")))
                                ]),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (viewModel.state.errorMessage != null)
                                  Text(viewModel.state.errorMessage!),
                              ],
                            ),
                          ],
                        ))))));
  }

  static Widget create() => ChangeNotifierProvider<_RegistrationViewModel>(
        create: (context) => _RegistrationViewModel(context: context),
        lazy: false,
        child: const RegistrationWidget(),
      );
}
