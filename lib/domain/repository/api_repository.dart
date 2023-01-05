import 'dart:io';

import 'package:dd_app_ui/domain/models/create_post_comment_model.dart';
import 'package:dd_app_ui/domain/models/create_post_model.dart';
import 'package:dd_app_ui/domain/models/direct_message_model.dart';
import 'package:dd_app_ui/domain/models/direct_model.dart';
import 'package:dd_app_ui/domain/models/meta_data_model.dart';
import 'package:dd_app_ui/domain/models/post_comment.dart';
import 'package:dd_app_ui/domain/models/post_model.dart';
import 'package:dd_app_ui/domain/models/push_token_model.dart';
import 'package:dd_app_ui/domain/models/token_response_model.dart';
import 'package:dd_app_ui/domain/models/user.dart';
import 'package:dd_app_ui/domain/models/user_model.dart';

abstract class ApiRepository {
  Future<TokenResponseModel?> getToken(
      {required String login, required String password});
  Future<TokenResponseModel?> refreshToken({required String refreshToken});
  Future<User?> getUser();
  Future<int> getUserPostAmount(String? userId);
  Future<int> getUserSubscribersAmount(String? userId);
  Future<int> getUserSubscriptionsAmount(String? userId);
  Future<List<PostModel>?> getCurrentUserPosts(
      String? lastPostCreated, int take, int skip);
  Future<List<UserModel>?> getUsers(int take, int skip);
  Future<List<PostModel>?> getSubscriptionsPosts(
      String? lastPostCreated, int take, int skip);
  Future createUser({
    required name,
    required email,
    required password,
    required retryPassword,
    required birthDate,
    required created,
    required id,
  });
  Future<PostModel?> getPost({required String postId});
  Future<bool> getPostLikeState({required String postId});
  Future changePostLikeState({required String postId});
  Future<UserModel?> getUserById({required String userId});
  Future<List<PostComment>?> getPostComments(
      {required String? lastPostCreated,
      required String postId,
      required int take,
      required int skip});
  Future createPostComment({required CreatePostCommentModel model});
  Future<List<MetaDataModel>?> uploadFiles({required List<File> files});
  Future addUserAvatar({required MetaDataModel model});
  Future createPost({required CreatePostModel model});
  Future changeSubscriptionStateOnUser({required String userId});
  Future<bool> isSubscribedOn({required String userId});
  Future subscribe({required PushTokenModel model});
  Future unsubscribe();
  Future<List<PostModel>?> getPosts({
    required String? lastPostCreated,
    required String userId,
    required int take,
    required int skip,
  });
  Future<List<DirectModel>?> getUserDirects({
    required int take,
    required int skip,
  });
  Future<List<DirectMessageModel>?> getDirectMessages({
    required String? lastDirectMessageCreated,
    required String directId,
    required int take,
    required int skip,
  });
}
