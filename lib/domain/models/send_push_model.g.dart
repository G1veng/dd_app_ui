// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_push_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SendPushModel _$SendPushModelFromJson(Map<String, dynamic> json) =>
    SendPushModel(
      userId: json['userId'] as String?,
      push: Push.fromJson(json['push'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SendPushModelToJson(SendPushModel instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'push': instance.push,
    };

Push _$PushFromJson(Map<String, dynamic> json) => Push(
      badge: json['badge'] as int?,
      sound: json['sound'] as String?,
      alert: Alert.fromJson(json['alert'] as Map<String, dynamic>),
      customData:
          CustomData.fromJson(json['customData'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PushToJson(Push instance) => <String, dynamic>{
      'badge': instance.badge,
      'sound': instance.sound,
      'alert': instance.alert,
      'customData': instance.customData,
    };

Alert _$AlertFromJson(Map<String, dynamic> json) => Alert(
      title: json['title'] as String?,
      subtitle: json['subtitle'] as String?,
      body: json['body'] as String?,
    );

Map<String, dynamic> _$AlertToJson(Alert instance) => <String, dynamic>{
      'title': instance.title,
      'subtitle': instance.subtitle,
      'body': instance.body,
    };

CustomData _$CustomDataFromJson(Map<String, dynamic> json) => CustomData(
      additionalProp1: json['additionalProp1'] as String,
      additionalProp2: json['additionalProp2'] as String,
      additionalProp3: json['additionalProp3'] as String,
    );

Map<String, dynamic> _$CustomDataToJson(CustomData instance) =>
    <String, dynamic>{
      'additionalProp1': instance.additionalProp1,
      'additionalProp2': instance.additionalProp2,
      'additionalProp3': instance.additionalProp3,
    };
