import 'package:dd_app_ui/data/clients/api_client.dart';
import 'package:dd_app_ui/domain/models/create_user_request.dart';
import 'package:dd_app_ui/domain/models/post_model_response.dart';
import 'package:dd_app_ui/domain/models/refresh_token_request.dart';
import 'package:dd_app_ui/domain/models/user.dart';

import '../../domain/models/token_request.dart';
import '../../domain/models/token_response.dart';
import '../../domain/repository/api_repository.dart';
import '../clients/auth_client.dart';

class ApiDataRepository extends ApiRepository {
  final AuthClient _auth;
  final ApiClient _api;
  ApiDataRepository(this._auth, this._api);

  @override
  Future<TokenResponse?> getToken({
    required String login,
    required String password,
  }) async {
    return await _auth.getToken(TokenRequest(
      login: login,
      password: password,
    ));
  }

  @override
  Future<TokenResponse?> refreshToken({
    required String refreshToken,
  }) async {
    return await _auth.getRefreshToken(RefreshTokenRequest(
      refreshToken: refreshToken,
    ));
  }

  @override
  Future<User?> getUser() async {
    return await _api.getUser();
  }

  @override
  Future<int> getUserPostAmount() async {
    return await _api.getUserPostAmount();
  }

  @override
  Future<int> getUserSubscribersAmount() async {
    return await _api.getUserSubscribersAmount();
  }

  @override
  Future<int> getUserSubscriptionsAmount() async {
    return await _api.getUserSubscriptionsAmount();
  }

  @override
  Future<List<PostModelResponse>?> getCurrentUserPosts(
      int take, int skip) async {
    return await _api.getCurrentUserPosts(take, skip);
  }

  @override
  Future<List<User>?> getUsers() async {
    return await _api.getUsers();
  }

  @override
  Future<List<PostModelResponse>?> getSubscriptionsPosts(
      int take, int skip) async {
    return await _api.getSubscriptionPosts(take, skip);
  }

  @override
  Future createUser(
      {required name,
      required email,
      required password,
      required retryPassword,
      required birthDate}) async {
    return await _auth.createUser(CreateUserRequest(
      name: name,
      email: email,
      password: password,
      retryPassword: retryPassword,
      birthDate: birthDate,
    ));
  }
}
