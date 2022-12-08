import 'dart:io';
import 'package:dd_app_ui/domain/models/post_model_response.dart';
import 'package:dd_app_ui/domain/models/post_request.dart';
import 'package:dd_app_ui/domain/models/user.dart';
import 'package:dd_app_ui/domain/repository/api_repository.dart';
import 'package:dd_app_ui/exceptions/nonetwork_exception.dart';
import 'package:dd_app_ui/internal/dependecies/repository_model.dart';
import 'package:dio/dio.dart';

class ApiService {
  final ApiRepository _api = RepositoryModule.apiRepository();

  Future<int> getUserPostAmount() async {
    try {
      return _api.getUserPostAmount();
    } on DioError catch (e) {
      if (e.error is SocketException) {
        throw NoNetworkException();
      } else {
        throw Exception();
      }
    }
  }

  Future<int> getUserSubscribersAmount() async {
    try {
      return await _api.getUserSubscribersAmount();
    } on DioError catch (e) {
      if (e.error is SocketException) {
        throw NoNetworkException();
      } else {
        throw Exception();
      }
    }
  }

  Future<int> getUserSubscriptionsAmount() async {
    try {
      return await _api.getUserSubscriptionsAmount();
    } on DioError catch (e) {
      if (e.error is SocketException) {
        throw NoNetworkException();
      } else {
        throw Exception();
      }
    }
  }

  Future<List<PostModelResponse>?> getCurrentUserPosts({
    int take = 10,
    int skip = 0,
  }) async {
    try {
      return await _api.getCurrentUserPosts(take, skip);
    } on DioError catch (e) {
      if (e.error is SocketException) {
        throw NoNetworkException();
      } else {
        throw Exception();
      }
    }
  }

  Future<List<User>?> getUsers() async {
    try {
      return await _api.getUsers();
    } on DioError catch (e) {
      if (e.error is SocketException) {
        throw NoNetworkException();
      } else {
        throw Exception();
      }
    }
  }

  Future<List<PostModelResponse>?> getSubscriptionPosts(
      int take, int skip) async {
    try {
      return await _api.getSubscriptionsPosts(take, skip);
    } on DioError catch (e) {
      if (e.error is SocketException) {
        throw NoNetworkException();
      } else {
        throw Exception();
      }
    }
  }

  Future<PostRequest?> getPost({required String postId}) async {
    return await _api.getPost(postId: postId);
  }

  Future<bool> getPostLikeState({required String postId}) async {
    return await _api.getPostLikeState(postId: postId);
  }

  Future changePostLikeState({required String postId}) async {
    return await _api.changePostLikeState(postId: postId);
  }
}
