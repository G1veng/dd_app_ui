import 'package:dd_app_ui/data/services/sync_service.dart';
import 'package:dd_app_ui/domain/models/user.dart';
import 'package:dd_app_ui/internal/config/token_storage.dart';
import 'package:dd_app_ui/ui/navigation/tab_navigator.dart';
import 'package:flutter/material.dart';
import 'package:dd_app_ui/data/services/data_service.dart';

class UsersState {
  final List<User>? users;
  final Map<String, String>? headers;
  final bool? isLoading;

  UsersState({this.users, this.headers, this.isLoading});

  UsersState copyWith({users, usersWidgets, headers, isLoading}) {
    return UsersState(
      users: users ?? this.users,
      headers:
          headers != null ? {"Authorization": "Bearer $headers"} : this.headers,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class UsersViewModel extends ChangeNotifier {
  var _state = UsersState();
  final _syncService = SyncService();
  final _dataService = DataService();
  final BuildContext context;
  int take = 10;
  int skip = 0;

  UsersViewModel({required this.context}) {
    _asyncInit();
  }

  UsersState get state => _state;
  set state(UsersState val) {
    _state = val;
    notifyListeners();
  }

  Future _asyncInit() async {
    state = state.copyWith(isLoading: true);
    var headers = await TokenStorage.getAccessToken();

    await _syncService.syncUsers(take, skip: skip);
    var users = await _dataService.getUsers(take: take, skip: skip);

    if (users != null) {
      var expUsers = state.users ?? [];
      expUsers.addAll(users);

      state = state.copyWith(users: expUsers);
    }

    state = state.copyWith(isLoading: false, headers: headers);
  }

  Future pressedGoToProfile(String userId) async {
    return await Navigator.of(context)
        .pushNamed(TabNavigatorRoutes.userProfile, arguments: userId);
  }
}
