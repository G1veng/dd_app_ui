import 'package:dd_app_ui/domain/db_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'direct_member.g.dart';

@JsonSerializable()
class DirectMember implements DbModel {
  @override
  final String id;
  final String userId;

  DirectMember({
    required this.id,
    required this.userId,
  });

  factory DirectMember.fromJson(Map<String, dynamic> json) =>
      _$DirectMemberFromJson(json);

  Map<String, dynamic> toJson() => _$DirectMemberToJson(this);

  factory DirectMember.fromMap(Map<String, dynamic> map) =>
      _$DirectMemberFromJson(map);

  @override
  Map<String, dynamic> toMap() => _$DirectMemberToJson(this);
}
