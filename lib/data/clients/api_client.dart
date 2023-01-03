import 'dart:io';

import 'package:dd_app_ui/domain/models/create_post_comment_model.dart';
import 'package:dd_app_ui/domain/models/create_post_model.dart';
import 'package:dd_app_ui/domain/models/meta_data_model.dart';
import 'package:dd_app_ui/domain/models/post_comment.dart';
import 'package:dd_app_ui/domain/models/post_model.dart';
import 'package:dd_app_ui/domain/models/push_token_model.dart';
import 'package:dd_app_ui/domain/models/user.dart';
import 'package:dd_app_ui/domain/models/user_model.dart';
import "package:dio/dio.dart";
import 'package:retrofit/retrofit.dart';

part 'api_client.g.dart';

@RestApi()
abstract class ApiClient {
  factory ApiClient(Dio dio, {String? baseUrl}) = _ApiClient;

  @GET("/api/User/GetCurrentUser")
  Future<User?> getUser();

  @GET("/api/Post/GetUserPostAmount")
  Future<int> getUserPostAmount(@Query("userId") String? userId);

  @GET("/api/Subscription/GetUserSubscriptionsAmount")
  Future<int> getUserSubscriptionsAmount(@Query("userId") String? userId);

  @GET("/api/Subscription/GetUserSubscribersAmount")
  Future<int> getUserSubscribersAmount(@Query("userId") String? userId);

  @GET("/api/Post/GetCurrentUserPosts")
  Future<List<PostModel>?> getCurrentUserPosts(
    @Query("lastPostCreated") String? lastPostCreated,
    @Query("take") int take,
    @Query("skip") int skip,
  );

  @GET("/api/User/GetUsers")
  Future<List<UserModel>?> getUsers(
    @Query("take") int take,
    @Query("skip") int skip,
  );

  @GET("/api/Post/GetSubscriptionPosts")
  Future<List<PostModel>?> getSubscriptionPosts(
    @Query("lastPostCreated") String? lastPostCreated,
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
  Future<UserModel?> getUserById(@Query("userId") String userId);

  @GET("/api/PostComment/GetPostComments")
  Future<List<PostComment>?> getPostComments(
    @Query("lastPostCreated") String? lastPostCreated,
    @Query("postId") String postId,
    @Query("take") int take,
    @Query("skip") int skip,
  );

  @POST("/api/PostComment/CreatePostComment")
  Future createPostComment(@Body() CreatePostCommentModel body);

  @POST("/api/Attach/UploadFiles")
  Future<List<MetaDataModel>?> uploadFiles(
      {@Part(name: "files") required List<File> files});

  @POST("/api/User/AddAvatarToUser")
  Future addUserAvatar(@Body() MetaDataModel model);

  @POST("/api/Post/CreatePost")
  Future createPost(@Body() CreatePostModel model);

  @POST("/api/Subscription/ChangeSubscriptionStateOnUser")
  Future changeSubscriptionStateOnUser(@Query("userId") String userId);

  @GET("/api/Subscription/IsSubscribedOn")
  Future<bool> isSubscribedOn(@Query("userId") String userId);

  @POST("/api/Push/Subscribe")
  Future subscribe(@Body() PushTokenModel model);

  @DELETE("/api/Push/Unsubscribe")
  Future unsubscribe();
}
