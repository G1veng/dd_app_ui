import 'package:dd_app_ui/internal/config/app_config.dart';
import 'package:dd_app_ui/ui/widgets/tab_direct/directs/directs_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DirectWidget extends StatelessWidget {
  const DirectWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<DirectViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Direct",
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () => {
                    //TODO создание директа
                  },
              icon: Icon(
                Icons.add,
                size: MediaQuery.of(context).size.width / 10,
              ))
        ],
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

  static Widget create() => ChangeNotifierProvider<DirectViewModel>(
        create: (context) => DirectViewModel(contex: context),
        lazy: false,
        child: const DirectWidget(),
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
      ));

  Widget _createGotoDirectButton(BuildContext context, int index) {
    //var viewModel = context.watch<DirectViewModel>();

    return IconButton(
        onPressed: () {
          //TODO переход в директ
        },
        icon: const Icon(Icons.arrow_circle_right_outlined));
  }

  Widget _createDirectImage(BuildContext context, int index) {
    var viewModel = context.watch<DirectViewModel>();

    return Container(
        margin: const EdgeInsets.only(right: 5),
        child: CircleAvatar(
          backgroundColor: Colors.grey,
          foregroundImage: Image.network(
            "$baseUrl${viewModel.state.directs![index].directImage.link}",
            headers: viewModel.state.headers,
          ).image,
          radius: MediaQuery.of(context).size.width / 10,
        ));
  }

  Widget _createDirectInfo(BuildContext context, int index) {
    var viewModel = context.watch<DirectViewModel>();

    return Expanded(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(viewModel.state.directs![index].directTitle,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            )),
        Text(
          viewModel.state.directMessages![index].isEmpty == true
              ? ""
              : viewModel.state.directMessages![index].first.directMessage,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ));
  }
}
