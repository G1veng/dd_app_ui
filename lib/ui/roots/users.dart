import 'package:dd_app_ui/data/services/api_service.dart';
import 'package:dd_app_ui/domain/models/user.dart';
import 'package:dd_app_ui/internal/config/app_config.dart';
import 'package:dd_app_ui/internal/config/shared_prefs.dart';
import 'package:dd_app_ui/internal/config/token_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class _UsersState {
  final List<User>? users;
  final Map<String, String>? headers;
  final List<Row>? usersWidgets;
  final bool? isLoading;

  _UsersState({this.users, this.usersWidgets, this.headers, this.isLoading});

  _UsersState copyWith({users, usersWidgets, headers, isLoading}) {
    List<User>? addedUsers;
    List<Row>? addedUserWidgets;

    if (this.users != null && users != null) {
      addedUsers = this.users;

      addedUsers!.addAll(users);

      users = addedUsers;
    }

    if (this.usersWidgets != null && usersWidgets != null) {
      addedUserWidgets = this.usersWidgets;

      addedUserWidgets!.addAll(usersWidgets);

      usersWidgets = addedUserWidgets;
    }

    return _UsersState(
      users: users ?? this.users,
      usersWidgets: usersWidgets ?? this.usersWidgets,
      headers:
          headers != null ? {"Authorization": "Bearer $headers"} : this.headers,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class _UsersViewModel extends ChangeNotifier {
  var _state = _UsersState();
  final _api = ApiService();
  final BuildContext context;
  int take = 10;
  int skip = 0;

  _UsersViewModel({required this.context}) {
    _asyncInit();
  }

  _UsersState get state => _state;
  set state(_UsersState val) {
    _state = val;
    notifyListeners();
  }

  Future _asyncInit() async {
    state = state.copyWith(isLoading: true);
    var users = await _api.getUsers();
    var currentUser = await SharedPrefs.getStoredUser();
    var headers = await TokenStorage.getAccessToken();

    if (users != null && currentUser != null) {
      users.remove(currentUser);

      state = state.copyWith(users: users);

      createUsersWidgets();
    }

    if (headers != null) {
      state = state.copyWith(headers: headers);
    }

    if (headers != null || users != null) {
      state = state.copyWith(isLoading: false);
    }
  }

  void pressedGoToProfile(String userId) {
    var some = userId;
  }

  void createUsersWidgets() {
    var users = state.users;
    var usersWidgets = state.usersWidgets ?? [];
    int startIndex;

    if (users == null) {
      return;
    }

    startIndex = usersWidgets.length;

    for (int i = startIndex; i < users.length; i++) {
      usersWidgets.add(Row(children: [
        users[i].avatar == ""
            ? CircleAvatar(
                backgroundImage: NetworkImage(
                  "$baseUrl${users[i].avatar}",
                  headers: state.headers,
                ),
              )
            : const CircleAvatar(
                backgroundColor: Colors.grey,
              ),
        Text(users[i].name),
        ElevatedButton(
          onPressed: () => pressedGoToProfile(users[i].id),
          child: const Text("Profile"),
        ),
      ]));
    }

    state = state.copyWith(usersWidgets: usersWidgets);
  }
}

class UsersWidget extends StatelessWidget {
  const UsersWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _portraitModeOnly();
    var viewModel = context.watch<_UsersViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("NotInstagram"),
        leading: viewModel.state.isLoading!
            ? const CircularProgressIndicator(
                color: Colors.red,
              )
            : null,
      ),
      body: Column(
          children: viewModel.state.usersWidgets ??
              [
                const Text(
                  "Users not found",
                  textAlign: TextAlign.center,
                )
              ]),
    );
  }

  void _portraitModeOnly() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  static Widget create() => ChangeNotifierProvider<_UsersViewModel>(
        create: (context) => _UsersViewModel(context: context),
        lazy: false,
        child: const UsersWidget(),
      );
}
