import 'package:dd_app_ui/ui/app_navigator.dart';
import 'package:dd_app_ui/ui/roots/registration/registration_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class RegistrationWidget extends StatelessWidget {
  const RegistrationWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<RegistrationViewModel>();
    var dtf = DateFormat("dd.MM.yyyy");

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
                            createTextField("This field is required",
                                "Enter login", viewModel.emailTec),
                            createTextField("This field is required",
                                "Enter password", viewModel.passwordTec),
                            createTextField("This field is required",
                                "Retry password", viewModel.retryPasswordTec),
                            createTextField("This field is required",
                                "Enter name", viewModel.nameTec),
                            Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 10.0,
                                children: [
                                  Text(dtf
                                      .format(DateTime.parse(
                                          viewModel.birthDateTec.text))
                                      .toString()),
                                  ElevatedButton(
                                    onPressed: () {
                                      viewModel.selectDate(context);
                                    },
                                    child: const Text("Select date"),
                                  ),
                                ]),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  createElevatedButton(
                                      "Register",
                                      viewModel.checkFields,
                                      viewModel.register),
                                  createElevatedButton(
                                      "Log in", null, AppNavigator.toAuth),
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

  Widget createTextField(
          String errorText, String hintText, TextEditingController tec) =>
      Container(
          margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
          alignment: Alignment.center,
          child: TextField(
            keyboardType: TextInputType.emailAddress,
            controller: tec,
            decoration: InputDecoration(
                errorText: tec.text.isEmpty ? "This field is required" : null,
                border: const OutlineInputBorder(),
                hintText: "Enter login"),
            textAlign: TextAlign.start,
          ));

  Widget createElevatedButton(
          String text, bool Function()? check, void Function() func) =>
      Container(
          margin: const EdgeInsets.all(5.0),
          child: check != null
              ? ElevatedButton(
                  onPressed: check() ? func : null,
                  child: Text(text),
                )
              : ElevatedButton(
                  onPressed: () => func(),
                  child: Text(text),
                ));

  static Widget create() => ChangeNotifierProvider<RegistrationViewModel>(
        create: (context) => RegistrationViewModel(context: context),
        lazy: false,
        child: const RegistrationWidget(),
      );
}
