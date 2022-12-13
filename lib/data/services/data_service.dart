import 'package:dd_app_ui/data/services/database.dart';
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

  Future<Iterable<User>?> getUsers(
      {String? id,
      int? take,
      int? skip,
      String? orderBy,
      bool? notEqual}) async {
    return await DB.instance.getAll(
      take: take,
      skip: skip,
      orderBy: orderBy,
      whereMap: id != null ? {"id": id} : null,
      notEqual: notEqual,
    );
  }

  Future<Post?> getPost(String id) async {
    return await DB.instance.get(id);
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

  Future<Iterable<Post>?> getPostsByAuthorId(String authorId,
      {int? take, int? skip, String? orderBy}) async {
    return await DB.instance.getAll(
      whereMap: {"authorId": authorId},
      orderBy: orderBy,
      skip: skip,
      take: take,
    );
  }

  Future<PostWithPostLikeState?> getPostWithLikeStatePostFiles(
      String postid) async {
    Post? post = await DB.instance.get(postid);

    List<PostFile>? postFiles = (await getPostFiles(postid))!.toList();

    PostLikeState? postLikeState = await getPostLikeState(postid);

    return PostWithPostLikeState(
      id: postid,
      created: post!.created,
      text: post.text,
      authorId: post.authorId,
      postFiles: postFiles,
      authorAvatar: post.authorAvatar,
      commentAmount: post.commentAmount,
      likesAmount: post.likesAmount,
      postLikeState: postLikeState!.isLiked,
    );
  }

  Future<Iterable<PostWithPostLikeState>?> getPostsWithLikeStatePostFilesById(
      String authorId,
      {int? take,
      int? skip,
      String? orderBy}) async {
    List<PostWithPostLikeState>? res = [];
    var posts = await getPostsByAuthorId(authorId,
        orderBy: orderBy, take: take, skip: skip);

    if (posts != null) {
      for (var post in posts) {
        var postLikeState = await getPostLikeState(post.id!) ??
            PostLikeState(id: post.id!, isLiked: 0);

        res.add(PostWithPostLikeState(
          id: post.id,
          created: post.created,
          text: post.text,
          authorId: post.authorId,
          postFiles: (await getPostFiles(post.id!))!.toList(),
          authorAvatar: post.authorAvatar,
          commentAmount: post.commentAmount,
          likesAmount: post.likesAmount,
          postLikeState: postLikeState.isLiked,
        ));
      }
    }

    return res;
  }

  Future cuUserStatistics(UserStatistics userStatistics) async {
    return await DB.instance.createUpdate(userStatistics);
  }

  Future<UserStatistics?> getUserStatisctics(String userId) async {
    return await DB.instance.get(userId);
  }

  Future cuPostFile(PostFile postFile) async {
    return await DB.instance.createUpdate(postFile);
  }

  Future<PostFile?> getPostFile(String id) async {
    return await DB.instance.get(id);
  }

  Future<Iterable<PostFile>?> getPostFiles(String postId) async {
    return await DB.instance.getAll(whereMap: {"postId": postId});
  }

  Future cuPostLikeState(PostLikeState postLikeState) async {
    return await DB.instance.createUpdate(postLikeState);
  }

  Future<PostLikeState?> getPostLikeState(String postId) async {
    return await DB.instance.get(postId);
  }

  Future cuPostComments(List<PostComment> postComments) async {
    return await DB.instance.createUpdateRange(postComments);
  }

  Future<Iterable<PostComment>?> getPostComments(
      String postId, int take, int skip, String? orderBy) async {
    return await DB.instance.getAll(
        whereMap: {"postId": postId}, take: take, skip: skip, orderBy: orderBy);
  }

  Future cuPostComment(PostComment postComment) async {
    return await DB.instance.createUpdate(postComment);
  }

  Future<PostComment?> getPostComment(String postCommentId) async {
    return await DB.instance.get(postCommentId);
  }
}
