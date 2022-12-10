// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_user_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateUserRequestModel _$CreateUserRequestModelFromJson(
        Map<String, dynamic> json) =>
    CreateUserRequestModel(
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      retryPassword: json['retryPassword'] as String,
      birthDate: json['birthDate'] as String,
    );

Map<String, dynamic> _$CreateUserRequestModelToJson(
        CreateUserRequestModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'password': instance.password,
      'retryPassword': instance.retryPassword,
      'birthDate': instance.birthDate,
    };
