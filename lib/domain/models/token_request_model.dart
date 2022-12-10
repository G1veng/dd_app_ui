import "package:json_annotation/json_annotation.dart";

part "token_request_model.g.dart";

@JsonSerializable()
class TokenRequestModel {
  final String login;
  final String password;

  TokenRequestModel({
    required this.login,
    required this.password,
  });

  factory TokenRequestModel.fromJson(Map<String, dynamic> json) =>
      _$TokenRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$TokenRequestModelToJson(this);
}
