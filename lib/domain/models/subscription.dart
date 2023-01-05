import 'package:dd_app_ui/domain/db_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'subscription.g.dart';

@JsonSerializable()
class Subscription implements DbModel {
  @override
  final String id;
  final String subscriberId;

  Subscription({
    required this.id,
    required this.subscriberId,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionToJson(this);

  factory Subscription.fromMap(Map<String, dynamic> map) =>
      _$SubscriptionFromJson(map);

  @override
  Map<String, dynamic> toMap() => _$SubscriptionToJson(this);
}
