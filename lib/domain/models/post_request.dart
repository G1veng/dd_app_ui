import 'package:dd_app_ui/domain/models/post_model_response.dart';
import 'package:json_annotation/json_annotation.dart';

part 'post_request.g.dart';

@JsonSerializable()
class PostRequest {
  final String id;
  final String created;
  final String text;
  final String authorId;
  final List<PostFile> postFiles;
  final String authorAvatar;
  final int commentAmount;
  final int likesAmount;

  PostRequest({
    required this.id,
    required this.created,
    required this.text,
    required this.authorId,
    required this.postFiles,
    required this.authorAvatar,
    required this.commentAmount,
    required this.likesAmount,
  });

  factory PostRequest.fromJson(Map<String, dynamic> json) =>
      _$PostRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PostRequestToJson(this);
}
