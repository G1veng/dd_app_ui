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
import 'package:dd_app_ui/ui/icons_images/icons_icons.dart';

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
  final List<Flexible> _allImages = [];
  var _state = _UserProfileState();
  final _authService = AuthService();
  final _apiService = ApiService();
  int take = 10, skip = 0;

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
    var postFiles =
        await _apiService.getCurrentUserPosts(take: take, skip: skip);

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
      state = state.copyWith(userPosts: postFiles);
      skip += 10;
      take += 10;
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

  void postPressed(String id) {} //TODO Добавить обработчик нажатия на пост

  void _getAllImages() {
    int counter = 0;

    while (_haveNextImage(counter)) {
      _allImages.add(
        Flexible(
            child: SizedBox(
                height: MediaQuery.of(context).size.width / 3,
                width: MediaQuery.of(context).size.width / 3,
                child: IconButton(
                    padding: const EdgeInsets.all(0.0),
                    onPressed: () => postPressed(state.userPosts![0].id!),
                    icon: Image.network(
                      "$baseUrl${state.userPosts![0].postFiles![0].link}",
                      headers: state.headers,
                      alignment: Alignment.centerLeft,
                      height: MediaQuery.of(context).size.width / 3,
                      width: MediaQuery.of(context).size.width / 3,
                    )))),
      );

      counter++;
    }
  }

  List<Widget> fillImageField() {
    List<Widget> res = [];
    int counter = 0;
    List<Flexible> temp = [];

    _getAllImages();

    for (int i = 0; i < _allImages.length; i++) {
      counter++;

      if (counter == 3) {
        res.add(Row(
          children: [
            _allImages[i - 2],
            _allImages[i - 1],
            _allImages[i],
          ],
        ));

        counter = 0;
      }
    }

    if (counter != 0) {
      for (int i = _allImages.length - 1;
          i >= _allImages.length - counter;
          i--) {
        temp.add(_allImages[i]);
      }

      res.add(Row(children: temp));
    }

    notifyListeners();

    return res;
  }

  bool _haveNextImage(int index) {
    if (state.userPosts != null) {
      if (state.userPosts!.length == index) {
        return false;
      } else {
        return true;
      }
    }
    return false;
  }

  Future _requestNextPosts() async {
    var postFiles =
        await _apiService.getCurrentUserPosts(take: take, skip: skip);

    state = state.copyWith(userPosts: postFiles);

    if (postFiles != null) {
      state = state.copyWith(userPosts: postFiles);
      skip += 10;
      take += 10;
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
            icon: const Icon(MyIcons.logout),
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
                            "Posts:  ${viewModel.getUserPostsAmount()}",
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "Followers:  ${viewModel.getUserSubscribersAmount()}",
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "Following:  ${viewModel.getUserSubscriptionsAmount()}",
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "Birth date:  ${viewModel.getUserBirtDate()}",
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      )),
                ),
              ],
            ),
            Expanded(
                child: NotificationListener<ScrollNotification>(
                    onNotification: (scrollNotification) {
                      if (scrollNotification is ScrollEndNotification) {
                        viewModel._requestNextPosts();
                        return true;
                      }
                      return false;
                    },
                    child: SingleChildScrollView(
                      child: Wrap(
                        direction: Axis.horizontal,
                        children: viewModel.fillImageField(),
                      ),
                    ))),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) => viewModel.changeActivePage(index),
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(MyIcons.homeOutline),
            label: '',
            tooltip: 'Home',
          ),
          NavigationDestination(
            icon: Icon(MyIcons.user),
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
