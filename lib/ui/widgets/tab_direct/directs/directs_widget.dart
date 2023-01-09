import 'package:dd_app_ui/internal/config/app_config.dart';
import 'package:dd_app_ui/ui/widgets/tab_direct/directs/directs_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DirectsWidget extends StatelessWidget {
  const DirectsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<DirectsViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Direct",
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
      ),
      body: viewModel.state.isLoading == false
          ? RefreshIndicator(
              onRefresh: viewModel.refresh,
              child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: viewModel.lvc,
                  itemBuilder: (_, index) {
                    if (index == viewModel.state.directs!.length - 1 &&
                        viewModel.state.isUpdating == true) {
                      return Column(
                        children: [
                          _createDirectRow(context, index),
                          const LinearProgressIndicator()
                        ],
                      );
                    }
                    return _createDirectRow(context, index);
                  },
                  separatorBuilder: (context, index) => const Divider(),
                  itemCount: viewModel.state.directs!.length))
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  static Widget create() => ChangeNotifierProvider<DirectsViewModel>(
        create: (context) => DirectsViewModel(context: context),
        lazy: false,
        child: const DirectsWidget(),
      );

  Widget _createDirectRow(BuildContext context, int index) => Container(
        margin: const EdgeInsets.all(5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: Row(children: [
              _createDirectImage(context, index),
              _createDirectInfo(context, index),
            ])),
            _createGotoDirectButton(context, index),
          ],
        ),
      );

  Widget _createGotoDirectButton(BuildContext context, int index) {
    var viewModel = context.watch<DirectsViewModel>();

    return IconButton(
        onPressed: () {
          viewModel.pressedGoToDirect(
              directId: viewModel.state.directs![index].id);
        },
        icon: const Icon(Icons.arrow_circle_right_outlined));
  }

  Widget _createDirectImage(BuildContext context, int index) {
    var viewModel = context.watch<DirectsViewModel>();

    return Container(
        margin: const EdgeInsets.only(right: 5),
        child: CircleAvatar(
          backgroundColor: Colors.grey,
          foregroundImage: viewModel.state.directs![index].directImage != null
              ? Image.network(
                  "$baseUrl${viewModel.state.directs![index].directImage}",
                  headers: viewModel.state.headers,
                ).image
              : Image.asset(
                  "images/empty_image.png",
                ).image,
          radius: MediaQuery.of(context).size.width / 10,
        ));
  }

  Widget _createDirectInfo(BuildContext context, int index) {
    var viewModel = context.watch<DirectsViewModel>();

    return Expanded(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(viewModel.state.directs![index].title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            )),
        Text(
          viewModel.state.directMessages![index].isEmpty == true
              ? ""
              : viewModel.state.directMessages![index].first.directMessage ??
                  "Picture",
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ));
  }
}
