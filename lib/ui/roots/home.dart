import 'package:dd_app_ui/domain/models/user.dart';
import 'package:dd_app_ui/internal/config/shared_prefs.dart';
import 'package:dd_app_ui/internal/config/token_storage.dart';
import 'package:dd_app_ui/ui/app_navigator.dart';
import 'package:dd_app_ui/ui/icons_images/icons_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class _HomeSate {
  final int counter;
  final bool isRuning;
  final User? user;
  final int currentPageIndex;

  _HomeSate(
      {this.counter = 0,
      this.isRuning = false,
      this.user,
      this.currentPageIndex = 0});

  _HomeSate copyWith({
    counter = 0,
    isRuning,
    user,
    currentPageIndex = 0,
  }) {
    return _HomeSate(
      counter: counter ?? this.counter,
      isRuning: isRuning ?? this.isRuning,
      user: user ?? this.user,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
    );
  }
}

class _ViewModel extends ChangeNotifier {
  var _state = _HomeSate();
  Map<String, String>? headers;

  _ViewModel() {
    _asyncInit();
  }

  _HomeSate get state => _state;
  set state(_HomeSate val) {
    _state = val;
    notifyListeners();
  }

  void _asyncInit() async {
    var user = await SharedPrefs.getStoredUser();
    var token = await TokenStorage.getAccessToken();

    if (user != null) {
      state = state.copyWith(user: user);
    }

    if (token != null) {
      headers = {"Authorization": "Bearer $token"};
    }
  }
}

class HomeWidget extends StatelessWidget {
  const HomeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "NotInstagram",
        ),
      ),
      body: Column(),
      bottomNavigationBar: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.09,
          child: Column(children: [
            const Divider(
              color: Colors.grey,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    width: MediaQuery.of(context).size.width / 2,
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(MyIcons.home),
                    )),
                SizedBox(
                    width: MediaQuery.of(context).size.width / 2,
                    child: IconButton(
                        onPressed: () => AppNavigator.toUserProfile(),
                        icon: const Icon(MyIcons.userOutline))),
              ],
            ),
          ])),
    );
  }

  static Widget create() => ChangeNotifierProvider<_ViewModel>(
        create: (context) => _ViewModel(),
        lazy: false,
        child: const HomeWidget(),
      );
}
