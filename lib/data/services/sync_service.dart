import 'package:dd_app_ui/data/services/api_service.dart';
import 'package:dd_app_ui/data/services/data_service.dart';
import 'package:dd_app_ui/domain/models/direct.dart';
import 'package:dd_app_ui/domain/models/direct_member.dart' as dir_member;
import 'package:dd_app_ui/domain/models/direct_message.dart';
import 'package:dd_app_ui/domain/models/direct_file.dart' as dir_file;
import 'package:dd_app_ui/domain/models/direct_model.dart';
import 'package:dd_app_ui/domain/models/post.dart';
import 'package:dd_app_ui/domain/models/post_like_state.dart';
import 'package:dd_app_ui/domain/models/subscription.dart';
import 'package:dd_app_ui/domain/models/user.dart';
import 'package:dd_app_ui/domain/models/user_statistics.dart';
import 'package:dd_app_ui/internal/config/shared_prefs.dart';

class SyncService {
  final _api = ApiService();
  final _dataService = DataService();

  Future syncPostLikeState({required String postId}) async {
    await _api.getUserById(userId: (await SharedPrefs.getStoredUser())!.id);
    if (!(await SharedPrefs.getConnectionState())) {
      return;
    }

    var postLikeState = await _api.getPostLikeState(postId: postId);
    await _dataService.cuPostLikeState(
        PostLikeState(id: postId, isLiked: postLikeState == true ? 1 : 0));
  }

  Future syncSubscriptionsPosts(
    int take, {
    required String userId,
    String? lastPostCreated,
    int skip = 0,
  }) async {
    await _api.getUserById(userId: (await SharedPrefs.getStoredUser())!.id);
    if (!(await SharedPrefs.getConnectionState())) {
      return;
    }

    var curUser = await SharedPrefs.getStoredUser();

    var posts = await _api.getSubscriptionPosts(
      lastPostCreated,
      take,
      skip,
    );
    if (posts == null) {
      return;
    }

    for (var post in posts) {
      await syncUser(userId: post.authorId!);

      await _dataService.cuSubscription(Subscription(
        id: post.authorId!,
        subscriberId: curUser!.id,
      ));

      await _dataService.cuPostFiles(post.postFiles!);

      await syncPostLikeState(postId: post.id!);
    }

    await _dataService
        .cuPosts(posts.map((e) => Post.fromJson(e.toJson())).toList());
  }

  Future syncUserPosts(
    int take, {
    required String userId,
    String? lastPostCreated,
    int skip = 0,
  }) async {
    await _api.getUserById(userId: (await SharedPrefs.getStoredUser())!.id);
    if (!(await SharedPrefs.getConnectionState())) {
      return;
    }

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
    await _api.getUserById(userId: (await SharedPrefs.getStoredUser())!.id);
    if (!(await SharedPrefs.getConnectionState())) {
      return;
    }

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
    await _api.getUserById(userId: (await SharedPrefs.getStoredUser())!.id);
    if (!(await SharedPrefs.getConnectionState())) {
      return;
    }

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
    await _api.getUserById(userId: (await SharedPrefs.getStoredUser())!.id);
    if (!(await SharedPrefs.getConnectionState())) {
      return;
    }

    var post = await _api.getPost(postId: postId);

    if (post != null) {
      await syncUser(userId: post.authorId!);

      await _dataService.cuPost(Post.fromJson(post.toJson()));

      await _dataService.cuPostFiles(post.postFiles!);

      await syncPostLikeState(postId: post.id!);
    }
  }

  Future syncUser({required String userId}) async {
    await _api.getUserById(userId: (await SharedPrefs.getStoredUser())!.id);
    if (!(await SharedPrefs.getConnectionState())) {
      return;
    }

    var user = await _api.getUserById(userId: userId);

    if (user != null) {
      await _dataService.cuUser(User.fromJson(user.toJson()));

      await _dataService.cuUserStatistics(UserStatistics(
          id: user.id!,
          userPostAmount: await _api.getUserPostAmount(userId: userId),
          userSubscribersAmount:
              await _api.getUserSubscribersAmount(userId: userId),
          userSubscriptionsAmount:
              await _api.getUserSubscriptionsAmount(userId: userId)));
    }
  }

  Future syncDirects(
    int take, {
    int skip = 0,
  }) async {
    await _api.getUserById(userId: (await SharedPrefs.getStoredUser())!.id);
    if (!(await SharedPrefs.getConnectionState())) {
      return;
    }

    var directs = await _api.getUserDirects(take: take, skip: skip);
    if (directs != null) {
      await _dataService.cuDirects(directs
          .map((e) => Direct(
              id: e.directId,
              directImage: e.directImage?.link,
              title: e.directTitle))
          .toList());

      for (var direct in directs) {
        await syncDirectMembers(direct: direct);
      }
    }
  }

  Future syncDirectMembers({required DirectModel direct}) async {
    await _api.getUserById(userId: (await SharedPrefs.getStoredUser())!.id);
    if (!(await SharedPrefs.getConnectionState())) {
      return;
    }

    for (var member in direct.directMembers) {
      await syncUser(userId: member.directMember);
      await _dataService.cuDirectMember(dir_member.DirectMember(
          id: direct.directId, userId: member.directMember));
    }
  }

  Future syncDirectMessages({
    required int take,
    required String directId,
    int skip = 0,
    String? lastDirectMessageCreated,
  }) async {
    await _api.getUserById(userId: (await SharedPrefs.getStoredUser())!.id);
    if (!(await SharedPrefs.getConnectionState())) {
      return;
    }

    var directMessages = await _api.getDirectMessages(
        lastDirectMessageCreated: lastDirectMessageCreated,
        directId: directId,
        take: take,
        skip: skip);
    if (directMessages != null) {
      await _dataService.cuDirectMessages(directMessages
          .map((e) => DirectMessage(
              id: e.directMessageId,
              directMessage: e.directMessage,
              directId: directId,
              sended: e.sended,
              senderId: e.senderId))
          .toList());

      for (var message in directMessages) {
        if (message.directFiles != null && message.directFiles!.isNotEmpty) {
          await _dataService.cuDirectMessageFiles(message.directFiles!
              .map((e) => dir_file.DirectFile(
                    link: e.link,
                    id: e.id,
                    messageId: message.directMessageId,
                  ))
              .toList());
        }
      }
    }
  }

  Future syncDirect({required String directId}) async {
    await _api.getUserById(userId: (await SharedPrefs.getStoredUser())!.id);
    if (!(await SharedPrefs.getConnectionState())) {
      return;
    }

    var direct = await _api.getUserDirect(directId: directId);
    if (direct != null) {
      await _dataService.cuDirect(Direct(
          id: direct.directId,
          directImage: direct.directImage?.link,
          title: direct.directTitle));

      await syncDirectMembers(direct: direct);
    }
  }
}
