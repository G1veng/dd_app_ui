import 'package:dd_app_ui/domain/db_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'direct_message.g.dart';

@JsonSerializable()
class DirectMessage implements DbModel {
  @override
  final String id;
  final String directId;
  final String? directMessage;
  final String sended;
  final String senderId;

  DirectMessage({
    required this.id,
    required this.directMessage,
    required this.directId,
    required this.sended,
    required this.senderId,
  });

  factory DirectMessage.fromJson(Map<String, dynamic> json) =>
      _$DirectMessageFromJson(json);

  Map<String, dynamic> toJson() => _$DirectMessageToJson(this);

  factory DirectMessage.fromMap(Map<String, dynamic> map) =>
      _$DirectMessageFromJson(map);

  @override
  Map<String, dynamic> toMap() => _$DirectMessageToJson(this);
}
