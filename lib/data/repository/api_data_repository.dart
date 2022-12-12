import 'package:dd_app_ui/data/clients/api_client.dart';
import 'package:dd_app_ui/domain/models/create_user_request_model.dart';
import 'package:dd_app_ui/domain/models/post_comment.dart';
import 'package:dd_app_ui/domain/models/post_model.dart';
import 'package:dd_app_ui/domain/models/refresh_token_request_model.dart';
import 'package:dd_app_ui/domain/models/user.dart';
import 'package:dd_app_ui/domain/models/user_model.dart';

import '../../domain/models/token_request_model.dart';
import '../../domain/models/token_response_model.dart';
import '../../domain/repository/api_repository.dart';
import '../clients/auth_client.dart';

class ApiDataRepository extends ApiRepository {
  final AuthClient _auth;
  final ApiClient _api;
  ApiDataRepository(this._auth, this._api);

  @override
  Future<TokenResponseModel?> getToken({
    required String login,
    required String password,
  }) async {
    return await _auth.getToken(TokenRequestModel(
      login: login,
      password: password,
    ));
  }

  @override
  Future<TokenResponseModel?> refreshToken({
    required String refreshToken,
  }) async {
    return await _auth.getRefreshToken(RefreshTokenRequestModel(
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
  Future<List<PostModel>?> getCurrentUserPosts(int take, int skip) async {
    return await _api.getCurrentUserPosts(take, skip);
  }

  @override
  Future<List<UserModel>?> getUsers() async {
    return await _api.getUsers();
  }

  @override
  Future<List<PostModel>?> getSubscriptionsPosts(int take, int skip) async {
    return await _api.getSubscriptionPosts(take, skip);
  }

  @override
  Future createUser(
      {required name,
      required email,
      required password,
      required retryPassword,
      required birthDate}) async {
    return await _auth.createUser(CreateUserRequestModel(
      name: name,
      email: email,
      password: password,
      retryPassword: retryPassword,
      birthDate: birthDate,
    ));
  }

  @override
  Future<PostModel?> getPost({required String postId}) async {
    return await _api.getPost(postId);
  }

  @override
  Future<bool> getPostLikeState({required String postId}) async {
    return await _api.getPostLikeState(postId);
  }

  @override
  Future changePostLikeState({required String postId}) async {
    return await _api.changePostLikeState(postId);
  }

  @override
  Future<UserModel?> getUserById({required String userId}) async {
    return await _api.getUserById(userId);
  }

  @override
  Future<List<PostComment>?> getPostComments({required String postId}) async {
    return await _api.getPostComments(postId);
  }
}
