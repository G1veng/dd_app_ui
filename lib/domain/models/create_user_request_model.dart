import 'package:json_annotation/json_annotation.dart';

part 'create_user_request_model.g.dart';

@JsonSerializable()
class CreateUserRequestModel {
  final String id;
  final String name;
  final String email;
  final String password;
  final String retryPassword;
  final String birthDate;
  final String created;

  CreateUserRequestModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.retryPassword,
    required this.birthDate,
    required this.created,
  });

  factory CreateUserRequestModel.fromJson(Map<String, dynamic> json) =>
      _$CreateUserRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$CreateUserRequestModelToJson(this);
}
