import 'package:dd_app_ui/domain/models/post_model_response.dart';
import 'package:dd_app_ui/domain/models/user.dart';
import "package:dio/dio.dart";
import 'package:retrofit/retrofit.dart';

part 'api_client.g.dart';

@RestApi()
abstract class ApiClient {
  factory ApiClient(Dio dio, {String? baseUrl}) = _ApiClient;

  @GET("/api/User/GetCurrentUser")
  Future<User?> getUser();

  @GET("/api/Post/GetUserPostAmount")
  Future<int> getUserPostAmount();

  @GET("/api/Subscription/GetUserSubscriptionsAmount")
  Future<int> getUserSubscriptionsAmount();

  @GET("/api/Subscription/GetUserSubscribersAmount")
  Future<int> getUserSubscribersAmount();

  @GET("/api/Post/GetCurrentUserPosts")
  Future<List<PostModelResponse>?>? getCurrentUserPosts(
    @Query("take") int take,
    @Query("skip") int skip,
  );

  @GET("/api/User/GetUsers")
  Future<List<User>?> getUsers();
}
