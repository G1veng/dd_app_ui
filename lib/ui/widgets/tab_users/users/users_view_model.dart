import 'package:dd_app_ui/data/services/api_service.dart';
import 'package:dd_app_ui/domain/models/user.dart';
import 'package:dd_app_ui/internal/config/app_config.dart';
import 'package:dd_app_ui/internal/config/shared_prefs.dart';
import 'package:dd_app_ui/internal/config/token_storage.dart';
import 'package:flutter/material.dart';
import 'package:dd_app_ui/data/services/data_service.dart';

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

class UsersViewModel extends ChangeNotifier {
  var _state = _UsersState();
  final _api = ApiService();
  final _dataService = DataService();
  final BuildContext context;
  int take = 10;
  int skip = 0;

  UsersViewModel({required this.context}) {
    _asyncInit();
  }

  _UsersState get state => _state;
  set state(_UsersState val) {
    _state = val;
    notifyListeners();
  }

  Future _asyncInit() async {
    Iterable<User>? dbUsers;
    state = state.copyWith(isLoading: true);
    var users = await _api.getUsers();
    var currentUser = await SharedPrefs.getStoredUser();

    if (users != null && currentUser != null) {
      for (var user in users) {
        await _dataService.cuUser(
          User(
              id: user.id!,
              name: user.name!,
              email: user.email!,
              birthDate: user.birthDate!,
              avatar: user.avatar),
        );
      }

      dbUsers = (await _dataService.getUsers(
              orderBy: '[Name] DESC',
              notEqual: true,
              id: currentUser.id,
              take: 8,
              skip: 0))!
          .toList();
    }

    var headers = await TokenStorage.getAccessToken();
    if (headers != null) {
      state = state.copyWith(headers: headers);
    }

    if (dbUsers != null && currentUser != null) {
      state = state.copyWith(users: dbUsers);

      createUsersWidgets();
    }

    if (dbUsers != null) {
      state = state.copyWith(isLoading: false);
    }
  }

  void pressedGoToProfile(String userId) {}
  //TODO добавить обработчик перехода в пользовательский профиль

  void createUsersWidgets() {
    var users = state.users;
    var usersWidgets = state.usersWidgets ?? [];
    int startIndex;

    if (users == null) {
      return;
    }

    startIndex = usersWidgets.length;

    for (int i = startIndex; i < users.length; i++) {
      usersWidgets.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            users[i].avatar != null
                ? Container(
                    margin: const EdgeInsets.all(2.0),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(
                        "$baseUrl${users[i].avatar}",
                        headers: state.headers,
                      ),
                      radius: (MediaQuery.of(context).size.width / 15),
                    ))
                : Container(
                    margin: const EdgeInsets.all(2.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.grey,
                      radius: (MediaQuery.of(context).size.width / 15),
                    )),
            Container(
                margin: const EdgeInsets.fromLTRB(4.0, 0, 0, 0),
                child: Text(
                  users[i].name,
                  overflow: TextOverflow.ellipsis,
                ))
          ]),
          Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 2.0, 0),
              child: ElevatedButton(
                onPressed: () => pressedGoToProfile(users[i].id),
                child: const Text("Profile"),
              )),
        ],
      ));
    }

    state = state.copyWith(usersWidgets: usersWidgets);
  }
}
