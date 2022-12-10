// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_statistics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserStatistics _$UserStatisticsFromJson(Map<String, dynamic> json) =>
    UserStatistics(
      id: json['id'] as String,
      userPostAmount: json['userPostAmount'] as int,
      userSubscribersAmount: json['userSubscribersAmount'] as int,
      userSubscriptionsAmount: json['userSubscriptionsAmount'] as int,
    );

Map<String, dynamic> _$UserStatisticsToJson(UserStatistics instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userPostAmount': instance.userPostAmount,
      'userSubscribersAmount': instance.userSubscribersAmount,
      'userSubscriptionsAmount': instance.userSubscriptionsAmount,
    };
