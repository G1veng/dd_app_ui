import 'package:json_annotation/json_annotation.dart';

part 'meta_data_model.g.dart';

@JsonSerializable()
class MetaDataModel {
  final String tempId;
  final String name;
  final String mimeType;
  final int size;

  MetaDataModel({
    required this.tempId,
    required this.name,
    required this.mimeType,
    required this.size,
  });

  factory MetaDataModel.fromJson(Map<String, dynamic> json) =>
      _$MetaDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$MetaDataModelToJson(this);
}
