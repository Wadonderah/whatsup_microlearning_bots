import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../models/social_learning.dart';

class SocialLearningService {
  static SocialLearningService? _instance;
  static SocialLearningService get instance => _instance ??= SocialLearningService._();
  
  SocialLearningService._();

  final Uuid _uuid = const Uuid();

  // Collection references
  CollectionReference<SocialProfile> get _profilesCollection =>
      FirebaseFirestore.instance.collection('social_profiles').withConverter<SocialProfile>(
        fromFirestore: (snapshot, _) => SocialProfile.fromFirestore(snapshot),
        toFirestore: (profile, _) => profile.toFirestore(),
      );

  CollectionReference<SocialPost> get _postsCollection =>
      FirebaseFirestore.instance.collection('social_posts').withConverter<SocialPost>(
        fromFirestore: (snapshot, _) => SocialPost.fromFirestore(snapshot),
        toFirestore: (post, _) => post.toFirestore(),
      );

  CollectionReference<SocialComment> get _commentsCollection =>
      FirebaseFirestore.instance.collection('social_comments').withConverter<SocialComment>(
        fromFirestore: (snapshot, _) => SocialComment.fromFirestore(snapshot),
        toFirestore: (comment, _) => comment.toFirestore(),
      );

  CollectionReference<Friendship> get _friendshipsCollection =>
      FirebaseFirestore.instance.collection('friendships').withConverter<Friendship>(
        fromFirestore: (snapshot, _) => Friendship.fromFirestore(snapshot),
        toFirestore: (friendship, _) => friendship.toFirestore(),
      );

  // Social Profile Management
  /// Create or update social profile
  Future<bool> createOrUpdateProfile({
    required String userId,
    required String displayName,
    String? avatarUrl,
    String? bio,
    List<String>? interests,
    SocialSettings? settings,
  }) async {
    try {
      final now = DateTime.now();
      final existingProfile = await getProfile(userId);

      if (existingProfile != null) {
        // Update existing profile
        final updatedProfile = existingProfile.copyWith(
          displayName: displayName,
          avatarUrl: avatarUrl,
          bio: bio,
          interests: interests,
          settings: settings,
          lastActiveAt: now,
          updatedAt: now,
        );
        await _profilesCollection.doc(userId).set(updatedProfile);
      } else {
        // Create new profile
        final newProfile = SocialProfile(
          userId: userId,
          displayName: displayName,
          avatarUrl: avatarUrl,
          bio: bio,
          interests: interests ?? [],
          stats: {},
          settings: settings ?? SocialSettings.defaultSettings(),
          joinedAt: now,
          lastActiveAt: now,
          createdAt: now,
          updatedAt: now,
        );
        await _profilesCollection.doc(userId).set(newProfile);
      }

      log('Social profile created/updated for user: $userId');
      return true;
    } catch (e) {
      log('Error creating/updating social profile: $e');
      return false;
    }
  }

  /// Get user's social profile
  Future<SocialProfile?> getProfile(String userId) async {
    try {
      final doc = await _profilesCollection.doc(userId).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      log('Error getting social profile: $e');
      return null;
    }
  }

  /// Search for users
  Future<List<SocialProfile>> searchUsers(String query, {int limit = 20}) async {
    try {
      // Note: This is a simple implementation. For production, consider using
      // a dedicated search service like Algolia or Elasticsearch
      final snapshot = await _profilesCollection
          .where('displayName', isGreaterThanOrEqualTo: query)
          .where('displayName', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(limit)
          .get();
      
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      log('Error searching users: $e');
      return [];
    }
  }

  /// Update last active time
  Future<void> updateLastActive(String userId) async {
    try {
      await _profilesCollection.doc(userId).update({
        'lastActiveAt': Timestamp.fromDate(DateTime.now()),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      log('Error updating last active: $e');
    }
  }

  // Social Posts Management
  /// Create a social post
  Future<String?> createPost({
    required String userId,
    required String displayName,
    String? avatarUrl,
    required PostType type,
    required String content,
    Map<String, dynamic>? metadata,
    List<String>? tags,
  }) async {
    try {
      final postId = _uuid.v4();
      final now = DateTime.now();

      final post = SocialPost(
        id: postId,
        userId: userId,
        displayName: displayName,
        avatarUrl: avatarUrl,
        type: type,
        content: content,
        metadata: metadata ?? {},
        tags: tags ?? [],
        likesCount: 0,
        commentsCount: 0,
        sharesCount: 0,
        isLikedByCurrentUser: false,
        createdAt: now,
        updatedAt: now,
      );

      await _postsCollection.doc(postId).set(post);
      log('Social post created: $postId');
      return postId;
    } catch (e) {
      log('Error creating social post: $e');
      return null;
    }
  }

  /// Get social feed
  Future<List<SocialPost>> getSocialFeed({
    String? userId,
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query<SocialPost> query = _postsCollection
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      log('Error getting social feed: $e');
      return [];
    }
  }

  /// Get user's posts
  Future<List<SocialPost>> getUserPosts(String userId, {int limit = 20}) async {
    try {
      final snapshot = await _postsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      log('Error getting user posts: $e');
      return [];
    }
  }

  /// Like/unlike a post
  Future<bool> togglePostLike(String postId, String userId) async {
    try {
      final postDoc = await _postsCollection.doc(postId).get();
      if (!postDoc.exists) return false;

      final post = postDoc.data()!;
      final isCurrentlyLiked = post.isLikedByCurrentUser;
      
      // Update like count and user's like status
      final updatedPost = post.copyWith(
        likesCount: isCurrentlyLiked ? post.likesCount - 1 : post.likesCount + 1,
        isLikedByCurrentUser: !isCurrentlyLiked,
        updatedAt: DateTime.now(),
      );

      await _postsCollection.doc(postId).set(updatedPost);
      
      // TODO: Store individual likes in a separate collection for better tracking
      
      return true;
    } catch (e) {
      log('Error toggling post like: $e');
      return false;
    }
  }

  /// Delete a post
  Future<bool> deletePost(String postId, String userId) async {
    try {
      final postDoc = await _postsCollection.doc(postId).get();
      if (!postDoc.exists) return false;

      final post = postDoc.data()!;
      if (post.userId != userId) return false; // Only owner can delete

      await _postsCollection.doc(postId).delete();
      
      // Also delete associated comments
      final commentsSnapshot = await _commentsCollection
          .where('postId', isEqualTo: postId)
          .get();
      
      final batch = FirebaseFirestore.instance.batch();
      for (final doc in commentsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      log('Post deleted: $postId');
      return true;
    } catch (e) {
      log('Error deleting post: $e');
      return false;
    }
  }

  // Comments Management
  /// Add comment to a post
  Future<String?> addComment({
    required String postId,
    required String userId,
    required String displayName,
    String? avatarUrl,
    required String content,
  }) async {
    try {
      final commentId = _uuid.v4();
      final now = DateTime.now();

      final comment = SocialComment(
        id: commentId,
        postId: postId,
        userId: userId,
        displayName: displayName,
        avatarUrl: avatarUrl,
        content: content,
        likesCount: 0,
        isLikedByCurrentUser: false,
        createdAt: now,
        updatedAt: now,
      );

      await _commentsCollection.doc(commentId).set(comment);

      // Update post comment count
      await _updatePostCommentCount(postId, 1);

      log('Comment added: $commentId');
      return commentId;
    } catch (e) {
      log('Error adding comment: $e');
      return null;
    }
  }

  /// Get comments for a post
  Future<List<SocialComment>> getPostComments(String postId, {int limit = 50}) async {
    try {
      final snapshot = await _commentsCollection
          .where('postId', isEqualTo: postId)
          .orderBy('createdAt')
          .limit(limit)
          .get();
      
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      log('Error getting post comments: $e');
      return [];
    }
  }

  /// Delete a comment
  Future<bool> deleteComment(String commentId, String userId) async {
    try {
      final commentDoc = await _commentsCollection.doc(commentId).get();
      if (!commentDoc.exists) return false;

      final comment = commentDoc.data()!;
      if (comment.userId != userId) return false; // Only owner can delete

      await _commentsCollection.doc(commentId).delete();
      
      // Update post comment count
      await _updatePostCommentCount(comment.postId, -1);

      log('Comment deleted: $commentId');
      return true;
    } catch (e) {
      log('Error deleting comment: $e');
      return false;
    }
  }

  /// Update post comment count
  Future<void> _updatePostCommentCount(String postId, int delta) async {
    try {
      final postDoc = await _postsCollection.doc(postId).get();
      if (postDoc.exists) {
        final post = postDoc.data()!;
        final updatedPost = post.copyWith(
          commentsCount: (post.commentsCount + delta).clamp(0, double.infinity).toInt(),
          updatedAt: DateTime.now(),
        );
        await _postsCollection.doc(postId).set(updatedPost);
      }
    } catch (e) {
      log('Error updating post comment count: $e');
    }
  }

  // Friendship Management
  /// Send friend request
  Future<String?> sendFriendRequest(String requesterId, String receiverId) async {
    try {
      // Check if friendship already exists
      final existingFriendship = await _getFriendship(requesterId, receiverId);
      if (existingFriendship != null) {
        log('Friendship already exists between $requesterId and $receiverId');
        return null;
      }

      final friendshipId = _uuid.v4();
      final now = DateTime.now();

      final friendship = Friendship(
        id: friendshipId,
        requesterId: requesterId,
        receiverId: receiverId,
        status: FriendshipStatus.pending,
        requestedAt: now,
        updatedAt: now,
      );

      await _friendshipsCollection.doc(friendshipId).set(friendship);
      log('Friend request sent: $friendshipId');
      return friendshipId;
    } catch (e) {
      log('Error sending friend request: $e');
      return null;
    }
  }

  /// Accept friend request
  Future<bool> acceptFriendRequest(String friendshipId) async {
    try {
      final friendshipDoc = await _friendshipsCollection.doc(friendshipId).get();
      if (!friendshipDoc.exists) return false;

      final friendship = friendshipDoc.data()!;
      if (friendship.status != FriendshipStatus.pending) return false;

      final updatedFriendship = friendship.copyWith(
        status: FriendshipStatus.accepted,
        acceptedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _friendshipsCollection.doc(friendshipId).set(updatedFriendship);
      log('Friend request accepted: $friendshipId');
      return true;
    } catch (e) {
      log('Error accepting friend request: $e');
      return false;
    }
  }

  /// Decline friend request
  Future<bool> declineFriendRequest(String friendshipId) async {
    try {
      final friendshipDoc = await _friendshipsCollection.doc(friendshipId).get();
      if (!friendshipDoc.exists) return false;

      final friendship = friendshipDoc.data()!;
      if (friendship.status != FriendshipStatus.pending) return false;

      final updatedFriendship = friendship.copyWith(
        status: FriendshipStatus.declined,
        updatedAt: DateTime.now(),
      );

      await _friendshipsCollection.doc(friendshipId).set(updatedFriendship);
      log('Friend request declined: $friendshipId');
      return true;
    } catch (e) {
      log('Error declining friend request: $e');
      return false;
    }
  }

  /// Get user's friends
  Future<List<SocialProfile>> getUserFriends(String userId) async {
    try {
      final friendshipsSnapshot = await _friendshipsCollection
          .where('status', isEqualTo: 'accepted')
          .get();
      
      final friendUserIds = <String>[];
      for (final doc in friendshipsSnapshot.docs) {
        final friendship = doc.data();
        if (friendship.requesterId == userId) {
          friendUserIds.add(friendship.receiverId);
        } else if (friendship.receiverId == userId) {
          friendUserIds.add(friendship.requesterId);
        }
      }

      if (friendUserIds.isEmpty) return [];

      // Get friend profiles
      final friends = <SocialProfile>[];
      for (final friendId in friendUserIds) {
        final profile = await getProfile(friendId);
        if (profile != null) {
          friends.add(profile);
        }
      }

      return friends;
    } catch (e) {
      log('Error getting user friends: $e');
      return [];
    }
  }

  /// Get pending friend requests
  Future<List<Friendship>> getPendingFriendRequests(String userId) async {
    try {
      final snapshot = await _friendshipsCollection
          .where('receiverId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .orderBy('requestedAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      log('Error getting pending friend requests: $e');
      return [];
    }
  }

  /// Check if users are friends
  Future<bool> areFriends(String userId1, String userId2) async {
    try {
      final friendship = await _getFriendship(userId1, userId2);
      return friendship?.isAccepted ?? false;
    } catch (e) {
      log('Error checking friendship: $e');
      return false;
    }
  }

  /// Get friendship between two users
  Future<Friendship?> _getFriendship(String userId1, String userId2) async {
    try {
      // Check both directions
      final snapshot1 = await _friendshipsCollection
          .where('requesterId', isEqualTo: userId1)
          .where('receiverId', isEqualTo: userId2)
          .limit(1)
          .get();
      
      if (snapshot1.docs.isNotEmpty) {
        return snapshot1.docs.first.data();
      }

      final snapshot2 = await _friendshipsCollection
          .where('requesterId', isEqualTo: userId2)
          .where('receiverId', isEqualTo: userId1)
          .limit(1)
          .get();
      
      if (snapshot2.docs.isNotEmpty) {
        return snapshot2.docs.first.data();
      }

      return null;
    } catch (e) {
      log('Error getting friendship: $e');
      return null;
    }
  }

  // Stream methods for real-time updates
  /// Stream social feed
  Stream<List<SocialPost>> streamSocialFeed({int limit = 20}) {
    return _postsCollection
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Stream user's posts
  Stream<List<SocialPost>> streamUserPosts(String userId, {int limit = 20}) {
    return _postsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Stream post comments
  Stream<List<SocialComment>> streamPostComments(String postId, {int limit = 50}) {
    return _commentsCollection
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt')
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Stream pending friend requests
  Stream<List<Friendship>> streamPendingFriendRequests(String userId) {
    return _friendshipsCollection
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
