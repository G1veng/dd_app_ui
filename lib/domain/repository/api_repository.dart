import 'package:dd_app_ui/domain/models/post_model_response.dart';
import 'package:dd_app_ui/domain/models/token_response.dart';
import 'package:dd_app_ui/domain/models/user.dart';

abstract class ApiRepository {
  Future<TokenResponse?> getToken(
      {required String login, required String password});

  Future<TokenResponse?> refreshToken({required String refreshToken});

  Future<User?> getUser();

  Future<int> getUserPostAmount();

  Future<int> getUserSubscribersAmount();

  Future<int> getUserSubscriptionsAmount();

  Future<List<PostModelResponse>?> getCurrentUserPosts(int take, int skip);

  Future<List<User>?> getUsers();

  Future<List<PostModelResponse>?> getSubscriptionsPosts(int take, int skip);

  Future createUser({
    required name,
    required email,
    required password,
    required retryPassword,
    required birthDate,
  });
}
