import 'package:dd_app_ui/data/services/api_service.dart';
import 'package:dd_app_ui/domain/models/direct_message_model.dart';
import 'package:dd_app_ui/domain/models/direct_model.dart';
import 'package:dd_app_ui/internal/config/token_storage.dart';
import 'package:flutter/material.dart';

class DirectState {
  final List<DirectModel>? directs;
  final List<List<DirectMessageModel>>? directMessages;
  final Map<String, String>? headers;
  final bool? isLoading;
  final bool? isUpdating;

  DirectState({
    this.directs,
    this.headers,
    this.isLoading = false,
    this.directMessages,
    this.isUpdating = false,
  });

  DirectState copyWith({
    directs,
    headers,
    isLoading,
    directMessages,
    isUpdating,
  }) =>
      DirectState(
        directs: directs ?? this.directs,
        headers: headers != null
            ? {"Authorization": "Bearer $headers"}
            : this.headers,
        isLoading: isLoading ?? this.isLoading,
        directMessages: directMessages ?? this.directMessages,
        isUpdating: isUpdating ?? this.isUpdating,
      );

  DirectState clear() => DirectState(
        directs: null,
        headers: headers,
        isLoading: isLoading,
        directMessages: null,
        isUpdating: isUpdating,
      );
}

class DirectViewModel extends ChangeNotifier {
  final BuildContext contex;
  final ApiService _apiService = ApiService();
  final lvc = ScrollController();
  int take = 10, skip = 0;

  DirectViewModel({required this.contex}) {
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

  var _state = DirectState();
  DirectState get state => _state;
  set state(DirectState val) {
    _state = val;
    notifyListeners();
  }

  Future refresh() async {
    state = state.clear();
    skip = 0;

    await _asyncInit();
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
    List<List<DirectMessageModel>> dirMess = state.directMessages ?? [];
    List<DirectModel> extDirects = state.directs ?? [];

    var directs = await _apiService.getUserDirects(
      take: take,
      skip: skip,
    );
    if (directs != null) {
      extDirects.addAll(directs);

      for (var direct in directs) {
        var dirMessage = await _apiService.getDirectMessages(
            lastDirectMessageCreated: null,
            directId: direct.directId,
            take: 1,
            skip: 0);

        dirMess.add(dirMessage ?? []);
      }

      state = state.copyWith(
        directMessages: dirMess,
        directs: extDirects,
        isUpdating: false,
      );
    }

    skip += take;
  }
}
