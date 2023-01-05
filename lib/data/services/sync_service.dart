import 'package:dd_app_ui/data/services/api_service.dart';
import 'package:dd_app_ui/data/services/data_service.dart';
import 'package:dd_app_ui/domain/models/post.dart';
import 'package:dd_app_ui/domain/models/post_like_state.dart';
import 'package:dd_app_ui/domain/models/user.dart';
import 'package:dd_app_ui/domain/models/user_statistics.dart';

class SyncService {
  final _api = ApiService();
  final _dataService = DataService();

  Future syncPostLikeState({required String postId}) async {
    var postLikeState = await _api.getPostLikeState(postId: postId);
    await _dataService.cuPostLikeState(
        PostLikeState(id: postId, isLiked: postLikeState == true ? 1 : 0));
  }

  Future syncUserPosts(
    int take, {
    required String userId,
    String? lastPostCreated,
    int skip = 0,
  }) async {
    var posts = await _api.getPosts(
      userId: userId,
      lastPostCreated: lastPostCreated,
      take: take,
      skip: skip,
    );
    if (posts == null) {
      return null;
    }

    for (var post in posts) {
      await syncUser(userId: post.authorId!);

      await _dataService.cuPostFiles(post.postFiles!);

      await syncPostLikeState(postId: post.id!);
    }

    await _dataService
        .cuPosts(posts.map((e) => Post.fromJson(e.toJson())).toList());
  }

  Future syncUsers(
    int take, {
    String? lastPostCreated,
    int skip = 0,
  }) async {
    var users = await _api.getUsers(take, skip);
    if (users == null) {
      return;
    }

    for (var user in users) {
      await syncUser(userId: user.id!);
    }

    await _dataService
        .cuUsers(users.map((e) => User.fromJson(e.toJson())).toList());
  }

  Future syncPostComments(
    int take, {
    required String postId,
    String? lastPostCreated,
    int skip = 0,
  }) async {
    await syncPost(postId: postId);

    var postComments = await _api.getPostComments(
        lastPostCreated: lastPostCreated,
        postId: postId,
        take: take,
        skip: skip);
    if (postComments == null) {
      return;
    }

    for (var postComment in postComments) {
      await syncUser(userId: postComment.authorId);
    }

    await _dataService.cuPostComments(postComments);
  }

  Future syncPost({required postId}) async {
    var post = await _api.getPost(postId: postId);

    if (post != null) {
      await syncUser(userId: post.authorId!);

      await _dataService.cuPost(Post.fromJson(post.toJson()));

      await _dataService.cuPostFiles(post.postFiles!);

      await syncPostLikeState(postId: post.id!);
    }
  }

  Future syncUser({required String userId}) async {
    var user = await _api.getUserById(userId: userId);

    if (user != null) {
      await _dataService.cuUserStatistics(UserStatistics(
          id: user.id!,
          userPostAmount: await _api.getUserPostAmount(userId: userId),
          userSubscribersAmount:
              await _api.getUserSubscribersAmount(userId: userId),
          userSubscriptionsAmount:
              await _api.getUserSubscriptionsAmount(userId: userId)));

      await _dataService.cuUser(User.fromJson(user.toJson()));
    }
  }
}
