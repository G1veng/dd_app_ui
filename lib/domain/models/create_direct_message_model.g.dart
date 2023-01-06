// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_direct_message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateDirectMessageModel _$CreateDirectMessageModelFromJson(
        Map<String, dynamic> json) =>
    CreateDirectMessageModel(
      directId: json['directId'] as String,
      message: json['message'] as String?,
      files: (json['files'] as List<dynamic>?)
          ?.map((e) => FileElement.fromJson(e as Map<String, dynamic>))
          .toList(),
      directMessageId: json['directMessageId'] as String?,
      sended: json['sended'] as String?,
    );

Map<String, dynamic> _$CreateDirectMessageModelToJson(
        CreateDirectMessageModel instance) =>
    <String, dynamic>{
      'directId': instance.directId,
      'message': instance.message,
      'files': instance.files,
      'directMessageId': instance.directMessageId,
      'sended': instance.sended,
    };

FileElement _$FileElementFromJson(Map<String, dynamic> json) => FileElement(
      tempId: json['tempId'] as String,
      name: json['name'] as String,
      mimeType: json['mimeType'] as String,
      size: json['size'] as int,
    );

Map<String, dynamic> _$FileElementToJson(FileElement instance) =>
    <String, dynamic>{
      'tempId': instance.tempId,
      'name': instance.name,
      'mimeType': instance.mimeType,
      'size': instance.size,
    };
