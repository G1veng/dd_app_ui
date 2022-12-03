// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_model_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostModelResponse _$PostModelResponseFromJson(Map<String, dynamic> json) =>
    PostModelResponse(
      id: json['id'] as String?,
      created: json['created'] as String?,
      text: json['text'] as String?,
      authorId: json['authorId'] as String?,
      postFiles: (json['postFiles'] as List<dynamic>?)
          ?.map((e) => PostFile.fromJson(e as Map<String, dynamic>))
          .toList(),
      authorAvatar: json['authorAvatar'] as String?,
      commentAmount: json['commentAmount'] as int?,
      likesAmount: json['likesAmount'] as int?,
    );

Map<String, dynamic> _$PostModelResponseToJson(PostModelResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created': instance.created,
      'text': instance.text,
      'authorId': instance.authorId,
      'postFiles': instance.postFiles,
      'authorAvatar': instance.authorAvatar,
      'commentAmount': instance.commentAmount,
      'likesAmount': instance.likesAmount,
    };

PostFile _$PostFileFromJson(Map<String, dynamic> json) => PostFile(
      link: json['link'] as String?,
    );

Map<String, dynamic> _$PostFileToJson(PostFile instance) => <String, dynamic>{
      'link': instance.link,
    };
