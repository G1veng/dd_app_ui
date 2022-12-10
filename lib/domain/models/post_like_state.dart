import 'package:dd_app_ui/domain/db_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'post_like_state.g.dart';

@JsonSerializable()
class PostLikeState implements DbModel {
  @override
  final String id;
  final int isLiked;

  PostLikeState({
    required this.id,
    required this.isLiked,
  });

  factory PostLikeState.fromJson(Map<String, dynamic> json) =>
      _$PostLikeStateFromJson(json);

  Map<String, dynamic> toJson() => _$PostLikeStateToJson(this);

  factory PostLikeState.fromMap(Map<String, dynamic> map) =>
      _$PostLikeStateFromJson(map);

  @override
  Map<String, dynamic> toMap() => _$PostLikeStateToJson(this);
}
