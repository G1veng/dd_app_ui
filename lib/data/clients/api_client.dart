import 'package:dd_app_ui/domain/models/post_model.dart';
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
  Future<List<PostModel>?> getCurrentUserPosts(
    @Query("take") int take,
    @Query("skip") int skip,
  );

  @GET("/api/User/GetUsers")
  Future<List<User>?> getUsers();

  @GET("/api/Post/GetSubscriptionPosts")
  Future<List<PostModel>?> getSubscriptionPosts(
    @Query("take") int take,
    @Query("skip") int skip,
  );

  @GET("/api/Post/GetPost")
  Future<PostModel?> getPost(@Query("postId") String postId);

  @GET("/api/Post/GetPostLikeState")
  Future<bool> getPostLikeState(@Query("postId") String postId);

  @POST("/api/Post/ChangePostLikeState")
  Future changePostLikeState(@Query("postId") String postId);

  @GET("/api/User/GetUser")
  Future<User?> getUserById(@Query("userId") String userId);
}
