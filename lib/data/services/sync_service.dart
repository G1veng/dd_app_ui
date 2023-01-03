import 'package:dd_app_ui/data/services/api_service.dart';
import 'package:dd_app_ui/data/services/data_service.dart';
import 'package:dd_app_ui/domain/models/post.dart';
import 'package:dd_app_ui/domain/models/post_like_state.dart';
import 'package:dd_app_ui/domain/models/user.dart';
import 'package:dd_app_ui/domain/models/user_statistics.dart';

class SyncService {
  final _api = ApiService();
  final _dataService = DataService();

  Future syncPosts(
    int take, {
    String? lastPostCreated,
    int skip = 0,
  }) async {
    var posts = await _api.getSubscriptionPosts(lastPostCreated, take, skip);
    if (posts == null) {
      return null;
    }

    for (var post in posts) {
      var author = await _api.getUserById(userId: post.authorId!);
      if (author != null) {
        await _dataService.cuUser(User.fromJson(author.toJson()));
      }
    }

    await _dataService
        .cuPosts(posts.map((e) => Post.fromJson(e.toJson())).toList());

    for (var post in posts) {
      await _dataService.cuPostFiles(post.postFiles!);

      var postLikeState = await _api.getPostLikeState(postId: post.id!);
      await _dataService.cuPostLikeState(
          PostLikeState(id: post.id!, isLiked: postLikeState == true ? 1 : 0));
    }
  }

  Future syncUserPosts(
    int take, {
    String? lastPostCreated,
    int skip = 0,
  }) async {
    var posts = await _api.getCurrentUserPosts(
      lastPostCreated: lastPostCreated,
      take: take,
      skip: skip,
    );
    if (posts == null) {
      return null;
    }

    for (var post in posts) {
      var author = await _api.getUserById(userId: post.authorId!);
      if (author != null) {
        await _dataService.cuUser(User.fromJson(author.toJson()));
      }

      await _dataService.cuPostFiles(post.postFiles!);

      var postLikeState = await _api.getPostLikeState(postId: post.id!);
      await _dataService.cuPostLikeState(
          PostLikeState(id: post.id!, isLiked: postLikeState == true ? 1 : 0));
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
      await _dataService.cuUserStatistics(UserStatistics(
          id: user.id!,
          userPostAmount: await _api.getUserPostAmount(),
          userSubscribersAmount: await _api.getUserSubscribersAmount(),
          userSubscriptionsAmount: await _api.getUserSubscriptionsAmount()));
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
    var postComments = await _api.getPostComments(
        lastPostCreated: lastPostCreated,
        postId: postId,
        take: take,
        skip: skip);
    if (postComments == null) {
      return;
    }

    for (var postComment in postComments) {
      var author = await _api.getUserById(userId: postComment.authorId);
      if (author != null) {
        await _dataService.cuUser(User.fromJson(author.toJson()));
      }
    }

    await _dataService.cuPostComments(postComments);
  }

  Future syncUserStatistics({
    required String userId,
  }) async {
    await syncUser(userId: userId);

    var one = await _api.getUserPostAmount(userId: userId);
    var two = await _api.getUserSubscribersAmount(userId: userId);
    var three = await _api.getUserSubscriptionsAmount(userId: userId);

    await _dataService.cuUserStatistics(UserStatistics(
        id: userId,
        userPostAmount: await _api.getUserPostAmount(userId: userId),
        userSubscribersAmount:
            await _api.getUserSubscribersAmount(userId: userId),
        userSubscriptionsAmount:
            await _api.getUserSubscriptionsAmount(userId: userId)));
  }

  Future syncUser({required String userId}) async {
    var user = await _api.getUserById(userId: userId);
    await _dataService.cuUser(User.fromJson(user!.toJson()));
  }
}
