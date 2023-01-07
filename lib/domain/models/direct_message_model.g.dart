// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'direct_message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DirectMessageModel _$DirectMessageModelFromJson(Map<String, dynamic> json) =>
    DirectMessageModel(
      directMessageId: json['directMessageId'] as String,
      directMessage: json['directMessage'] as String?,
      sended: json['sended'] as String,
      senderId: json['senderId'] as String,
      directFiles: (json['directFiles'] as List<dynamic>?)
          ?.map((e) => DirectFile.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DirectMessageModelToJson(DirectMessageModel instance) =>
    <String, dynamic>{
      'directMessageId': instance.directMessageId,
      'directMessage': instance.directMessage,
      'sended': instance.sended,
      'senderId': instance.senderId,
      'directFiles': instance.directFiles,
    };

DirectFile _$DirectFileFromJson(Map<String, dynamic> json) => DirectFile(
      link: json['link'] as String,
      id: json['id'] as String,
    );

Map<String, dynamic> _$DirectFileToJson(DirectFile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'link': instance.link,
    };
