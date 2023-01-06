import 'package:dd_app_ui/domain/db_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'direct_file.g.dart';

@JsonSerializable()
class DirectFile implements DbModel {
  @override
  final String id;
  final String link;
  final String messageId;

  DirectFile({
    required this.id,
    required this.messageId,
    required this.link,
  });

  factory DirectFile.fromJson(Map<String, dynamic> json) =>
      _$DirectFileFromJson(json);

  Map<String, dynamic> toJson() => _$DirectFileToJson(this);

  factory DirectFile.fromMap(Map<String, dynamic> map) =>
      _$DirectFileFromJson(map);

  @override
  Map<String, dynamic> toMap() => _$DirectFileToJson(this);
}
