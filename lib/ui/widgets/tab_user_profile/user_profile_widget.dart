import 'package:dd_app_ui/internal/config/app_config.dart';
import 'package:dd_app_ui/ui/widgets/tab_user_profile/user_profile_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dd_app_ui/domain/icons_images/icons_icons.dart';

class UserProfileWidget extends StatelessWidget {
  static const double fontSize = 12;

  const UserProfileWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<UserProfileViewModel>();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: viewModel.state.user != null
            ? Text(
                viewModel.state.user!.name,
                overflow: TextOverflow.ellipsis,
              )
            : const Text(""),
        centerTitle: true,
        actions: viewModel.state.isCurrentUser == true
            ? <Widget>[
                IconButton(
                  onPressed: viewModel.logout,
                  icon: const Icon(MyIcons.logout),
                ),
              ]
            : null,
      ),
      body: SafeArea(
        child: viewModel.state.isLoading!
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: viewModel.refresh,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    _createUserInformation(context),
                    viewModel.state.isCurrentUser != true
                        ? _createFollowMessageButtons(context)
                        : const SizedBox.shrink(),
                    _createUserPostsGridView(context),
                    viewModel.state.isUpdating!
                        ? const LinearProgressIndicator()
                        : const SizedBox.shrink(),
                  ],
                )),
      ),
    );
  }

  static Widget create(Object? arg) {
    String? userId;
    if (arg != null && arg is String) userId = arg;
    return ChangeNotifierProvider<UserProfileViewModel>(
      create: (context) =>
          UserProfileViewModel(context: context, userId: userId),
      lazy: false,
      child: const UserProfileWidget(),
    );
  }

  Widget _createUserPostsGridView(BuildContext context) {
    var viewModel = context.watch<UserProfileViewModel>();

    return Expanded(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(1.0),
        controller: viewModel.lvc,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisSpacing: 1.0,
          mainAxisSpacing: 1.0,
          crossAxisCount: 3,
        ),
        itemCount: viewModel.state.userPosts!.length,
        itemBuilder: (_, index) {
          return _createPost(context, index);
        },
      ),
    );
  }

  Widget _createFollowMessageButtons(BuildContext context) {
    var viewModel = context.watch<UserProfileViewModel>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () => viewModel.changeSubscriptionStatePressed(),
          child: Text(viewModel.isSubscribedOn()),
        ),
        OutlinedButton(
            onPressed: () {
              //TODO переход в директ
            },
            child: const Text("Message")),
      ],
    );
  }

  Widget _createPost(BuildContext context, int index) {
    var viewModel = context.read<UserProfileViewModel>();

    return GestureDetector(
        onTap: () =>
            viewModel.postPressed(viewModel.state.userPosts![index].id!),
        child: Container(
          height: (MediaQuery.of(context).size.width / 3),
          width: (MediaQuery.of(context).size.width / 3),
          decoration: BoxDecoration(
            image: DecorationImage(
                image: Image.network(
                  "$baseUrl${viewModel.state.userPosts![index].postFiles![0]!.link}",
                  headers: viewModel.state.headers,
                ).image,
                fit: BoxFit.cover,
                alignment: Alignment.center),
          ),
        ));
  }

  Widget _createInformation(
          BuildContext context, String text, int? userStatistics) =>
      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
            alignment: Alignment.center,
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: fontSize,
              ),
            )),
        Container(
            alignment: Alignment.center,
            child: Text(
              userStatistics == null ? 0.toString() : userStatistics.toString(),
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: fontSize + 10,
              ),
            )),
      ]);

  Widget _createUserInformation(BuildContext context) {
    var viewModel = context.watch<UserProfileViewModel>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(10, 10, 5, 10),
          child: GestureDetector(
              onTap: () => viewModel.changePhoto(),
              child: CircleAvatar(
                backgroundColor: Colors.grey,
                foregroundImage: (viewModel.state.avatar != null)
                    ? viewModel.state.avatar!.image
                    : Image.asset(
                        "images/empty_image.png",
                      ).image,
                radius: MediaQuery.of(context).size.width / 7,
              )),
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _createInformation(context, "Post ",
                      viewModel.state.userStatistics?.userPostAmount),
                  _createInformation(context, "Followers ",
                      viewModel.state.userStatistics?.userSubscribersAmount),
                  _createInformation(context, "Followings ",
                      viewModel.state.userStatistics?.userSubscriptionsAmount),
                ],
              )),
        ),
      ],
    );
  }
}
