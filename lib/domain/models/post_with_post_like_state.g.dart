// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_with_post_like_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostWithPostLikeState _$PostWithPostLikeStateFromJson(
        Map<String, dynamic> json) =>
    PostWithPostLikeState(
      id: json['id'] as String?,
      created: json['created'] as String?,
      text: json['text'] as String?,
      authorId: json['authorId'] as String?,
      postFiles: (json['postFiles'] as List<dynamic>?)
          ?.map((e) =>
              e == null ? null : PostFile.fromJson(e as Map<String, dynamic>))
          .toList(),
      authorAvatar: json['authorAvatar'] as String?,
      commentAmount: json['commentAmount'] as int?,
      likesAmount: json['likesAmount'] as int?,
      postLikeState: json['postLikeState'] as int? ?? 0,
    );

Map<String, dynamic> _$PostWithPostLikeStateToJson(
        PostWithPostLikeState instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created': instance.created,
      'text': instance.text,
      'authorId': instance.authorId,
      'postFiles': instance.postFiles,
      'authorAvatar': instance.authorAvatar,
      'commentAmount': instance.commentAmount,
      'likesAmount': instance.likesAmount,
      'postLikeState': instance.postLikeState,
    };
