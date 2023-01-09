import 'dart:io';
import 'package:dd_app_ui/data/services/api_service.dart';
import 'package:dd_app_ui/data/services/auth_service.dart';
import 'package:dd_app_ui/data/services/data_service.dart';
import 'package:dd_app_ui/data/services/sync_service.dart';
import 'package:dd_app_ui/domain/enums/db_query.dart';
import 'package:dd_app_ui/domain/models/create_direct_model.dart';
import 'package:dd_app_ui/domain/models/direct.dart';
import 'package:dd_app_ui/domain/models/direct_member.dart';
import 'package:dd_app_ui/domain/models/post_with_post_like_state.dart';
import 'package:dd_app_ui/domain/models/subscription.dart';
import 'package:dd_app_ui/domain/models/user.dart';
import 'package:dd_app_ui/domain/models/user_statistics.dart';
import 'package:dd_app_ui/domain/exceptions/nonetwork_exception.dart';
import 'package:dd_app_ui/internal/config/app_config.dart';
import 'package:dd_app_ui/internal/config/shared_prefs.dart';
import 'package:dd_app_ui/internal/config/token_storage.dart';
import 'package:dd_app_ui/ui/navigation/app_navigator.dart';
import 'package:dd_app_ui/ui/navigation/tab_navigator.dart';
import 'package:dd_app_ui/ui/widgets/common/cam_widget.dart';
import 'package:dd_app_ui/ui/widgets/roots/app/app_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class UserProfileState {
  final User? user;
  final Map<String, String>? headers;
  final UserStatistics? userStatistics;
  final List<PostWithPostLikeState>? userPosts;
  final Image? avatar;
  final bool? isLoading;
  final bool? isUpdating;
  final bool? isCurrentUser;
  final bool? isSubscribed;
  final bool? isInternetConnection;

  UserProfileState({
    this.isCurrentUser = false,
    this.user,
    this.headers,
    this.userStatistics,
    this.userPosts,
    this.avatar,
    this.isLoading = false,
    this.isUpdating = false,
    this.isSubscribed = false,
    this.isInternetConnection = false,
  });

  UserProfileState clear() {
    return UserProfileState(
      user: user,
      headers: headers,
      isCurrentUser: isCurrentUser,
      userStatistics: null,
      userPosts: null,
      avatar: null,
      isInternetConnection: false,
    );
  }

  UserProfileState copyWith({
    user,
    headers,
    userStatistics,
    userPosts,
    avatar,
    isUpdating,
    isLoading,
    isCurrentUser,
    isSubscribed,
    isInternetConnection,
  }) {
    List<PostWithPostLikeState>? extendeUserPosts;

    if (this.userPosts == null) {
      if (userPosts != null) {
        extendeUserPosts = userPosts;
      }
    } else {
      extendeUserPosts = this.userPosts;
      if (userPosts != null) {
        extendeUserPosts!.addAll(userPosts);
      }
    }

    return UserProfileState(
      user: user ?? this.user,
      headers:
          headers != null ? {"Authorization": "Bearer $headers"} : this.headers,
      userStatistics: userStatistics ?? this.userStatistics,
      userPosts: extendeUserPosts,
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      avatar: avatar ?? this.avatar,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      isInternetConnection: isInternetConnection ?? this.isInternetConnection,
    );
  }
}

class UserProfileViewModel extends ChangeNotifier {
  final BuildContext context;
  final List<String> ids = [];
  final List<Widget> allImages = [];
  var _state = UserProfileState();
  final _authService = AuthService();
  final _apiService = ApiService();
  final _dataService = DataService();
  final _syncService = SyncService();
  final lvc = ScrollController();
  String? userId;
  int take = 10;

  bool isDelay = false;

  UserProfileViewModel({required this.context, required this.userId}) {
    _asyncInit();

    lvc.addListener(() async {
      var max = lvc.position.maxScrollExtent;
      var current = lvc.offset;
      var percent = (current / max * 100);
      if (percent > 80) {
        if (!state.isUpdating!) {
          _startDelayAsync();
          await _requestNextPosts();
        }
      }
    });
  }

  set state(UserProfileState val) {
    _state = val;
    notifyListeners();
  }

  UserProfileState get state => _state;

  void logout() async {
    try {
      await _authService.logout();
    } on NoNetworkException {
      _showDialog("Network error", "No network, please try later");
    } on Exception {
      _showDialog("Error", "Happened unexpected error, please try later");
    }
    AppNavigator.toLoader();
  }

  Future gotoDirectPressed(String userId) async {
    await _apiService.getUserById(userId: state.user!.id);
    if (!(await SharedPrefs.getConnectionState())) {
      return;
    }

    var direct = await _apiService.getDirectWithUser(userId: userId);
    if (direct == null) {
      var directId = const Uuid().v4();

      await _dataService.cuDirect(Direct(
          id: directId,
          directImage: state.user?.avatar,
          title: state.user!.name));

      await _apiService.createDirect(
          model: CreateDirectModel(
        id: directId,
        userId: userId,
        title: state.user!.name,
        directImage: state.user!.avatar,
      ));

      await _dataService.cuDirectMembers([
        DirectMember(id: directId, userId: userId),
        DirectMember(
            id: directId, userId: (await SharedPrefs.getStoredUser())!.id),
      ]);

      _pushDirect(directId);
      return;
    }
    _pushDirect(direct.directId);
  }

  Future _pushDirect(String directId) async {
    await Navigator.of(context)
        .pushNamed(TabNavigatorRoutes.direct, arguments: directId);
  }

  void postPressed(String postId) => {
        Navigator.of(context)
            .pushNamed(TabNavigatorRoutes.postDetails, arguments: postId)
      };

  Future changeSubscriptionStatePressed() async {
    await _apiService.getUserById(userId: state.user!.id);
    if (!(await SharedPrefs.getConnectionState())) {
      return;
    }

    await _apiService.changeSubscriptionStateOnUser(userId: state.user!.id);

    var subscription = Subscription(
        id: state.user!.id,
        subscriberId: (await SharedPrefs.getStoredUser())!.id);

    if (state.isSubscribed == true) {
      await _dataService.delSubscription(subscription: subscription);
    } else {
      await _dataService.cuSubscription(subscription);
    }

    await _syncService.syncUser(userId: state.user!.id);
    state = state.copyWith(
      userStatistics: await _dataService.getUserStatisctics(state.user!.id),
      isSubscribed: state.isSubscribed == true ? false : true,
    );
  }

  Future refresh() async {
    state = state.clear();
    await _apiService.getUserById(userId: state.user!.id);
    if (!(await SharedPrefs.getConnectionState())) {
      return;
    }

    await _asyncInit();
  }

  Future changePhoto() async {
    String? imagePath;
    var viewModel = context.read<AppViewModel>();
    await _apiService.getUserById(userId: state.user!.id);
    if (!(await SharedPrefs.getConnectionState())) {
      return;
    }

    await Navigator.of(AppNavigator.key.currentState!.context)
        .push(MaterialPageRoute(
      builder: (newContext) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.black),
        body: SafeArea(
          child: CamWidget(
            onFile: (file) {
              imagePath = file.path;
              Navigator.of(newContext).pop();
            },
          ),
        ),
      ),
    ));

    if (imagePath != null) {
      var metaData = await _apiService.uploadFiles(files: [File(imagePath!)]);
      if (metaData!.isNotEmpty) {
        await _apiService.addUserAvatar(model: metaData.first);
        var img =
            await NetworkAssetBundle(Uri.parse("$baseUrl${state.user!.avatar}"))
                .load("$baseUrl${state.user!.avatar}?v=1");
        state = state.copyWith(avatar: Image.memory(img.buffer.asUint8List()));

        viewModel.avatar = state.avatar;
      }
    }
  }

  String isSubscribedOn() {
    return state.isSubscribed == true ? "Unfollow" : "Follow";
  }

  Future _startDelayAsync({int duration = 1}) async {
    state = state.copyWith(isUpdating: true);
    await Future.delayed(Duration(seconds: duration));
  }

  Future _requestNextPosts() async {
    try {
      await _syncService.syncUserPosts(
          userId: state.user!.id,
          take,
          lastPostCreated: state.userPosts?.last.created);
    } on NoNetworkException {
      _showDialog("Network error", "Network erorr, please try later");
    } on Exception {
      _showDialog("Error", "Happened unexpected error, please try later");
    }

    var posts = await _dataService.getPostsWithLikeStatePostFilesById(
        state.userPosts != null
            ? {
                "authorId": state.user!.id,
                "created": state.userPosts!.last.created
              }
            : {"authorId": state.user!.id},
        conds: state.userPosts != null
            ? [DbQueryEnum.equal, DbQueryEnum.isLess]
            : [DbQueryEnum.equal],
        take: take);
    if (posts != null) {
      var innerPosts = state.userPosts ?? [];

      innerPosts.addAll(posts.toList());

      state = state.copyWith(
        userPosts: innerPosts,
        isUpdating: false,
      );
    }
  }

  Future _asyncInit() async {
    state = state.copyWith(
        isLoading: true,
        isInternetConnection: (await SharedPrefs.getConnectionState()));

    if (userId == null) {
      state = state.copyWith(user: await SharedPrefs.getStoredUser());
    } else {
      await _syncService.syncUser(userId: userId!);

      state = state.copyWith(
        user: await _dataService.getUser(userId!),
      );
    }

    var headers = await TokenStorage.getAccessToken();
    await _syncService.syncUser(userId: state.user!.id);

    state = state.copyWith(
      headers: headers,
      userStatistics: await _dataService.getUserStatisctics(state.user!.id),
      isCurrentUser:
          userId == null || (await SharedPrefs.getStoredUser())!.id == userId,
      isSubscribed: (await SharedPrefs.getConnectionState()) == false
          ? false
          : (await _apiService.isSubscribedOn(userId: state.user!.id)),
    );

    if ((await SharedPrefs.getConnectionState()) == true &&
        state.user!.avatar != null) {
      var img =
          await NetworkAssetBundle(Uri.parse("$baseUrl${state.user!.avatar}"))
              .load("$baseUrl${state.user!.avatar}?v=2");
      state = state.copyWith(avatar: Image.memory(img.buffer.asUint8List()));
    }

    await _requestNextPosts();

    state = state.copyWith(
      isLoading: false,
    );
  }

  void _showDialog(String title, String description) {
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text(title),
              content: Text(description),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, 'Cancel'),
                  child: const Text('Ok'),
                ),
              ],
            ));
  }
}
