import 'package:json_annotation/json_annotation.dart';

part 'create_user_request_model.g.dart';

@JsonSerializable()
class CreateUserRequestModel {
  final String name;
  final String email;
  final String password;
  final String retryPassword;
  final String birthDate;

  CreateUserRequestModel({
    required this.name,
    required this.email,
    required this.password,
    required this.retryPassword,
    required this.birthDate,
  });

  factory CreateUserRequestModel.fromJson(Map<String, dynamic> json) =>
      _$CreateUserRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$CreateUserRequestModelToJson(this);
}
