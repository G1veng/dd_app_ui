import 'package:dd_app_ui/data/services/database.dart';
import 'package:dd_app_ui/domain/enums/db_query.dart';
import 'package:dd_app_ui/domain/models/post.dart';
import 'package:dd_app_ui/domain/models/post_comment.dart';
import 'package:dd_app_ui/domain/models/post_file.dart';
import 'package:dd_app_ui/domain/models/post_like_state.dart';
import 'package:dd_app_ui/domain/models/post_with_post_like_state.dart';
import 'package:dd_app_ui/domain/models/user.dart';
import 'package:dd_app_ui/domain/models/user_statistics.dart';

class DataService {
  Future cuUser(User user) async {
    await DB.instance.createUpdate(user);
  }

  Future cuUsers(List<User> users) async {
    await DB.instance.createUpdateRange(users);
  }

  Future<List<User>?> getUsers({
    Map<String, dynamic>? where,
    int? take,
    int? skip,
    List<DbQueryEnum>? conds,
  }) async {
    return (await DB.instance.getAll<User>(
            take: take,
            skip: skip,
            whereMap: where,
            orderBy: '"name" DESC',
            conditions: conds))
        .toList();
  }

  Future<User?> getUser(String id) async {
    return await DB.instance.get(id);
  }

  Future cuPosts(List<Post> posts) async {
    return await DB.instance.createUpdateRange(posts);
  }

  Future cuPost(Post post) async {
    await DB.instance.createUpdate(post);
  }

  Future<PostWithPostLikeState?> getPostWithLikeStatePostFiles(
      String postId) async {
    Post? post = await DB.instance.get(postId);

    List<PostFile>? postFiles = (await getPostFiles(postId))!.toList();

    PostLikeState? postLikeState =
        await getPostLikeState(postId) ?? PostLikeState(id: postId, isLiked: 0);

    return PostWithPostLikeState(
      id: postId,
      created: post!.created,
      text: post.text,
      authorId: post.authorId,
      postFiles: postFiles,
      authorAvatar: post.authorAvatar,
      commentAmount: post.commentAmount,
      likesAmount: post.likesAmount,
      postLikeState: postLikeState.isLiked,
    );
  }

  Future<Iterable<PostWithPostLikeState>?> getPostsWithLikeStatePostFilesById(
    Map<String, dynamic>? where, {
    int? take,
    int? skip,
    List<DbQueryEnum>? conds,
  }) async {
    List<PostWithPostLikeState>? res = [];

    List<Post> posts = (await DB.instance.getAll<Post>(
            take: take,
            skip: skip,
            whereMap: where,
            orderBy: "created DESC",
            conditions: conds))
        .toList();

    for (var post in posts) {
      var postLikeState = (await DB.instance.get<PostLikeState>(post.id));

      res.add(PostWithPostLikeState(
          id: post.id,
          created: post.created,
          text: post.text,
          authorId: post.authorId,
          postFiles: (await getPostFiles(post.id!))!.toList(),
          authorAvatar: post.authorAvatar,
          commentAmount: post.commentAmount,
          likesAmount: post.likesAmount,
          postLikeState: postLikeState == null ? 0 : postLikeState.isLiked));
    }

    return res;
  }

  Future cuUserStatistics(UserStatistics userStatistics) async {
    return await DB.instance.createUpdate(userStatistics);
  }

  Future<UserStatistics?> getUserStatisctics(String userId) async {
    return await DB.instance.get(userId);
  }

  Future cuPostFiles(List<PostFile> postFiles) async {
    return await DB.instance.createUpdateRange(postFiles);
  }

  Future<Iterable<PostFile>?> getPostFiles(String postId) async {
    return await DB.instance.getAll(whereMap: {"postId": postId});
  }

  Future cuPostLikeState(PostLikeState postLikeState) async {
    await DB.instance.createUpdate(postLikeState);
  }

  Future<PostLikeState?> getPostLikeState(String postId) async {
    return await DB.instance.get(postId);
  }

  Future cuPostComments(List<PostComment> postComments) async {
    return await DB.instance.createUpdateRange(postComments);
  }

  Future<List<PostComment>?> getPostComments(
    Map<String, dynamic>? where, {
    int? take,
    int? skip,
    List<DbQueryEnum>? conds,
  }) async {
    List<PostComment> postsComments = (await DB.instance.getAll<PostComment>(
            take: take,
            skip: skip,
            whereMap: where,
            orderBy: "created DESC",
            conditions: conds))
        .toList();

    return postsComments;
  }

  Future cuPostComment(PostComment postComment) async {
    return await DB.instance.createUpdate(postComment);
  }
}
