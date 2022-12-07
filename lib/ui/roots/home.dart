import 'package:dd_app_ui/data/services/api_service.dart';
import 'package:dd_app_ui/domain/models/post_model_response.dart';
import 'package:dd_app_ui/domain/models/user.dart';
import 'package:dd_app_ui/internal/config/app_config.dart';
import 'package:dd_app_ui/internal/config/shared_prefs.dart';
import 'package:dd_app_ui/internal/config/token_storage.dart';
import 'package:dd_app_ui/ui/app_navigator.dart';
import 'package:dd_app_ui/ui/icons_images/icons_icons.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:provider/provider.dart';

class _HomeSate {
  final int counter;
  final bool isRuning;
  final User? user;
  final int currentPageIndex;
  final List<PostModelResponse>? subscriptionPosts;
  final Map<String, String>? headers;

  _HomeSate(
      {this.counter = 0,
      this.isRuning = false,
      this.user,
      this.currentPageIndex = 0,
      this.headers,
      this.subscriptionPosts});

  _HomeSate copyWith({
    counter = 0,
    isRuning,
    user,
    currentPageIndex = 0,
    subscriptionPosts,
    headers,
  }) {
    List<PostModelResponse>? resSubscriptionsPosts;

    if (this.subscriptionPosts != null) {
      resSubscriptionsPosts = this.subscriptionPosts;
    }

    if (subscriptionPosts != null) {
      if (resSubscriptionsPosts == null) {
        resSubscriptionsPosts = subscriptionPosts;
      } else {
        resSubscriptionsPosts.addAll(subscriptionPosts);
      }
    }

    return _HomeSate(
      counter: counter ?? this.counter,
      headers:
          headers != null ? {"Authorization": "Bearer $headers"} : this.headers,
      isRuning: isRuning ?? this.isRuning,
      user: user ?? this.user,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      subscriptionPosts: resSubscriptionsPosts,
    );
  }
}

class _ViewModel extends ChangeNotifier {
  final BuildContext context;
  var _state = _HomeSate();
  Map<String, String>? headers;
  final _api = ApiService();
  int take = 10, skip = 0;
  List<GestureDetector> posts = [];
  bool? isLoading;

  _ViewModel({required this.context}) {
    _asyncInit();
  }

  _HomeSate get state => _state;
  set state(_HomeSate val) {
    _state = val;
    notifyListeners();
  }

  void _asyncInit() async {
    isLoading = true;
    var user = await SharedPrefs.getStoredUser();
    var headers = await TokenStorage.getAccessToken();

    if (user != null) {
      state = state.copyWith(user: user);
    }

    if (headers != null) {
      state = state.copyWith(headers: headers);
    }

    var posts = await _requestNextPosts(take, skip);

    if (posts == true || headers != null || user != null) {
      isLoading = false;
    }
  }

  void postPressed(String postId) {}

  void _updateScreenPosts(int startIndex) {
    for (int i = startIndex; i < state.subscriptionPosts!.length; i++) {
      if (state.subscriptionPosts![i].postFiles!.isEmpty) {
        continue;
      }

      posts.add(GestureDetector(
          onTap: () => postPressed(state.subscriptionPosts![i].id!),
          child: GFAvatar(
            backgroundImage: Image.network(
              "$baseUrl${state.subscriptionPosts![i].postFiles![0].link}",
              headers: state.headers,
            ).image,
            radius: (MediaQuery.of(context).size.width) - 1,
            shape: GFAvatarShape.square,
          )));
    }
  }

  Future<bool> _requestNextPosts(int take, int skip) async {
    var posts = await _api.getSubscriptionPosts(take, skip);
    int startIndex = 0;

    if (posts != null) {
      if (state.subscriptionPosts != null) {
        startIndex = state.subscriptionPosts!.length;
      }

      state = state.copyWith(subscriptionPosts: posts);

      take += 10;
      skip += 10;

      _updateScreenPosts(startIndex);

      return true;
    }

    return false;
  }
}

class HomeWidget extends StatelessWidget {
  const HomeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<_ViewModel>();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "NotInstagram",
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: viewModel.posts,
      ),
      bottomNavigationBar: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.09,
          child: Column(children: [
            const Divider(
              color: Colors.grey,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    width: MediaQuery.of(context).size.width / 2,
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(MyIcons.home),
                    )),
                SizedBox(
                    width: MediaQuery.of(context).size.width / 2,
                    child: IconButton(
                        onPressed: () => AppNavigator.toUserProfile(),
                        icon: const Icon(MyIcons.userOutline))),
              ],
            ),
          ])),
    );
  }

  static Widget create() => ChangeNotifierProvider<_ViewModel>(
        create: (context) => _ViewModel(context: context),
        lazy: false,
        child: const HomeWidget(),
      );
}
