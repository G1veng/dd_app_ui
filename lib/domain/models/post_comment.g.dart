// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostComment _$PostCommentFromJson(Map<String, dynamic> json) => PostComment(
      id: json['id'] as String,
      text: json['text'] as String,
      created: json['created'] as String,
      likes: json['likes'] as int,
      authorId: json['authorId'] as String,
      postId: json['postId'] as String,
    );

Map<String, dynamic> _$PostCommentToJson(PostComment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'created': instance.created,
      'likes': instance.likes,
      'authorId': instance.authorId,
      'postId': instance.postId,
    };
