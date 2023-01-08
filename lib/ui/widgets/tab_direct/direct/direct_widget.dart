import 'package:dd_app_ui/internal/config/app_config.dart';
import 'package:dd_app_ui/ui/widgets/tab_direct/direct/direct_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DirectWidget extends StatelessWidget {
  const DirectWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<DirectViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(viewModel.state.directTitle ?? ""),
        centerTitle: true,
      ),
      body: viewModel.state.isLoading == false
          ? Column(children: [
              viewModel.state.isUpdating == false
                  ? _createDirectMessages(context)
                  : const Center(child: CircularProgressIndicator()),
              _createFieldAddComment(context),
            ])
          : const Center(child: CircularProgressIndicator()),
    );
  }

  static Widget create({required BuildContext context, required Object? arg}) {
    String? directId;
    if (arg != null && arg is String) {
      directId = arg;
    }

    return ChangeNotifierProvider<DirectViewModel>(
      create: (context) =>
          DirectViewModel(context: context, directId: directId!),
      lazy: false,
      child: const DirectWidget(),
    );
  }

  Widget _createDirectMessages(BuildContext context) {
    var viewModel = context.watch<DirectViewModel>();
    //bool isCurrentUser =

    return Expanded(
        child: ListView.builder(
      reverse: true,
      itemBuilder: (_, index) {
        bool isCurrentUser = viewModel.state.directMessages?[index].senderId ==
            viewModel.state.currentUser!.id;

        return Container(
            margin: const EdgeInsets.all(5),
            child: Row(
              mainAxisAlignment: isCurrentUser
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                !isCurrentUser
                    ? _createUserPucture(context, index)
                    : const SizedBox.shrink(),
                SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: Text(
                      viewModel.state.directMessages?[index].directMessage ??
                          "",
                      textAlign:
                          isCurrentUser ? TextAlign.end : TextAlign.start,
                    ))
              ],
            ));
      },
      itemCount: viewModel.state.directMessages == null
          ? 0
          : viewModel.state.directMessages!.length,
    ));
  }

  Widget _createUserPucture(BuildContext context, int index) {
    var viewModel = context.watch<DirectViewModel>();
    var avatar = viewModel
        .state.membersAvatars![viewModel.state.directMessages![index].senderId];

    return Container(
        margin: const EdgeInsets.only(right: 5),
        child: CircleAvatar(
          backgroundColor: Colors.grey,
          foregroundImage: avatar != null
              ? Image.network(
                  "$baseUrl$avatar",
                  headers: viewModel.state.headers,
                ).image
              : Image.asset(
                  "images/empty_image.png",
                ).image,
          radius: MediaQuery.of(context).size.width / 20,
        ));
  }

  Widget _createFieldAddComment(BuildContext context) {
    var viewModel = context.watch<DirectViewModel>();

    return Container(
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Flexible(
                child: TextField(
              maxLength: 1000,
              textCapitalization: TextCapitalization.sentences,
              textAlignVertical: TextAlignVertical.center,
              controller: viewModel.createMessageTec,
              maxLines: null,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.fromLTRB(5, 15, 5, 15),
                filled: true,
                fillColor: Colors.blue[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                hintText: "Message...",
                counterText: "",
              ),
              textAlign: TextAlign.start,
            )),
            Container(
                margin: const EdgeInsets.all(5.0),
                child: ElevatedButton(
                    onPressed: viewModel.state.createMessageText != null &&
                            viewModel.state.createMessageText!.isNotEmpty
                        ? viewModel.createMessage
                        : null,
                    child: const Icon(Icons.send)))
          ],
        ));
  }
}
