import 'package:dd_app_ui/data/services/api_service.dart';
import 'package:dd_app_ui/data/services/auth_service.dart';
import 'package:dd_app_ui/domain/models/post_model_response.dart';
import 'package:dd_app_ui/domain/models/user.dart';
import 'package:dd_app_ui/internal/config/app_config.dart';
import 'package:dd_app_ui/internal/config/shared_prefs.dart';
import 'package:dd_app_ui/internal/config/token_storage.dart';
import 'package:dd_app_ui/ui/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jiffy/jiffy.dart';

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
    postFiles,
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
      userPosts: postFiles ?? this.userPosts,
    );
  }
}

class _ViewModel extends ChangeNotifier {
  final BuildContext context;
  var _state = _UserProfileState();
  final _authService = AuthService();
  final _apiService = ApiService();

  _ViewModel({required this.context}) {
    asyncInit();
  }

  set state(_UserProfileState val) {
    _state = val;
    notifyListeners();
  }

  _UserProfileState get state => _state;

  void asyncInit() async {
    var user = await SharedPrefs.getStoredUser();
    var headers = await TokenStorage.getAccessToken();
    var postFiles = await _apiService.getCurrentUserPosts(take: 10, skip: 0);

    state = state.copyWith(
      userPostAmount: await _apiService.getUserPostAmount(),
      userSubscribersAmount: await _apiService.getUserSubscribersAmount(),
      userSubscriptionsAmount: await _apiService.getUserSubscriptionsAmount(),
    );

    if (user != null) {
      state = state.copyWith(user: user);
    }

    if (headers != null) {
      state = state.copyWith(headers: headers);
    }

    if (postFiles != null) {
      state = state.copyWith(postFiles: postFiles);
    }
  }

  void logout() async {
    await _authService.logout();
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

  void changeActivePage(
    int currentPageIndex,
  ) {
    switch (currentPageIndex) {
      case 0:
        AppNavigator.toHome();
        break;
      default:
        break;
    }
  }

  List<Widget> getImages() {
    int counter = 0;
    List<Flexible> widgets = [];
    List<Widget> res = [];

    if (state.userPosts != null) {
      while (_haveNextImage(counter)) {
        widgets.add(
          Flexible(
              child: Container(
                  margin: const EdgeInsets.all(1.0),
                  child: Image.network(
                    "$baseUrl${state.userPosts![0].postFiles![0].link}",
                    headers: state.headers,
                    height: MediaQuery.of(context).size.width / 3.5,
                  ))),
        );

        if (widgets.length == 3) {
          res.add(Row(
            children: widgets,
          ));

          widgets = [];
        }

        counter++;
      }

      res.add(Row(
        children: widgets,
      ));
    }

    return res;
  }

  bool _haveNextImage(int index) {
    if (state.userPosts!.length == index) {
      return false;
    } else {
      return true;
    }
  }
}

class UserProfileWidget extends StatelessWidget {
  const UserProfileWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            icon: const Icon(Icons.exit_to_app),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.all(20.0),
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
                Flexible(
                  child: Container(
                      margin: const EdgeInsets.fromLTRB(20.0, 0, 0, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Posts:\t${viewModel.getUserPostsAmount()}",
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "Followers:\t${viewModel.getUserSubscribersAmount()}",
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "Following:\t${viewModel.getUserSubscriptionsAmount()}",
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "Birth date:\t${viewModel.getUserBirtDate()}",
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      )),
                ),
              ],
            ),
            Expanded(
                child: SingleChildScrollView(
              child: Wrap(
                direction: Axis.horizontal,
                children: viewModel.getImages(),
              ),
            )),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) => viewModel.changeActivePage(index),
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.home_filled),
            label: '',
            tooltip: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: '',
            tooltip: 'Profile',
          ),
        ],
      ),
    );
  }

  static Widget create() => ChangeNotifierProvider<_ViewModel>(
        create: (context) => _ViewModel(context: context),
        lazy: false,
        child: const UserProfileWidget(),
      );
}
