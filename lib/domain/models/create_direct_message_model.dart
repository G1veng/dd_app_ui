import 'package:json_annotation/json_annotation.dart';

part 'create_direct_message_model.g.dart';

@JsonSerializable()
class CreateDirectMessageModel {
  final String directId;
  final String? message;
  final List<FileElement>? files;
  final String? directMessageId;
  final String? sended;

  CreateDirectMessageModel({
    required this.directId,
    this.message,
    this.files,
    this.directMessageId,
    this.sended,
  });

  factory CreateDirectMessageModel.fromJson(Map<String, dynamic> json) =>
      _$CreateDirectMessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$CreateDirectMessageModelToJson(this);
}

@JsonSerializable()
class FileElement {
  final String tempId;
  final String name;
  final String mimeType;
  final int size;

  FileElement({
    required this.tempId,
    required this.name,
    required this.mimeType,
    required this.size,
  });

  factory FileElement.fromJson(Map<String, dynamic> json) =>
      _$FileElementFromJson(json);

  Map<String, dynamic> toJson() => _$FileElementToJson(this);
}
