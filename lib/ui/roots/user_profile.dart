import 'package:dd_app_ui/data/services/api_service.dart';
import 'package:dd_app_ui/data/services/auth_service.dart';
import 'package:dd_app_ui/domain/models/post_model_response.dart';
import 'package:dd_app_ui/domain/models/user.dart';
import 'package:dd_app_ui/exceptions/nonetwork_exception.dart';
import 'package:dd_app_ui/internal/config/app_config.dart';
import 'package:dd_app_ui/internal/config/shared_prefs.dart';
import 'package:dd_app_ui/internal/config/token_storage.dart';
import 'package:dd_app_ui/ui/app_navigator.dart';
import 'package:dd_app_ui/ui/custom_ui/custom_buttom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:jiffy/jiffy.dart';
import 'package:dd_app_ui/ui/icons_images/icons_icons.dart';
import 'package:getwidget/getwidget.dart';

class _UserProfileState {
  final User? user;
  final Map<String, String>? headers;
  final int? userPostAmount;
  final int? userSubscriptionsAmount;
  final int? userSubscribersAmount;
  final List<PostModelResponse>? userPosts;

  _UserProfileState({
    this.userSubscriptionsAmount,
    this.userSubscribersAmount,
    this.user,
    this.headers,
    this.userPostAmount,
    this.userPosts,
  });

  _UserProfileState copyWith({
    user,
    headers,
    userPostAmount,
    userSubscriptionsAmount,
    userSubscribersAmount,
    userPosts,
  }) {
    return _UserProfileState(
      user: user ?? this.user,
      headers:
          headers != null ? {"Authorization": "Bearer $headers"} : this.headers,
      userPostAmount: userPostAmount ?? this.userPostAmount,
      userSubscribersAmount:
          userSubscribersAmount ?? this.userSubscribersAmount,
      userSubscriptionsAmount:
          userSubscriptionsAmount ?? this.userSubscriptionsAmount,
      userPosts: userPosts ?? this.userPosts,
    );
  }
}

class _ViewModel extends ChangeNotifier {
  final BuildContext context;
  final List<String> ids = [];
  final List<GestureDetector> _allImages = [];
  var _state = _UserProfileState();
  final _authService = AuthService();
  final _apiService = ApiService();
  int take = 10, skip = 0;
  bool isLoading = true;

  _ViewModel({required this.context}) {
    _asyncInit();
  }

  set state(_UserProfileState val) {
    _state = val;
    notifyListeners();
  }

  _UserProfileState get state => _state;

  void _asyncInit() async {
    isLoading = true;
    User? user;
    String? headers;
    List<PostModelResponse>? userPosts;

    try {
      user = await SharedPrefs.getStoredUser();
      headers = await TokenStorage.getAccessToken();
      userPosts = await _apiService.getCurrentUserPosts(take: take, skip: skip);

      state = state.copyWith(
        userPostAmount: await _apiService.getUserPostAmount(),
        userSubscribersAmount: await _apiService.getUserSubscribersAmount(),
        userSubscriptionsAmount: await _apiService.getUserSubscriptionsAmount(),
      );
    } on NoNetworkException {
      _showDialog("Network error", "Network erorr, please try later");
    } on Exception {
      _showDialog("Error", "Happened unexpected error, please try later");
    }

    if (user != null) {
      state = state.copyWith(user: user);
    }

    if (headers != null) {
      state = state.copyWith(headers: headers);
    }

    if (userPosts != null) {
      if (state.userPosts == null) {
        state = state.copyWith(userPosts: userPosts);
      } else {
        state.userPosts!.addAll(userPosts);
      }

      addImages(userPosts.length);

      skip += 10;
      take += 10;
    }

    if (user != null || headers != null || userPosts != null) {
      isLoading = false;
    }
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

  void addImages(int size) {
    for (int i = state.userPosts!.length - size;
        i < state.userPosts!.length;
        i++) {
      _allImages.add(GestureDetector(
          onTap: () => postPressed(state.userPosts![i].id!),
          child: GFAvatar(
            backgroundImage: Image.network(
              "$baseUrl${state.userPosts![i].postFiles![0].link}",
              headers: state.headers,
            ).image,
            radius: (MediaQuery.of(context).size.width / 6) - 1,
            shape: GFAvatarShape.square,
          )));
    }

    notifyListeners();
  }

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

  String getUserPostsAmount() => state.userPostAmount == null
      ? 0.toString()
      : state.userPostAmount.toString();

  String getUserSubscribersAmount() => state.userSubscribersAmount == null
      ? 0.toString()
      : state.userSubscribersAmount.toString();

  String getUserSubscriptionsAmount() => state.userSubscriptionsAmount == null
      ? 0.toString()
      : state.userSubscriptionsAmount.toString();

  String getUserBirtDate() =>
      state.user == null ? '' : Jiffy(state.user!.birthDate, "yyyy-MM-dd").MMMd;

  void postPressed(
      String postId) {} //TODO Добавить обработчик перехода на выбранный пост

  Future requestNextPosts() async {
    List<PostModelResponse>? userPosts;

    try {
      userPosts = await _apiService.getCurrentUserPosts(take: take, skip: skip);
    } on NoNetworkException {
      _showDialog("Network error", "Network erorr, please try later");
    } on Exception {
      _showDialog("Error", "Happened unexpected error, please try later");
    }

    if (userPosts != null) {
      if (state.userPosts == null) {
        state = state.copyWith(userPosts: userPosts);
      } else {
        state.userPosts!.addAll(userPosts);
      }

      addImages(userPosts.length);

      skip += 10;
      take += 10;
    }
  }
}

class UserProfileWidget extends StatelessWidget {
  static const double fontSize = 12;

  const UserProfileWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _portraitModeOnly();

    var viewModel = context.watch<_ViewModel>();

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: viewModel.state.user != null
              ? Text(viewModel.state.user!.name)
              : const Text(""),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              onPressed: viewModel.logout,
              icon: const Icon(MyIcons.logout),
            )
          ],
        ),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              IntrinsicHeight(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(10, 10, 5, 10),
                    child: (viewModel.state.headers != null &&
                            viewModel.state.user != null)
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(
                              "$baseUrl${viewModel.state.user!.avatar}",
                              headers: viewModel.state.headers,
                            ),
                            radius: 50.0,
                          )
                        : const CircleAvatar(
                            backgroundColor: Colors.grey,
                            radius: 50.0,
                          ),
                  ),
                  const SizedBox(
                      height: 75,
                      child: VerticalDivider(
                        width: 5,
                        color: Colors.grey,
                      )),
                  Flexible(
                    child: Container(
                        margin: const EdgeInsets.fromLTRB(5.0, 0, 0.0, 0.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                  Container(
                                      alignment: Alignment.center,
                                      child: const Text(
                                        "Post ",
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: fontSize,
                                        ),
                                      )),
                                  Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        viewModel.getUserPostsAmount(),
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: fontSize + 10,
                                        ),
                                      )),
                                ])),
                            Expanded(
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                  Container(
                                      alignment: Alignment.center,
                                      child: const Text(
                                        "Followers ",
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: fontSize,
                                        ),
                                      )),
                                  Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        viewModel.getUserSubscribersAmount(),
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: fontSize + 10,
                                        ),
                                      )),
                                ])),
                            Expanded(
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                  Container(
                                      alignment: Alignment.center,
                                      child: const Text(
                                        "Followings ",
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: fontSize,
                                        ),
                                      )),
                                  Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        viewModel.getUserSubscriptionsAmount(),
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: fontSize + 10,
                                        ),
                                      )),
                                ])),
                          ],
                        )),
                  ),
                ],
              )),
              if (viewModel.isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
              Expanded(
                  child: NotificationListener<ScrollNotification>(
                      onNotification: (scrollNotification) {
                        if (scrollNotification is ScrollEndNotification) {
                          viewModel.requestNextPosts();
                          return true;
                        }
                        return false;
                      },
                      child: SingleChildScrollView(
                        child: Wrap(
                          runSpacing: 2.0,
                          spacing: 2.0,
                          direction: Axis.horizontal,
                          children: viewModel._allImages,
                        ),
                      ))),
            ],
          ),
        ),
        bottomNavigationBar: CustomBottomNavigationBar.create(
            context: context, isUserProfile: true));
  }

  void _portraitModeOnly() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  static Widget create() => ChangeNotifierProvider<_ViewModel>(
        create: (context) => _ViewModel(context: context),
        lazy: false,
        child: const UserProfileWidget(),
      );
}
