import 'package:dd_app_ui/data/services/auth_service.dart';
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
  final _authService = AuthService();
  Map<String, String>? headers;

  _ViewModel() {
    asyncInit();
  }

  _HomeSate get state => _state;
  set state(_HomeSate val) {
    _state = val;
    notifyListeners();
  }

  void increment() {
    var innerState = state;

    state = state.copyWith(
        counter: (innerState.counter + 1),
        isRuning: state.isRuning == false ? true : false);
  }

  int getCounter() {
    return state.counter;
  }

  void logout() async {
    await _authService.logout();
    AppNavigator.toLoader();
  }

  IconData getIcon() {
    if (state.isRuning == true) {
      return Icons.accessible_forward_sharp;
    } else {
      return Icons.accessible_outlined;
    }
  }

  void asyncInit() async {
    var user = await SharedPrefs.getStoredUser();
    var token = await TokenStorage.getAccessToken();

    if (user != null) {
      state = state.copyWith(user: user);
    }

    if (token != null) {
      headers = {"Authorization": "Bearer $token"};
    }
  }

  void changeActivePage(int currentPageIndex) {
    switch (currentPageIndex) {
      case 1:
        AppNavigator.toUserProfile();
        break;
      default:
        break;
    }
  }
}

class HomeWidget extends StatelessWidget {
  const HomeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<_ViewModel>();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Instagram",
        ),
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) => viewModel.changeActivePage(index),
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(MyIcons.home),
            label: '',
            tooltip: 'Home',
          ),
          NavigationDestination(
            icon: Icon(MyIcons.userOutline),
            label: '',
            tooltip: 'Profile',
          ),
        ],
      ),
    );
  }

  static Widget create() => ChangeNotifierProvider<_ViewModel>(
        create: (context) => _ViewModel(),
        lazy: false,
        child: const HomeWidget(),
      );
}
