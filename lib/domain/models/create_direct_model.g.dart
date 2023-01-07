// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_direct_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateDirectModel _$CreateDirectModelFromJson(Map<String, dynamic> json) =>
    CreateDirectModel(
      id: json['id'] as String,
      title: json['title'] as String,
      userId: json['userId'] as String,
      directImage: json['directImage'] as String?,
    );

Map<String, dynamic> _$CreateDirectModelToJson(CreateDirectModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'directImage': instance.directImage,
    };
