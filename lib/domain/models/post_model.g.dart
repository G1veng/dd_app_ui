// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostModel _$PostModelFromJson(Map<String, dynamic> json) => PostModel(
      id: json['id'] as String?,
      created: json['created'] as String?,
      text: json['text'] as String?,
      authorId: json['authorId'] as String?,
      postFiles: (json['postFiles'] as List<dynamic>?)
          ?.map((e) =>
              e == null ? null : PostFile.fromJson(e as Map<String, dynamic>))
          .toList(),
      authorAvatar: json['authorAvatar'] as String?,
      commentAmount: json['commentAmount'] as int?,
      likesAmount: json['likesAmount'] as int?,
    );

Map<String, dynamic> _$PostModelToJson(PostModel instance) => <String, dynamic>{
      'id': instance.id,
      'created': instance.created,
      'text': instance.text,
      'authorId': instance.authorId,
      'postFiles': instance.postFiles,
      'authorAvatar': instance.authorAvatar,
      'commentAmount': instance.commentAmount,
      'likesAmount': instance.likesAmount,
    };
