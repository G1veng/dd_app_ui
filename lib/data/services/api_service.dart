import 'package:dd_app_ui/domain/models/create_post_comment_model.dart';
import 'package:dd_app_ui/domain/models/post_comment.dart';
import 'package:dd_app_ui/domain/models/post_model.dart';
import 'package:dd_app_ui/domain/models/user_model.dart';
import 'package:dd_app_ui/domain/repository/api_repository.dart';
import 'package:dd_app_ui/internal/dependecies/repository_model.dart';

class ApiService {
  final ApiRepository _api = RepositoryModule.apiRepository();

  Future<int> getUserPostAmount() async {
    return _api.getUserPostAmount();
  }

  Future<int> getUserSubscribersAmount() async {
    return await _api.getUserSubscribersAmount();
  }

  Future<int> getUserSubscriptionsAmount() async {
    return await _api.getUserSubscriptionsAmount();
  }

  Future<List<PostModel>?> getCurrentUserPosts({
    int take = 10,
    int skip = 0,
  }) async {
    {
      return await _api.getCurrentUserPosts(take, skip);
    }
  }

  Future<List<UserModel>?> getUsers() async {
    return await _api.getUsers();
  }

  Future<List<PostModel>?> getSubscriptionPosts(int take, int skip) async {
    return await _api.getSubscriptionsPosts(take, skip);
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
      {required String postId, required int take, required int skip}) async {
    return await _api.getPostComments(postId: postId, take: take, skip: skip);
  }

  Future createPostComment({required CreatePostCommentModel model}) async {
    return await _api.createPostComment(model: model);
  }
}
