import 'package:json_annotation/json_annotation.dart';

part 'direct_model.g.dart';

@JsonSerializable()
class DirectModel {
  final String directId;
  String directTitle;
  List<DirectMember> directMembers;
  DirectImage? directImage;

  DirectModel({
    required this.directId,
    required this.directTitle,
    required this.directMembers,
    this.directImage,
  });

  factory DirectModel.fromJson(Map<String, dynamic> json) =>
      _$DirectModelFromJson(json);

  Map<String, dynamic> toJson() => _$DirectModelToJson(this);
}

@JsonSerializable()
class DirectImage {
  String id;
  String link;

  DirectImage({
    required this.id,
    required this.link,
  });

  factory DirectImage.fromJson(Map<String, dynamic> json) =>
      _$DirectImageFromJson(json);

  Map<String, dynamic> toJson() => _$DirectImageToJson(this);
}

@JsonSerializable()
class DirectMember {
  final String directMember;

  DirectMember({
    required this.directMember,
  });

  factory DirectMember.fromJson(Map<String, dynamic> json) =>
      _$DirectMemberFromJson(json);

  Map<String, dynamic> toJson() => _$DirectMemberToJson(this);
}
