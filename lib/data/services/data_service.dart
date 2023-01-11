import 'package:dd_app_ui/data/services/database.dart';
import 'package:dd_app_ui/domain/enums/db_query.dart';
import 'package:dd_app_ui/domain/models/direct.dart';
import 'package:dd_app_ui/domain/models/direct_file.dart';
import 'package:dd_app_ui/domain/models/direct_member.dart';
import 'package:dd_app_ui/domain/models/direct_message.dart';
import 'package:dd_app_ui/domain/models/post.dart';
import 'package:dd_app_ui/domain/models/post_comment.dart';
import 'package:dd_app_ui/domain/models/post_file.dart';
import 'package:dd_app_ui/domain/models/post_like_state.dart';
import 'package:dd_app_ui/domain/models/post_with_post_like_state.dart';
import 'package:dd_app_ui/domain/models/subscription.dart';
import 'package:dd_app_ui/domain/models/user.dart';
import 'package:dd_app_ui/domain/models/user_statistics.dart';
import 'package:dd_app_ui/internal/config/shared_prefs.dart';

class DataService {
  Future cuUser(User user) async {
    await DB.instance.createUpdate(user);
  }

  Future cuUsers(List<User> users) async {
    await DB.instance.createUpdateRange(users);
  }

  Future<Post?> getPost({required String postId}) async {
    return await DB.instance.get(postId);
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

  Future cuSubscription(Subscription sub) async {
    return await DB.instance.createUpdate<Subscription>(sub);
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

  Future<List<Subscription>?> getSusbcriptions({
    required String userId,
    int? take,
    int? skip,
  }) async {
    return (await DB.instance.getAll<Subscription>(
      whereMap: {"subscriberId": userId},
      take: take,
      skip: skip,
      conditions: [DbQueryEnum.equal],
    ))
        .toList();
  }

  Future<List<Subscription>?> getSubscribers({
    required String userId,
    int? take,
    int? skip,
  }) async {
    return (await DB.instance.getAll<Subscription>(
      whereMap: {"id": userId},
      take: take,
      skip: skip,
      conditions: [DbQueryEnum.equal],
    ))
        .toList();
  }

  Future delSubscription({required Subscription subscription}) async {
    return await DB.instance.delete(subscription);
  }

  Future<Iterable<PostWithPostLikeState>?> getCurrentUserSubscriptionsPosts({
    required Map<String, dynamic>? where,
    int? take,
    int? skip,
    required List<DbQueryEnum>? conds,
  }) async {
    List<String> subsIds = [];
    List<PostWithPostLikeState> res = [];
    var curUser = await SharedPrefs.getStoredUser();

    var curUserSubscriptions = await getSusbcriptions(userId: curUser!.id);

    if (curUserSubscriptions != null) {
      for (var curUserSub in curUserSubscriptions) {
        subsIds.add(curUserSub.id);
      }
    }

    if (where != null) {
      where.addAll({"authorId": subsIds});
    } else {
      where = {"authorId": subsIds};
    }

    var posts = (await DB.instance.getAll<Post>(
      whereMap: where,
      take: take,
      skip: skip,
      conditions: conds,
      orderBy: "created DESC",
    ))
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

  Future cuDirects(List<Direct> directs) async {
    await DB.instance.createUpdateRange(directs);
  }

  // Future<List<Direct>?> getUserDirectss({
  //   required String userId,
  //   int? take,
  //   int? skip,
  //   List<DbQueryEnum>? conds,
  // }) async {
  //   List<Direct> res = [];

  //   var directIds = await DB.instance.getAll<DirectMember>(
  //     whereMap: {"userId": userId},
  //     conditions: [DbQueryEnum.equal],
  //     take: take,
  //     skip: skip,
  //   );

  //   for (var id in directIds) {
  //     //res.add(DB.instance.get<>(id))
  //   }
  // }

  Future<List<Direct>?> getDirects({
    Map<String, dynamic>? where,
    int? take,
    int? skip,
    List<DbQueryEnum>? conds,
  }) async {
    return (await DB.instance.getAll<Direct>(
            take: take,
            skip: skip,
            whereMap: where,
            orderBy: '"title" DESC',
            conditions: conds))
        .toList();
  }

  Future cuDirectMessages(List<DirectMessage> directMessages) async {
    await DB.instance.createUpdateRange(directMessages);
  }

  Future<List<DirectMessage>?> getDirectMessages({
    Map<String, dynamic>? where,
    int? take,
    int? skip,
    List<DbQueryEnum>? conds,
  }) async {
    return (await DB.instance.getAll<DirectMessage>(
            take: take,
            skip: skip,
            whereMap: where,
            orderBy: '"sended" DESC',
            conditions: conds))
        .toList();
  }

  Future cuDirect(Direct direct) async {
    await DB.instance.createUpdate(direct);
  }

  Future<Direct?> getDirect({required String directId}) async {
    return await DB.instance.get(directId);
  }

  Future cuDirectMember(DirectMember directMember) async {
    await DB.instance
        .createUpdate(directMember, where: "id = ? and userId = ?", whereArgs: [
      directMember.id,
      directMember.userId,
    ]);
  }

  Future cuDirectMembers(List<DirectMember> directMember) async {
    return await DB.instance.createUpdateRange(directMember);
  }

  Future<List<DirectMember>?> getDirectMembers({
    Map<String, dynamic>? where,
    int? take,
    int? skip,
    List<DbQueryEnum>? conds,
  }) async {
    return (await DB.instance.getAll<DirectMember>(
      take: take,
      skip: skip,
      whereMap: where,
      conditions: conds,
    ))
        .toList();
  }

  Future cuDirectMessageFiles(List<DirectFile> directFile) async {
    return await DB.instance.createUpdateRange(directFile);
  }

  Future<List<DirectFile>?> getDirectMessageFiles(
      String directMessageId) async {
    return (await DB.instance
            .getAll<DirectFile>(whereMap: {"messageId": directMessageId}))
        .toList();
  }

  Future iDirectMessage(DirectMessage message) async {
    await DB.instance.insert(message);
  }
}
