import 'package:dd_app_ui/domain/db_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'post_comment.g.dart';

@JsonSerializable()
class PostComment implements DbModel {
  @override
  final String id;
  final String text;
  final String created;
  final int likes;
  final String authorId;
  final String postId;

  PostComment({
    required this.id,
    required this.text,
    required this.created,
    required this.likes,
    required this.authorId,
    required this.postId,
  });

  factory PostComment.fromJson(Map<String, dynamic> json) =>
      _$PostCommentFromJson(json);

  Map<String, dynamic> toJson() => _$PostCommentToJson(this);

  factory PostComment.fromMap(Map<String, dynamic> map) =>
      _$PostCommentFromJson(map);

  @override
  Map<String, dynamic> toMap() => _$PostCommentToJson(this);
}
