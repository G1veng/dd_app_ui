import 'package:dd_app_ui/domain/db_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'direct.g.dart';

@JsonSerializable()
class Direct implements DbModel {
  @override
  final String id;
  final String title;
  final String? directImage;

  Direct({
    required this.id,
    required this.directImage,
    required this.title,
  });

  factory Direct.fromJson(Map<String, dynamic> json) => _$DirectFromJson(json);

  Map<String, dynamic> toJson() => _$DirectToJson(this);

  factory Direct.fromMap(Map<String, dynamic> map) => _$DirectFromJson(map);

  @override
  Map<String, dynamic> toMap() => _$DirectToJson(this);
}
