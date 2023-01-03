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
                _createPostImagesGridView(context),
                _createDescriptionField(context),
              ]));
  }

  static Widget create() => ChangeNotifierProvider<CreatePostViewModel>(
        create: (context) => CreatePostViewModel(context: context),
        lazy: false,
        child: const CreatePostWidget(),
      );

  Widget _createPostImagesGridView(BuildContext context) {
    var viewModel = context.watch<CreatePostViewModel>();
    var size = MediaQuery.of(context).size;

    return SizedBox(
      width: size.width,
      height: size.width,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisSpacing: 1.0,
          mainAxisSpacing: 1.0,
          crossAxisCount: 3,
        ),
        itemCount: viewModel.state.images == null
            ? 1
            : viewModel.state.images!.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return GestureDetector(
                onTap: viewModel.takePicture,
                child: Container(
                  margin: const EdgeInsets.all(0.5),
                  height: size.width / 3 - 1,
                  width: size.width / 3 - 1,
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20.0))),
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    child: Icon(
                      Icons.add,
                      size: size.width / 10,
                    ),
                  ),
                ));
          } else {
            return GestureDetector(
                onTap: () {}, //Сделать открытие картинки в полный экран
                child: Container(
                  margin: const EdgeInsets.all(0.5),
                  height: (MediaQuery.of(context).size.width / 3),
                  width: (MediaQuery.of(context).size.width / 3),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: viewModel.state.images![index - 1].image,
                        fit: BoxFit.cover,
                        alignment: Alignment.center),
                  ),
                ));
          }
        },
      ),
    );
  }

  Widget _createDescriptionField(BuildContext context) {
    var viewModel = context.watch<CreatePostViewModel>();

    return Container(
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
    );
  }
}
