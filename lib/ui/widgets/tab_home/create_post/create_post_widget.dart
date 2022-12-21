import 'package:dd_app_ui/ui/widgets/tab_home/create_post/create_post_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreatePostWidget extends StatelessWidget {
  const CreatePostWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<CreatePostViewModel>();
    var size = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "New publication",
            overflow: TextOverflow.fade,
          ),
          leading: IconButton(
            onPressed: () => viewModel.close(),
            icon: const Icon(Icons.close),
          ),
          actions: [
            IconButton(
                onPressed: () => viewModel.createPost(),
                icon: const Icon(Icons.check))
          ],
        ),
        body: viewModel.state.isLoading == true
            ? const Center(child: CircularProgressIndicator())
            : ListView(children: [
                Column(
                  children: [
                    SizedBox(
                        width: size.width,
                        height: size.width,
                        child: ListView(
                          children: [
                            Wrap(children: viewModel.state.imagesWidgets!),
                          ],
                        )),
                    Container(
                      margin: const EdgeInsets.all(5.0),
                      child: TextFormField(
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        maxLength: 300,
                        maxLines: null,
                        keyboardType: TextInputType.text,
                        controller: viewModel.postText,
                        decoration: InputDecoration(
                            errorText: viewModel.postText.text.isEmpty
                                ? "Minimum is one symbol"
                                : null,
                            border: const OutlineInputBorder(),
                            hintText: "Enter post description"),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ],
                )
              ]));
  }

  static Widget create() => ChangeNotifierProvider<CreatePostViewModel>(
        create: (context) => CreatePostViewModel(context: context),
        lazy: false,
        child: const CreatePostWidget(),
      );
}
