// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'direct_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DirectModel _$DirectModelFromJson(Map<String, dynamic> json) => DirectModel(
      directId: json['directId'] as String,
      directTitle: json['directTitle'] as String,
      directMembers: (json['directMembers'] as List<dynamic>)
          .map((e) => DirectMember.fromJson(e as Map<String, dynamic>))
          .toList(),
      directImage:
          DirectImage.fromJson(json['directImage'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DirectModelToJson(DirectModel instance) =>
    <String, dynamic>{
      'directId': instance.directId,
      'directTitle': instance.directTitle,
      'directMembers': instance.directMembers,
      'directImage': instance.directImage,
    };

DirectImage _$DirectImageFromJson(Map<String, dynamic> json) => DirectImage(
      link: json['link'] as String,
    );

Map<String, dynamic> _$DirectImageToJson(DirectImage instance) =>
    <String, dynamic>{
      'link': instance.link,
    };

DirectMember _$DirectMemberFromJson(Map<String, dynamic> json) => DirectMember(
      directMember: json['directMember'] as String,
    );

Map<String, dynamic> _$DirectMemberToJson(DirectMember instance) =>
    <String, dynamic>{
      'directMember': instance.directMember,
    };
