import 'dart:io';

import 'package:dd_app_ui/data/services/api_service.dart';
import 'package:dd_app_ui/data/services/data_service.dart';
import 'package:dd_app_ui/data/services/sync_service.dart';
import 'package:dd_app_ui/domain/enums/db_query.dart';
import 'package:dd_app_ui/domain/models/create_direct_message_model.dart';
import 'package:dd_app_ui/domain/models/direct.dart';
import 'package:dd_app_ui/domain/models/direct_message.dart';
import 'package:dd_app_ui/domain/models/user.dart';
import 'package:dd_app_ui/internal/config/shared_prefs.dart';
import 'package:dd_app_ui/internal/config/token_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';

class DirectState {
  final Direct? direct;
  final List<DirectMessage>? directMessages;
  final Map<String, String>? headers;
  final bool? isLoading;
  final bool? isUpdating;
  final String? directTitle;
  final User? currentUser;
  final String? createMessageText;
  final List<File>? files;
  final Map<String, String?>? membersAvatars;

  DirectState({
    this.direct,
    this.directMessages,
    this.headers,
    this.isLoading,
    this.isUpdating,
    this.directTitle,
    this.currentUser,
    this.createMessageText,
    this.files,
    this.membersAvatars,
  });

  DirectState copyWith({
    direct,
    directMessages,
    headers,
    isLoading = false,
    isUpdating = false,
    directTitle,
    currentUser,
    createMessageText,
    files,
    membersAvatars,
  }) =>
      DirectState(
        direct: direct ?? this.direct,
        directMessages: directMessages ?? this.directMessages,
        headers: headers != null
            ? {"Authorization": "Bearer $headers"}
            : this.headers,
        isLoading: isLoading ?? this.isLoading,
        isUpdating: isUpdating ?? this.isUpdating,
        directTitle: directTitle ?? this.directTitle,
        currentUser: currentUser ?? this.currentUser,
        createMessageText: createMessageText ?? this.createMessageText,
        files: files ?? this.files,
        membersAvatars: membersAvatars ?? this.membersAvatars,
      );
}

class DirectViewModel extends ChangeNotifier {
  final BuildContext context;
  final String directId;
  final _apiService = ApiService();
  final _syncService = SyncService();
  final _dataService = DataService();
  final _take = 10;
  int _skip = 0;
  final lvc = ScrollController();
  var createMessageTec = TextEditingController();

  DirectViewModel({required this.context, required this.directId}) {
    createMessageTec.addListener(() {
      state = state.copyWith(createMessageText: createMessageTec.text);
    });

    _asyncInit();

    lvc.addListener(() async {
      var max = lvc.position.maxScrollExtent;
      var current = lvc.offset;
      var percent = (current / max * 100);
      if (percent > 80) {
        if (!state.isUpdating!) {
          _startDelayAsync();
          await _requestNextMessages();
        }
      }
    });
  }

  DirectState _state = DirectState();
  DirectState get state => _state;
  set state(DirectState val) {
    _state = val;
    notifyListeners();
  }

  Future createMessage() async {
    var messageId = const Uuid().v4();
    var sended = DateTime.now().toUtc().toString().replaceAll(r' ', 'T');

    await _dataService.iDirectMessage(DirectMessage(
        id: messageId,
        directMessage: state.createMessageText,
        directId: directId,
        sended: sended,
        senderId: state.currentUser!.id));

    await _apiService.createDirectMessage(
        model: CreateDirectMessageModel(
            directId: directId,
            directMessageId: messageId,
            files: null,
            message: state.createMessageText,
            sended: sended));

    var newMessage = await _dataService.getDirectMessages(
        where: {"directId": directId}, take: 1, conds: [DbQueryEnum.equal]);

    var mess = state.directMessages ?? [];
    newMessage!.addAll(mess);

    state = state.copyWith(directMessages: newMessage, createMessageText: "");
    createMessageTec.text = "";
  }

  Future _asyncInit() async {
    state = state.copyWith(isLoading: true);

    state = state.copyWith(
      currentUser: (await SharedPrefs.getStoredUser()),
      headers: (await TokenStorage.getAccessToken()),
    );

    await _syncService.syncDirect(directId: directId);
    var direct = await _dataService.getDirect(directId: directId);
    if (direct != null) {
      state = state.copyWith(directTitle: direct.title, direct: direct);

      var directMembers = await _dataService.getDirectMembers(
          where: {"id": directId}, conds: [DbQueryEnum.equal]);
      Map<String, String?> avatars = {};
      if (directMembers != null) {
        for (var member in directMembers) {
          var user = await _dataService.getUser(member.userId);

          avatars.addAll({member.id: user?.avatar});
        }

        state = state.copyWith(membersAvatars: avatars);
      }

      await _requestNextMessages();
    }

    state = state.copyWith(isLoading: false);
  }

  Future _requestNextMessages() async {
    if (state.direct != null) {
      var extMessages = state.directMessages ?? [];

      await _syncService.syncDirectMessages(take: _take, directId: directId);
      var directMesasges = await _dataService.getDirectMessages(
        where: state.directMessages == null
            ? {
                "directId": directId,
              }
            : {
                "directId": directId,
                "sended": state.directMessages!.last.sended
              },
        skip: _skip,
        take: _take,
        conds: state.directMessages == null
            ? [DbQueryEnum.equal]
            : [DbQueryEnum.equal, DbQueryEnum.isLess],
      );

      if (directMesasges != null) {
        extMessages.addAll(directMesasges);

        state = state.copyWith(directMessages: extMessages);
      }

      _skip += _take;
    }

    state = state.copyWith(isUpdating: false);
  }

  Future _startDelayAsync({int duration = 2}) async {
    state = state.copyWith(isUpdating: true);
    await Future.delayed(Duration(seconds: duration));
  }
}
