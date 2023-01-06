// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'direct_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DirectMessage _$DirectMessageFromJson(Map<String, dynamic> json) =>
    DirectMessage(
      id: json['id'] as String,
      directMessage: json['directMessage'] as String?,
      directId: json['directId'] as String,
      sended: json['sended'] as String,
      senderId: json['senderId'] as String,
    );

Map<String, dynamic> _$DirectMessageToJson(DirectMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'directId': instance.directId,
      'directMessage': instance.directMessage,
      'sended': instance.sended,
      'senderId': instance.senderId,
    };
