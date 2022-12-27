import 'package:dd_app_ui/ui/widgets/tab_current_user_profile/current_user_profile_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dd_app_ui/domain/icons_images/icons_icons.dart';

class CurrentUserProfileWidget extends StatelessWidget {
  static const double fontSize = 12;

  const CurrentUserProfileWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<CurrentUserProfileViewModel>();

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
          child: GestureDetector(
            child: Column(
              children: <Widget>[
                IntrinsicHeight(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(10, 10, 5, 10),
                      child: GestureDetector(
                          onTap: viewModel.changePhoto,
                          child: CircleAvatar(
                            backgroundColor: Colors.grey,
                            foregroundImage: (viewModel.state.headers != null &&
                                    viewModel.state.avatar != null)
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              createInformation(
                                  "Post ",
                                  viewModel
                                      .state.userStatistics?.userPostAmount),
                              createInformation(
                                  "Followers ",
                                  viewModel.state.userStatistics
                                      ?.userSubscribersAmount),
                              createInformation(
                                  "Followings ",
                                  viewModel.state.userStatistics
                                      ?.userSubscriptionsAmount),
                            ],
                          )),
                    ),
                  ],
                )),
                if (viewModel.isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                NotificationListener<ScrollNotification>(
                    onNotification: (scrollNotification) {
                      if (scrollNotification is ScrollEndNotification) {
                        if (!viewModel.isDelay) {
                          viewModel.startDelay();
                          viewModel.requestNextPosts();
                        }
                        return true;
                      }
                      return false;
                    },
                    child: SingleChildScrollView(
                      child: Wrap(
                        runSpacing: 2.0,
                        spacing: 2.0,
                        children: viewModel.allImages,
                      ),
                    )),
              ],
            ),
            onVerticalDragUpdate: (details) =>
                details.delta.distance > 10.0 ? viewModel.updateScreen() : null,
          ),
        ));
  }

  Widget createInformation(String text, int? userStatistics) => Expanded(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
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
      ]));

  static Widget create() => ChangeNotifierProvider<CurrentUserProfileViewModel>(
        create: (context) => CurrentUserProfileViewModel(context: context),
        lazy: false,
        child: const CurrentUserProfileWidget(),
      );
}
