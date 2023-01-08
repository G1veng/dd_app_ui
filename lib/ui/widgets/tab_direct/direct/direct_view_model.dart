import 'dart:io';

import 'package:dd_app_ui/data/services/api_service.dart';
import 'package:dd_app_ui/data/services/data_service.dart';
import 'package:dd_app_ui/data/services/sync_service.dart';
import 'package:dd_app_ui/domain/enums/db_query.dart';
import 'package:dd_app_ui/domain/models/create_direct_message_model.dart';
import 'package:dd_app_ui/domain/models/direct.dart';
import 'package:dd_app_ui/domain/models/direct_message.dart';
import 'package:dd_app_ui/domain/models/send_push_model.dart';
import 'package:dd_app_ui/domain/models/user.dart';
import 'package:dd_app_ui/internal/config/shared_prefs.dart';
import 'package:dd_app_ui/internal/config/token_storage.dart';
import 'package:dd_app_ui/ui/navigation/tab_navigator.dart';
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
    await _apiService.getUserById(
        userId: (await SharedPrefs.getStoredUser())!.id);
    if (!(await SharedPrefs.getConnectionState())) {
      return;
    }

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

    _sendNotificationsAsync(
        (state.createMessageText == null || state.createMessageText!.isEmpty)
            ? "Sended files"
            : state.createMessageText!,
        directId);

    state = state.copyWith(directMessages: newMessage, createMessageText: "");
    createMessageTec.text = "";
  }

  Future _sendNotificationsAsync(String message, String directId) async {
    var members = await _dataService.getDirectMembers(
      where: {
        "id": state.direct!.id,
        "userId": (await SharedPrefs.getStoredUser())!.id
      },
      conds: [
        DbQueryEnum.equal,
        DbQueryEnum.notEqual,
      ],
    );

    if (members == null) {
      return;
    }

    var alert = Alert(
      title: "New message from ${state.currentUser!.name}",
      body: message,
    );
    var customData = CustomData(
      additionalProp1: directId,
      additionalProp2: TabNavigatorRoutes.direct,
      additionalProp3: "",
    );
    var push = Push(
      badge: 1,
      alert: alert,
      customData: customData,
    );

    for (var member in members) {
      var model = SendPushModel(
        userId: member.userId,
        push: push,
      );

      _apiService.sendPush(model: model);
    }
  }

  Future _asyncInit() async {
    state = state.copyWith(
      isLoading: true,
      isUpdating: true,
    );

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

          avatars.addAll({member.userId: user?.avatar});
        }

        state = state.copyWith(membersAvatars: avatars);
      }

      await _requestNextMessages();
    }

    state = state.copyWith(isLoading: false, isUpdating: false);
    _updateDirect();
  }

  Future _updateDirect({int soconds = 1}) async {
    for (;;) {
      Future.delayed(Duration(seconds: soconds));
      await _apiService.getUserById(
          userId: (await SharedPrefs.getStoredUser())!.id);
      if (!(await SharedPrefs.getConnectionState())) {
        continue;
      }

      var newMessages = await _apiService.getDirectMessages(
        lastDirectMessageCreated: null,
        directId: directId,
        take: 20,
        skip: 0,
      );

      if (state.directMessages != null && newMessages != null) {
        if (state.directMessages!.first.id !=
            newMessages.first.directMessageId) {
          int newMessageAmount = 0;

          for (var message in newMessages) {
            if (message.directMessageId != state.directMessages![0].id) {
              newMessageAmount++;
              continue;
            }
            break;
          }

          await _dataService.cuDirectMessages(
            newMessages
                .map((e) => DirectMessage(
                    id: e.directMessageId,
                    directMessage: e.directMessage,
                    directId: directId,
                    sended: e.sended,
                    senderId: e.senderId))
                .toList(),
          );

          var messages = await _dataService.getDirectMessages(
            where: {"directId": directId},
            conds: [DbQueryEnum.equal],
            take: newMessageAmount,
          );

          if (messages != null) {
            var stateMess = state.directMessages ?? [];

            messages.addAll(stateMess);
            state = state.copyWith(directMessages: messages);
          }
        }
      }
    }
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
