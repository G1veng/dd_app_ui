import 'package:dd_app_ui/domain/models/post_model_response.dart';
import 'package:dd_app_ui/domain/models/user.dart';
import 'package:dd_app_ui/domain/repository/api_repository.dart';
import 'package:dd_app_ui/internal/dependecies/repository_model.dart';

class ApiService {
  final ApiRepository _api = RepositoryModule.apiRepository();

  Future<int> getUserPostAmount() async {
    return await _api.getUserPostAmount();
  }

  Future<int> getUserSubscribersAmount() async {
    return await _api.getUserSubscribersAmount();
  }

  Future<int> getUserSubscriptionsAmount() async {
    return await _api.getUserSubscriptionsAmount();
  }

  Future<List<PostModelResponse>?> getCurrentUserPosts({
    int take = 10,
    int skip = 0,
  }) async {
    return await _api.getCurrentUserPosts(take, skip);
  }

  Future<List<User>?> getUsers() async {
    return await _api.getUsers();
  }
}
