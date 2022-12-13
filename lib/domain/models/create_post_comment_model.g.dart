// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_post_comment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreatePostCommentModel _$CreatePostCommentModelFromJson(
        Map<String, dynamic> json) =>
    CreatePostCommentModel(
      id: json['id'] as String,
      postId: json['postId'] as String,
      text: json['text'] as String,
      created: json['created'] as String,
    );

Map<String, dynamic> _$CreatePostCommentModelToJson(
        CreatePostCommentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'postId': instance.postId,
      'text': instance.text,
      'created': instance.created,
    };
