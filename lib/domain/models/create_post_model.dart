import 'package:dd_app_ui/domain/models/meta_data_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_post_model.g.dart';

@JsonSerializable()
class CreatePostModel {
  final String id;
  final String text;
  final List<MetaDataModel> files;
  final String created;

  CreatePostModel({
    required this.id,
    required this.text,
    required this.files,
    required this.created,
  });

  factory CreatePostModel.fromJson(Map<String, dynamic> json) =>
      _$CreatePostModelFromJson(json);

  Map<String, dynamic> toJson() => _$CreatePostModelToJson(this);
}
