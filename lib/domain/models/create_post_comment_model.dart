import 'package:json_annotation/json_annotation.dart';

part 'create_post_comment_model.g.dart';

@JsonSerializable()
class CreatePostCommentModel {
  final String id;
  final String postId;
  final String text;
  final String created;

  CreatePostCommentModel({
    required this.id,
    required this.postId,
    required this.text,
    required this.created,
  });

  factory CreatePostCommentModel.fromJson(Map<String, dynamic> json) =>
      _$CreatePostCommentModelFromJson(json);

  Map<String, dynamic> toJson() => _$CreatePostCommentModelToJson(this);
}
