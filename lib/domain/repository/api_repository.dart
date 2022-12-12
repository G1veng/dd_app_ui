import 'package:dd_app_ui/domain/models/post_comment.dart';
import 'package:dd_app_ui/domain/models/post_model.dart';
import 'package:dd_app_ui/domain/models/token_response_model.dart';
import 'package:dd_app_ui/domain/models/user.dart';
import 'package:dd_app_ui/domain/models/user_model.dart';

abstract class ApiRepository {
  Future<TokenResponseModel?> getToken(
      {required String login, required String password});

  Future<TokenResponseModel?> refreshToken({required String refreshToken});

  Future<User?> getUser();

  Future<int> getUserPostAmount();

  Future<int> getUserSubscribersAmount();

  Future<int> getUserSubscriptionsAmount();

  Future<List<PostModel>?> getCurrentUserPosts(int take, int skip);

  Future<List<UserModel>?> getUsers();

  Future<List<PostModel>?> getSubscriptionsPosts(int take, int skip);

  Future createUser({
    required name,
    required email,
    required password,
    required retryPassword,
    required birthDate,
  });

  Future<PostModel?> getPost({required String postId});

  Future<bool> getPostLikeState({required String postId});

  Future changePostLikeState({required String postId});

  Future<UserModel?> getUserById({required String userId});

  Future<List<PostComment>?> getPostComments({required String postId});
}
