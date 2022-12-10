// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostFile _$PostFileFromJson(Map<String, dynamic> json) => PostFile(
      postId: json['postId'] as String,
      id: json['id'] as String,
      name: json['name'] as String,
      mimeType: json['mimeType'] as String,
      link: json['link'] as String,
    );

Map<String, dynamic> _$PostFileToJson(PostFile instance) => <String, dynamic>{
      'id': instance.id,
      'postId': instance.postId,
      'name': instance.name,
      'mimeType': instance.mimeType,
      'link': instance.link,
    };
