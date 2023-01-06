// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'direct.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Direct _$DirectFromJson(Map<String, dynamic> json) => Direct(
      id: json['id'] as String,
      directImage: json['directImage'] as String?,
      title: json['title'] as String,
    );

Map<String, dynamic> _$DirectToJson(Direct instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'directImage': instance.directImage,
    };
