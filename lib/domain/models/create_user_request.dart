import 'package:json_annotation/json_annotation.dart';

part 'create_user_request.g.dart';

@JsonSerializable()
class CreateUserRequest {
  final String name;
  final String email;
  final String password;
  final String retryPassword;
  final String birthDate;

  CreateUserRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.retryPassword,
    required this.birthDate,
  });

  factory CreateUserRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateUserRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateUserRequestToJson(this);
}
