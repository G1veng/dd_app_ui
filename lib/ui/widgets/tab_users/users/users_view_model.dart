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
  final bool? isUpdating;

  UsersState(
      {this.users, this.headers, this.isLoading, this.isUpdating = false});

  UsersState copyWith({users, usersWidgets, headers, isLoading, isUpdating}) {
    return UsersState(
      users: users ?? this.users,
      headers:
          headers != null ? {"Authorization": "Bearer $headers"} : this.headers,
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }
}

class UsersViewModel extends ChangeNotifier {
  var _state = UsersState();
  final _syncService = SyncService();
  final _dataService = DataService();
  final BuildContext context;
  final lvc = ScrollController();
  int take = 10;
  int skip = 0;

  UsersViewModel({required this.context}) {
    _asyncInit();

    lvc.addListener(() async {
      var max = lvc.position.maxScrollExtent;
      var current = lvc.offset;
      var percent = (current / max * 100);
      if (percent > 80) {
        if (!state.isUpdating!) {
          _startDelayAsync();
          await _requestNextUsers();
        }
      }
    });
  }

  UsersState get state => _state;
  set state(UsersState val) {
    _state = val;
    notifyListeners();
  }

  Future pressedGoToProfile(String userId) async {
    return await Navigator.of(context)
        .pushNamed(TabNavigatorRoutes.userProfile, arguments: userId);
  }

  Future _asyncInit() async {
    state = state.copyWith(isLoading: true);
    var headers = await TokenStorage.getAccessToken();

    await _requestNextUsers();

    state = state.copyWith(isLoading: false, headers: headers);
  }

  Future _requestNextUsers() async {
    await _syncService.syncUsers(take, skip: skip);
    var users = await _dataService.getUsers(take: take, skip: skip);

    if (users != null) {
      var expUsers = state.users ?? [];
      expUsers.addAll(users);

      state = state.copyWith(users: expUsers);

      skip += take;
    }
  }

  Future _startDelayAsync({int duration = 1}) async {
    state = state.copyWith(isUpdating: true);
    await Future.delayed(Duration(seconds: duration));
    state = state.copyWith(isUpdating: false);
  }
}
