import 'package:dd_app_ui/domain/db_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_statistics.g.dart';

@JsonSerializable()
class UserStatistics implements DbModel {
  @override
  final String id;
  final int userPostAmount;
  final int userSubscribersAmount;
  final int userSubscriptionsAmount;

  UserStatistics(
      {required this.id,
      required this.userPostAmount,
      required this.userSubscribersAmount,
      required this.userSubscriptionsAmount});

  factory UserStatistics.fromJson(Map<String, dynamic> json) =>
      _$UserStatisticsFromJson(json);

  Map<String, dynamic> toJson() => _$UserStatisticsToJson(this);

  factory UserStatistics.fromMap(Map<String, dynamic> map) =>
      _$UserStatisticsFromJson(map);

  @override
  Map<String, dynamic> toMap() => _$UserStatisticsToJson(this);
}
