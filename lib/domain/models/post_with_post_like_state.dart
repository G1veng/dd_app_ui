import 'package:dd_app_ui/domain/db_model.dart';
import 'package:dd_app_ui/domain/models/post_file.dart';
import 'package:json_annotation/json_annotation.dart';

part 'post_with_post_like_state.g.dart';

@JsonSerializable()
class PostWithPostLikeState implements DbModel {
  @override
  final String? id;
  final String? created;
  final String? text;
  final String? authorId;
  final List<PostFile?>? postFiles;
  final String? authorAvatar;
  final int? commentAmount;
  final int? likesAmount;
  final int? postLikeState;

  PostWithPostLikeState({
    required this.id,
    required this.created,
    required this.text,
    required this.authorId,
    required this.postFiles,
    required this.authorAvatar,
    required this.commentAmount,
    required this.likesAmount,
    this.postLikeState = 0,
  });

  factory PostWithPostLikeState.fromJson(Map<String, dynamic> json) =>
      _$PostWithPostLikeStateFromJson(json);

  Map<String, dynamic> toJson() => _$PostWithPostLikeStateToJson(this);

  factory PostWithPostLikeState.fromMap(Map<String, dynamic> map) =>
      _$PostWithPostLikeStateFromJson(map);

  @override
  Map<String, dynamic> toMap() => _$PostWithPostLikeStateToJson(this);
}
