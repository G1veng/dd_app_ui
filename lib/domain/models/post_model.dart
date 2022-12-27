import 'package:dd_app_ui/domain/models/post_file.dart';
import 'package:json_annotation/json_annotation.dart';

part 'post_model.g.dart';

@JsonSerializable()
class PostModel {
  final String? id;
  final String? created;
  final String? text;
  final String? authorId;
  final List<PostFile>? postFiles;
  final String? authorAvatar;
  final int? commentAmount;
  final int? likesAmount;

  PostModel({
    required this.id,
    required this.created,
    required this.text,
    required this.authorId,
    required this.postFiles,
    required this.authorAvatar,
    required this.commentAmount,
    required this.likesAmount,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) =>
      _$PostModelFromJson(json);

  Map<String, dynamic> toJson() => _$PostModelToJson(this);
}
