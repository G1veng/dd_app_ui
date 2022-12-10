import 'package:dd_app_ui/domain/db_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'post.g.dart';

@JsonSerializable()
class Post implements DbModel {
  @override
  final String? id;
  final String? created;
  final String? text;
  final String? authorId;
  final String? authorAvatar;
  final int? commentAmount;
  final int? likesAmount;

  Post({
    required this.id,
    required this.created,
    required this.text,
    required this.authorId,
    required this.authorAvatar,
    required this.commentAmount,
    required this.likesAmount,
  });

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);

  Map<String, dynamic> toJson() => _$PostToJson(this);

  factory Post.fromMap(Map<String, dynamic> map) => _$PostFromJson(map);

  @override
  Map<String, dynamic> toMap() => _$PostToJson(this);
}
