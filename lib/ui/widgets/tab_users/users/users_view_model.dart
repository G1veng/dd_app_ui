import 'package:dd_app_ui/data/services/api_service.dart';
import 'package:dd_app_ui/data/services/sync_service.dart';
import 'package:dd_app_ui/domain/enums/db_query.dart';
import 'package:dd_app_ui/domain/models/subscription.dart';
import 'package:dd_app_ui/domain/models/user.dart';
import 'package:dd_app_ui/internal/config/shared_prefs.dart';
import 'package:dd_app_ui/internal/config/token_storage.dart';
import 'package:dd_app_ui/ui/navigation/tab_navigator.dart';
import 'package:flutter/material.dart';
import 'package:dd_app_ui/data/services/data_service.dart';

class UsersState {
  final List<User>? users;
  final List<bool>? isFollowed;
  final Map<String, String>? headers;
  final bool? isLoading;
  final bool? isUpdating;

  UsersState({
    this.users,
    this.headers,
    this.isLoading,
    this.isUpdating = false,
    this.isFollowed,
  });

  UsersState copyWith(
      {users, usersWidgets, headers, isLoading, isUpdating, isFollowed}) {
    return UsersState(
      users: users ?? this.users,
      headers:
          headers != null ? {"Authorization": "Bearer $headers"} : this.headers,
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      isFollowed: isFollowed ?? this.isFollowed,
    );
  }

  UsersState clear() => UsersState(
      users: null,
      headers: headers,
      isFollowed: null,
      isLoading: false,
      isUpdating: false);
}

class UsersViewModel extends ChangeNotifier {
  var _state = UsersState();
  final _syncService = SyncService();
  final _dataService = DataService();
  final _apiService = ApiService();
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

  Future refresh() async {
    state = state.clear();
    skip = 0;

    _asyncInit();
  }

  Future _asyncInit() async {
    state = state.copyWith(isLoading: true);
    var headers = await TokenStorage.getAccessToken();

    await _requestNextUsers();

    state = state.copyWith(isLoading: false, headers: headers);
  }

  Future _requestNextUsers() async {
    await _syncService.syncUsers(take, skip: skip);
    var users = await _dataService.getUsers(
      take: take,
      skip: skip,
      where: {"id": (await SharedPrefs.getStoredUser())!.id},
      conds: [DbQueryEnum.notEqual],
    );

    if (users != null) {
      var expUsers = state.users ?? [];
      var expIsFollowed = state.isFollowed ?? [];

      for (var user in users) {
        expIsFollowed.add((await _apiService.isSubscribedOn(userId: user.id)));
      }

      expUsers.addAll(users);

      state = state.copyWith(
        users: expUsers,
        isFollowed: expIsFollowed,
      );

      skip += take;
    }
  }

  Future _startDelayAsync({int duration = 1}) async {
    state = state.copyWith(isUpdating: true);
    await Future.delayed(Duration(seconds: duration));
    state = state.copyWith(isUpdating: false);
  }

  Future changeSubscriptionStatePressed(int index) async {
    await _apiService.changeSubscriptionStateOnUser(
        userId: state.users![index].id);

    var isFollowed = state.isFollowed;
    var subscription = Subscription(
        id: state.users![index].id,
        subscriberId: (await SharedPrefs.getStoredUser())!.id);

    if (isFollowed![index] == true) {
      await _dataService.delSubscription(subscription: subscription);
    } else {
      await _dataService.cuSubscription(subscription);
    }
    isFollowed[index] = isFollowed[index] == true ? false : true;

    state = state.copyWith(isFollowed: isFollowed);
  }
}
