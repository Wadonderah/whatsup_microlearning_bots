import 'package:flutter_test/flutter_test.dart';
import 'package:whatsup_microlearning_bots/core/models/social_learning.dart';
import 'package:whatsup_microlearning_bots/core/services/social_learning_service.dart';

void main() {
  group('SocialLearningService Tests', () {
    late SocialLearningService socialService;

    setUp(() {
      socialService = SocialLearningService.instance;
    });

    group('Social Profile Management', () {
      test('should create a new social profile', () async {
        // Arrange
        const userId = 'user-123';
        const displayName = 'John Doe';
        const bio = 'Learning enthusiast';
        final interests = ['Programming', 'Design'];

        // Act
        final success = await socialService.createOrUpdateProfile(
          userId: userId,
          displayName: displayName,
          bio: bio,
          interests: interests,
        );

        // Assert
        expect(success, isTrue);

        final profile = await socialService.getProfile(userId);
        expect(profile, isNotNull);
        expect(profile!.displayName, equals(displayName));
        expect(profile.bio, equals(bio));
        expect(profile.interests, equals(interests));
        expect(profile.settings.shareAchievements, isTrue); // Default setting
      });

      test('should update existing social profile', () async {
        // Arrange
        const userId = 'user-123';
        await socialService.createOrUpdateProfile(
          userId: userId,
          displayName: 'Original Name',
          bio: 'Original bio',
          interests: ['Original'],
        );

        // Act
        final success = await socialService.createOrUpdateProfile(
          userId: userId,
          displayName: 'Updated Name',
          bio: 'Updated bio',
          interests: ['Updated', 'New'],
        );

        // Assert
        expect(success, isTrue);

        final profile = await socialService.getProfile(userId);
        expect(profile!.displayName, equals('Updated Name'));
        expect(profile.bio, equals('Updated bio'));
        expect(profile.interests, equals(['Updated', 'New']));
      });

      test('should search users by display name', () async {
        // Arrange
        await socialService.createOrUpdateProfile(
          userId: 'user1',
          displayName: 'Alice Johnson',
          interests: ['Programming'],
        );
        await socialService.createOrUpdateProfile(
          userId: 'user2',
          displayName: 'Bob Smith',
          interests: ['Design'],
        );
        await socialService.createOrUpdateProfile(
          userId: 'user3',
          displayName: 'Alice Brown',
          interests: ['Marketing'],
        );

        // Act
        final searchResults = await socialService.searchUsers('Alice');

        // Assert
        expect(searchResults, hasLength(2));
        expect(searchResults.every((u) => u.displayName.contains('Alice')),
            isTrue);
      });

      test('should update last active time', () async {
        // Arrange
        const userId = 'user-123';
        await socialService.createOrUpdateProfile(
          userId: userId,
          displayName: 'Test User',
          interests: [],
        );

        final originalProfile = await socialService.getProfile(userId);
        final originalLastActive = originalProfile!.lastActiveAt;

        // Wait a bit to ensure time difference
        await Future.delayed(const Duration(milliseconds: 10));

        // Act
        await socialService.updateLastActive(userId);

        // Assert
        final updatedProfile = await socialService.getProfile(userId);
        expect(
            updatedProfile!.lastActiveAt.isAfter(originalLastActive), isTrue);
      });
    });

    group('Social Posts Management', () {
      test('should create a social post', () async {
        // Arrange
        const userId = 'user-123';
        const displayName = 'John Doe';
        const content = 'Just completed my first Flutter app! 🎉';
        final tags = ['flutter', 'achievement'];

        // Act
        final postId = await socialService.createPost(
          userId: userId,
          displayName: displayName,
          type: PostType.achievement,
          content: content,
          tags: tags,
          metadata: {'xpGained': 100},
        );

        // Assert
        expect(postId, isNotNull);
        expect(postId, isNotEmpty);
      });

      test('should get social feed', () async {
        // Arrange
        await socialService.createPost(
          userId: 'user1',
          displayName: 'User 1',
          type: PostType.achievement,
          content: 'Achievement post',
        );
        await socialService.createPost(
          userId: 'user2',
          displayName: 'User 2',
          type: PostType.streak,
          content: 'Streak post',
        );

        // Act
        final feed = await socialService.getSocialFeed();

        // Assert
        expect(feed, hasLength(2));
        expect(
            feed.first.createdAt.isAfter(feed.last.createdAt) ||
                feed.first.createdAt.isAtSameMomentAs(feed.last.createdAt),
            isTrue);
      });

      test('should get user posts', () async {
        // Arrange
        const userId = 'user-123';
        await socialService.createPost(
          userId: userId,
          displayName: 'Test User',
          type: PostType.progress,
          content: 'Progress update 1',
        );
        await socialService.createPost(
          userId: userId,
          displayName: 'Test User',
          type: PostType.milestone,
          content: 'Milestone reached!',
        );
        await socialService.createPost(
          userId: 'other-user',
          displayName: 'Other User',
          type: PostType.general,
          content: 'Other user post',
        );

        // Act
        final userPosts = await socialService.getUserPosts(userId);

        // Assert
        expect(userPosts, hasLength(2));
        expect(userPosts.every((p) => p.userId == userId), isTrue);
      });

      test('should toggle post like', () async {
        // Arrange
        const userId = 'user-123';
        final postId = await socialService.createPost(
          userId: 'post-author',
          displayName: 'Author',
          type: PostType.achievement,
          content: 'Test post',
        );

        // Act - Like the post
        final likeSuccess = await socialService.togglePostLike(postId!, userId);

        // Assert
        expect(likeSuccess, isTrue);
      });

      test('should delete own post', () async {
        // Arrange
        const userId = 'user-123';
        final postId = await socialService.createPost(
          userId: userId,
          displayName: 'Test User',
          type: PostType.general,
          content: 'Post to delete',
        );

        // Act
        final deleteSuccess = await socialService.deletePost(postId!, userId);

        // Assert
        expect(deleteSuccess, isTrue);
      });

      test('should not delete other user\'s post', () async {
        // Arrange
        final postId = await socialService.createPost(
          userId: 'post-author',
          displayName: 'Author',
          type: PostType.general,
          content: 'Other user post',
        );

        // Act
        final deleteSuccess =
            await socialService.deletePost(postId!, 'different-user');

        // Assert
        expect(deleteSuccess, isFalse);
      });
    });

    group('Comments Management', () {
      late String testPostId;

      setUp(() async {
        testPostId = await socialService.createPost(
              userId: 'post-author',
              displayName: 'Post Author',
              type: PostType.achievement,
              content: 'Test post for comments',
            ) ??
            '';
      });

      test('should add comment to post', () async {
        // Arrange
        const userId = 'commenter-123';
        const displayName = 'Commenter';
        const content = 'Great achievement! 👏';

        // Act
        final commentId = await socialService.addComment(
          postId: testPostId,
          userId: userId,
          displayName: displayName,
          content: content,
        );

        // Assert
        expect(commentId, isNotNull);
        expect(commentId, isNotEmpty);

        final comments = await socialService.getPostComments(testPostId);
        expect(comments, hasLength(1));
        expect(comments.first.content, equals(content));
        expect(comments.first.userId, equals(userId));
      });

      test('should get post comments', () async {
        // Arrange
        await socialService.addComment(
          postId: testPostId,
          userId: 'user1',
          displayName: 'User 1',
          content: 'First comment',
        );
        await socialService.addComment(
          postId: testPostId,
          userId: 'user2',
          displayName: 'User 2',
          content: 'Second comment',
        );

        // Act
        final comments = await socialService.getPostComments(testPostId);

        // Assert
        expect(comments, hasLength(2));
        expect(comments.first.content,
            equals('First comment')); // Ordered by creation time
        expect(comments.last.content, equals('Second comment'));
      });

      test('should delete own comment', () async {
        // Arrange
        const userId = 'commenter-123';
        final commentId = await socialService.addComment(
          postId: testPostId,
          userId: userId,
          displayName: 'Commenter',
          content: 'Comment to delete',
        );

        // Act
        final deleteSuccess =
            await socialService.deleteComment(commentId!, userId);

        // Assert
        expect(deleteSuccess, isTrue);

        final comments = await socialService.getPostComments(testPostId);
        expect(comments, isEmpty);
      });
    });

    group('Friendship Management', () {
      test('should send friend request', () async {
        // Arrange
        const requesterId = 'user-123';
        const receiverId = 'user-456';

        // Act
        final friendshipId =
            await socialService.sendFriendRequest(requesterId, receiverId);

        // Assert
        expect(friendshipId, isNotNull);
        expect(friendshipId, isNotEmpty);
      });

      test('should not send duplicate friend request', () async {
        // Arrange
        const requesterId = 'user-123';
        const receiverId = 'user-456';
        await socialService.sendFriendRequest(requesterId, receiverId);

        // Act
        final duplicateRequest =
            await socialService.sendFriendRequest(requesterId, receiverId);

        // Assert
        expect(duplicateRequest, isNull);
      });

      test('should accept friend request', () async {
        // Arrange
        const requesterId = 'user-123';
        const receiverId = 'user-456';
        final friendshipId =
            await socialService.sendFriendRequest(requesterId, receiverId);

        // Act
        final acceptSuccess =
            await socialService.acceptFriendRequest(friendshipId!);

        // Assert
        expect(acceptSuccess, isTrue);

        final areFriends =
            await socialService.areFriends(requesterId, receiverId);
        expect(areFriends, isTrue);
      });

      test('should decline friend request', () async {
        // Arrange
        const requesterId = 'user-123';
        const receiverId = 'user-456';
        final friendshipId =
            await socialService.sendFriendRequest(requesterId, receiverId);

        // Act
        final declineSuccess =
            await socialService.declineFriendRequest(friendshipId!);

        // Assert
        expect(declineSuccess, isTrue);

        final areFriends =
            await socialService.areFriends(requesterId, receiverId);
        expect(areFriends, isFalse);
      });

      test('should get pending friend requests', () async {
        // Arrange
        const receiverId = 'user-456';
        await socialService.sendFriendRequest('user-123', receiverId);
        await socialService.sendFriendRequest('user-789', receiverId);

        // Act
        final pendingRequests =
            await socialService.getPendingFriendRequests(receiverId);

        // Assert
        expect(pendingRequests, hasLength(2));
        expect(
            pendingRequests.every((r) => r.receiverId == receiverId), isTrue);
        expect(pendingRequests.every((r) => r.isPending), isTrue);
      });

      test('should get user friends', () async {
        // Arrange
        const userId = 'user-123';

        // Create friend profiles
        await socialService.createOrUpdateProfile(
          userId: 'friend1',
          displayName: 'Friend 1',
          interests: [],
        );
        await socialService.createOrUpdateProfile(
          userId: 'friend2',
          displayName: 'Friend 2',
          interests: [],
        );

        // Send and accept friend requests
        final friendship1 =
            await socialService.sendFriendRequest(userId, 'friend1');
        final friendship2 =
            await socialService.sendFriendRequest('friend2', userId);

        await socialService.acceptFriendRequest(friendship1!);
        await socialService.acceptFriendRequest(friendship2!);

        // Act
        final friends = await socialService.getUserFriends(userId);

        // Assert
        expect(friends, hasLength(2));
        expect(
            friends.map((f) => f.userId), containsAll(['friend1', 'friend2']));
      });

      test('should check if users are friends', () async {
        // Arrange
        const user1 = 'user-123';
        const user2 = 'user-456';
        const user3 = 'user-789';

        final friendshipId =
            await socialService.sendFriendRequest(user1, user2);
        await socialService.acceptFriendRequest(friendshipId!);

        // Act & Assert
        final areFriends12 = await socialService.areFriends(user1, user2);
        final areFriends13 = await socialService.areFriends(user1, user3);

        expect(areFriends12, isTrue);
        expect(areFriends13, isFalse);
      });
    });

    group('Error Handling', () {
      test('should handle non-existent profile gracefully', () async {
        // Act
        final profile = await socialService.getProfile('non-existent-user');

        // Assert
        expect(profile, isNull);
      });

      test('should handle empty search results', () async {
        // Act
        final searchResults =
            await socialService.searchUsers('NonExistentUser');

        // Assert
        expect(searchResults, isEmpty);
      });

      test('should handle non-existent post operations', () async {
        // Act
        final likeSuccess =
            await socialService.togglePostLike('non-existent-post', 'user');
        final deleteSuccess =
            await socialService.deletePost('non-existent-post', 'user');

        // Assert
        expect(likeSuccess, isFalse);
        expect(deleteSuccess, isFalse);
      });

      test('should handle non-existent friendship operations', () async {
        // Act
        final acceptSuccess =
            await socialService.acceptFriendRequest('non-existent-friendship');
        final declineSuccess =
            await socialService.declineFriendRequest('non-existent-friendship');

        // Assert
        expect(acceptSuccess, isFalse);
        expect(declineSuccess, isFalse);
      });
    });
  });
}
