import 'dart:io';

import 'package:dd_app_ui/domain/models/create_post_comment_model.dart';
import 'package:dd_app_ui/domain/models/create_post_model.dart';
import 'package:dd_app_ui/domain/models/meta_data_model.dart';
import 'package:dd_app_ui/domain/models/post_comment.dart';
import 'package:dd_app_ui/domain/models/post_model.dart';
import 'package:dd_app_ui/domain/models/push_token_model.dart';
import 'package:dd_app_ui/domain/models/user_model.dart';
import 'package:dd_app_ui/domain/repository/api_repository.dart';
import 'package:dd_app_ui/internal/dependecies/repository_model.dart';

class ApiService {
  final ApiRepository _api = RepositoryModule.apiRepository();

  Future<int> getUserPostAmount({String? userId}) async {
    return _api.getUserPostAmount(userId);
  }

  Future<int> getUserSubscribersAmount({String? userId}) async {
    return await _api.getUserSubscribersAmount(userId);
  }

  Future<int> getUserSubscriptionsAmount({String? userId}) async {
    return await _api.getUserSubscriptionsAmount(userId);
  }

  Future<List<PostModel>?> getCurrentUserPosts({
    String? lastPostCreated,
    int take = 10,
    int skip = 0,
  }) async {
    {
      return await _api.getCurrentUserPosts(lastPostCreated, take, skip);
    }
  }

  Future<List<UserModel>?> getUsers(int take, int skip) async {
    return await _api.getUsers(take, skip);
  }

  Future<List<PostModel>?> getSubscriptionPosts(
      String? lastPostCreated, int take, int skip) async {
    return await _api.getSubscriptionsPosts(lastPostCreated, take, skip);
  }

  Future<PostModel?> getPost({required String postId}) async {
    return await _api.getPost(postId: postId);
  }

  Future<bool> getPostLikeState({required String postId}) async {
    return await _api.getPostLikeState(postId: postId);
  }

  Future changePostLikeState({required String postId}) async {
    return await _api.changePostLikeState(postId: postId);
  }

  Future<UserModel?> getUserById({required String userId}) async {
    return await _api.getUserById(userId: userId);
  }

  Future<List<PostComment>?> getPostComments(
      {required String? lastPostCreated,
      required String postId,
      required int take,
      required int skip}) async {
    return await _api.getPostComments(
        lastPostCreated: lastPostCreated,
        postId: postId,
        take: take,
        skip: skip);
  }

  Future createPostComment({required CreatePostCommentModel model}) async {
    return await _api.createPostComment(model: model);
  }

  Future<List<MetaDataModel>?> uploadFiles({required List<File> files}) async {
    return await _api.uploadFiles(files: files);
  }

  Future addUserAvatar({required MetaDataModel model}) async {
    return await _api.addUserAvatar(model: model);
  }

  Future createPost({required CreatePostModel model}) async {
    return await _api.createPost(model: model);
  }

  Future changeSubscriptionStateOnUser({required String userId}) async {
    return await _api.changeSubscriptionStateOnUser(userId: userId);
  }

  Future<bool> isSubscribedOn({required String userId}) async {
    return await _api.isSubscribedOn(userId: userId);
  }

  Future subscribe({required PushTokenModel model}) async {
    return await _api.subscribe(model: model);
  }

  Future unsubscribe() async {
    return await _api.unsubscribe();
  }
}
