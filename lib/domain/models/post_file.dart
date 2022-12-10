import 'package:dd_app_ui/domain/db_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'post_file.g.dart';

@JsonSerializable()
class PostFile implements DbModel {
  @override
  final String id;
  final String postId;
  final String name;
  final String mimeType;
  final String link;

  PostFile({
    required this.postId,
    required this.id,
    required this.name,
    required this.mimeType,
    required this.link,
  });

  factory PostFile.fromJson(Map<String, dynamic> json) =>
      _$PostFileFromJson(json);

  Map<String, dynamic> toJson() => _$PostFileToJson(this);

  factory PostFile.fromMap(Map<String, dynamic> map) => _$PostFileFromJson(map);

  @override
  Map<String, dynamic> toMap() => _$PostFileToJson(this);
}
