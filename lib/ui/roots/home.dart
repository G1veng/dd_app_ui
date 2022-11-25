import 'package:dd_app_ui/data/auth_service.dart';
import 'package:dd_app_ui/ui/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class _HomeSate {
  final int counter;

  _HomeSate({this.counter = 0});

  _HomeSate copyWith({int counter = 0}) {
    return _HomeSate(counter: counter);
  }
}

class _ViewModel extends ChangeNotifier {
  var _state = _HomeSate();
  final _authService = AuthService();

  _HomeSate get state => _state;
  set state(_HomeSate val) {
    _state = val;
    notifyListeners();
  }

  void increment() {
    var innerState = state;

    state = state.copyWith(counter: (innerState.counter + 1));
  }

  int getCounter() {
    return state.counter;
  }

  void logout() async {
    await _authService.logout();
    AppNavigator.toLoader();
  }
}

class HomeWidget extends StatelessWidget {
  final String title;

  const HomeWidget({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<_ViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: viewModel.logout,
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(title),
            Text(viewModel.getCounter().toString()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: viewModel.increment,
        tooltip: 'Increment',
        child: const Icon(Icons.access_alarm_sharp),
      ),
    );
  }

  static Widget create(String title) => ChangeNotifierProvider<_ViewModel>(
        create: (context) => _ViewModel(),
        lazy: false,
        child: HomeWidget(title: title),
      );
}
