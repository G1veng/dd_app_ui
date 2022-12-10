// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Post _$PostFromJson(Map<String, dynamic> json) => Post(
      id: json['id'] as String?,
      created: json['created'] as String?,
      text: json['text'] as String?,
      authorId: json['authorId'] as String?,
      authorAvatar: json['authorAvatar'] as String?,
      commentAmount: json['commentAmount'] as int?,
      likesAmount: json['likesAmount'] as int?,
    );

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
      'id': instance.id,
      'created': instance.created,
      'text': instance.text,
      'authorId': instance.authorId,
      'authorAvatar': instance.authorAvatar,
      'commentAmount': instance.commentAmount,
      'likesAmount': instance.likesAmount,
    };
