import 'package:dd_app_ui/data/services/data_service.dart';
import 'package:dd_app_ui/data/services/sync_service.dart';
import 'package:dd_app_ui/domain/enums/db_query.dart';
import 'package:dd_app_ui/domain/models/direct.dart';
import 'package:dd_app_ui/domain/models/direct_message.dart';
import 'package:dd_app_ui/internal/config/shared_prefs.dart';
import 'package:dd_app_ui/internal/config/token_storage.dart';
import 'package:dd_app_ui/ui/navigation/tab_navigator.dart';
import 'package:flutter/material.dart';

class DirectsState {
  final List<Direct>? directs;
  final List<List<DirectMessage>>? directMessages;
  final Map<String, String>? headers;
  final bool? isLoading;
  final bool? isUpdating;

  DirectsState({
    this.directs,
    this.headers,
    this.isLoading = false,
    this.directMessages,
    this.isUpdating = false,
  });

  DirectsState copyWith({
    directs,
    headers,
    isLoading,
    directMessages,
    isUpdating,
  }) =>
      DirectsState(
        directs: directs ?? this.directs,
        headers: headers != null
            ? {"Authorization": "Bearer $headers"}
            : this.headers,
        isLoading: isLoading ?? this.isLoading,
        directMessages: directMessages ?? this.directMessages,
        isUpdating: isUpdating ?? this.isUpdating,
      );

  DirectsState clear() => DirectsState(
        directs: null,
        headers: headers,
        isLoading: isLoading,
        directMessages: null,
        isUpdating: isUpdating,
      );
}

class DirectsViewModel extends ChangeNotifier {
  final BuildContext context;
  final SyncService _syncService = SyncService();
  final DataService _dataService = DataService();
  final lvc = ScrollController();
  final _take = 10;
  int _skip = 0;

  DirectsViewModel({required this.context}) {
    _asyncInit();

    lvc.addListener(() async {
      var max = lvc.position.maxScrollExtent;
      var current = lvc.offset;
      var percent = (current / max * 100);
      if (percent > 80) {
        if (!state.isUpdating!) {
          _startDelayAsync();
          await _requestNextDirects();
        }
      }
    });
  }

  var _state = DirectsState();
  DirectsState get state => _state;
  set state(DirectsState val) {
    _state = val;
    notifyListeners();
  }

  Future refresh() async {
    state = state.clear();
    _skip = 0;

    await _asyncInit();
  }

  Future pressedGoToDirect({String? directId}) async {
    return await Navigator.of(context).pushNamed(
      TabNavigatorRoutes.direct,
      arguments: directId,
    );
  }

  Future _asyncInit() async {
    state = state.copyWith(isLoading: true);
    state = state.copyWith(headers: (await TokenStorage.getAccessToken()));

    await _requestNextDirects();
    state = state.copyWith(isLoading: false);
  }

  Future _startDelayAsync({int duration = 2}) async {
    state = state.copyWith(isUpdating: true);
    await Future.delayed(Duration(seconds: duration));
  }

  Future _requestNextDirects() async {
    List<List<DirectMessage>> dirMess = state.directMessages ?? [];
    List<Direct> extDirects = state.directs ?? [];

    await _syncService.syncDirects(_take, skip: _skip);
    var directs = await _dataService.getDirects(take: _take, skip: _skip);
    if (directs != null) {
      extDirects.addAll(directs);

      for (var direct in directs) {
        if ((await SharedPrefs.getConnectionState())) {
          await _syncService.syncDirectMessages(take: 1, directId: direct.id);
        }

        var dirMessage = await _dataService.getDirectMessages(
          take: 1,
          where: {"directId": direct.id},
          conds: [DbQueryEnum.equal],
        );

        dirMess.add(dirMessage ?? []);
      }

      state = state.copyWith(
        directMessages: dirMess,
        directs: extDirects,
        isUpdating: false,
      );
    }

    _skip += _take;
  }
}
