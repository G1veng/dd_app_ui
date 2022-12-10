// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TokenRequestModel _$TokenRequestModelFromJson(Map<String, dynamic> json) =>
    TokenRequestModel(
      login: json['login'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$TokenRequestModelToJson(TokenRequestModel instance) =>
    <String, dynamic>{
      'login': instance.login,
      'password': instance.password,
    };
