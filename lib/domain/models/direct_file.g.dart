// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'direct_file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DirectFile _$DirectFileFromJson(Map<String, dynamic> json) => DirectFile(
      id: json['id'] as String,
      messageId: json['messageId'] as String,
      link: json['link'] as String,
    );

Map<String, dynamic> _$DirectFileToJson(DirectFile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'link': instance.link,
      'messageId': instance.messageId,
    };
