import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'social_learning.g.dart';

@JsonSerializable()
class SocialProfile {
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final String? bio;
  final List<String> interests;
  final Map<String, dynamic> stats;
  final SocialSettings settings;
  final DateTime joinedAt;
  final DateTime lastActiveAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SocialProfile({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    this.bio,
    required this.interests,
    required this.stats,
    required this.settings,
    required this.joinedAt,
    required this.lastActiveAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SocialProfile.fromJson(Map<String, dynamic> json) =>
      _$SocialProfileFromJson(json);
  Map<String, dynamic> toJson() => _$SocialProfileToJson(this);

  factory SocialProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SocialProfile.fromJson({
      'userId': doc.id,
      ...data,
      'joinedAt': (data['joinedAt'] as Timestamp).toDate().toIso8601String(),
      'lastActiveAt':
          (data['lastActiveAt'] as Timestamp).toDate().toIso8601String(),
      'createdAt': (data['createdAt'] as Timestamp).toDate().toIso8601String(),
      'updatedAt': (data['updatedAt'] as Timestamp).toDate().toIso8601String(),
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    return {
      ...json,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'lastActiveAt': Timestamp.fromDate(lastActiveAt),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    }..remove('userId');
  }

  SocialProfile copyWith({
    String? userId,
    String? displayName,
    String? avatarUrl,
    String? bio,
    List<String>? interests,
    Map<String, dynamic>? stats,
    SocialSettings? settings,
    DateTime? joinedAt,
    DateTime? lastActiveAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SocialProfile(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      interests: interests ?? this.interests,
      stats: stats ?? this.stats,
      settings: settings ?? this.settings,
      joinedAt: joinedAt ?? this.joinedAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class SocialSettings {
  final bool shareAchievements;
  final bool shareStreak;
  final bool shareProgress;
  final bool allowFriendRequests;
  final bool showOnlineStatus;
  final PrivacyLevel profileVisibility;
  final PrivacyLevel activityVisibility;

  const SocialSettings({
    required this.shareAchievements,
    required this.shareStreak,
    required this.shareProgress,
    required this.allowFriendRequests,
    required this.showOnlineStatus,
    required this.profileVisibility,
    required this.activityVisibility,
  });

  factory SocialSettings.fromJson(Map<String, dynamic> json) =>
      _$SocialSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$SocialSettingsToJson(this);

  factory SocialSettings.defaultSettings() {
    return const SocialSettings(
      shareAchievements: true,
      shareStreak: true,
      shareProgress: false,
      allowFriendRequests: true,
      showOnlineStatus: true,
      profileVisibility: PrivacyLevel.friends,
      activityVisibility: PrivacyLevel.friends,
    );
  }

  SocialSettings copyWith({
    bool? shareAchievements,
    bool? shareStreak,
    bool? shareProgress,
    bool? allowFriendRequests,
    bool? showOnlineStatus,
    PrivacyLevel? profileVisibility,
    PrivacyLevel? activityVisibility,
  }) {
    return SocialSettings(
      shareAchievements: shareAchievements ?? this.shareAchievements,
      shareStreak: shareStreak ?? this.shareStreak,
      shareProgress: shareProgress ?? this.shareProgress,
      allowFriendRequests: allowFriendRequests ?? this.allowFriendRequests,
      showOnlineStatus: showOnlineStatus ?? this.showOnlineStatus,
      profileVisibility: profileVisibility ?? this.profileVisibility,
      activityVisibility: activityVisibility ?? this.activityVisibility,
    );
  }
}

@JsonSerializable()
class SocialPost {
  final String id;
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final PostType type;
  final String content;
  final Map<String, dynamic> metadata;
  final List<String> tags;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final bool isLikedByCurrentUser;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SocialPost({
    required this.id,
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    required this.type,
    required this.content,
    required this.metadata,
    required this.tags,
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
    required this.isLikedByCurrentUser,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SocialPost.fromJson(Map<String, dynamic> json) =>
      _$SocialPostFromJson(json);
  Map<String, dynamic> toJson() => _$SocialPostToJson(this);

  factory SocialPost.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SocialPost.fromJson({
      'id': doc.id,
      ...data,
      'createdAt': (data['createdAt'] as Timestamp).toDate().toIso8601String(),
      'updatedAt': (data['updatedAt'] as Timestamp).toDate().toIso8601String(),
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    return {
      ...json,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    }..remove('id');
  }

  SocialPost copyWith({
    String? id,
    String? userId,
    String? displayName,
    String? avatarUrl,
    PostType? type,
    String? content,
    Map<String, dynamic>? metadata,
    List<String>? tags,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    bool? isLikedByCurrentUser,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SocialPost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      type: type ?? this.type,
      content: content ?? this.content,
      metadata: metadata ?? this.metadata,
      tags: tags ?? this.tags,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class SocialComment {
  final String id;
  final String postId;
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final String content;
  final int likesCount;
  final bool isLikedByCurrentUser;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SocialComment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    required this.content,
    required this.likesCount,
    required this.isLikedByCurrentUser,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SocialComment.fromJson(Map<String, dynamic> json) =>
      _$SocialCommentFromJson(json);
  Map<String, dynamic> toJson() => _$SocialCommentToJson(this);

  factory SocialComment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SocialComment.fromJson({
      'id': doc.id,
      ...data,
      'createdAt': (data['createdAt'] as Timestamp).toDate().toIso8601String(),
      'updatedAt': (data['updatedAt'] as Timestamp).toDate().toIso8601String(),
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    return {
      ...json,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    }..remove('id');
  }

  SocialComment copyWith({
    String? id,
    String? postId,
    String? userId,
    String? displayName,
    String? avatarUrl,
    String? content,
    int? likesCount,
    bool? isLikedByCurrentUser,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SocialComment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      content: content ?? this.content,
      likesCount: likesCount ?? this.likesCount,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class Friendship {
  final String id;
  final String requesterId;
  final String receiverId;
  final FriendshipStatus status;
  final DateTime requestedAt;
  final DateTime? acceptedAt;
  final DateTime updatedAt;

  const Friendship({
    required this.id,
    required this.requesterId,
    required this.receiverId,
    required this.status,
    required this.requestedAt,
    this.acceptedAt,
    required this.updatedAt,
  });

  factory Friendship.fromJson(Map<String, dynamic> json) =>
      _$FriendshipFromJson(json);
  Map<String, dynamic> toJson() => _$FriendshipToJson(this);

  factory Friendship.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Friendship.fromJson({
      'id': doc.id,
      ...data,
      'requestedAt':
          (data['requestedAt'] as Timestamp).toDate().toIso8601String(),
      'acceptedAt': data['acceptedAt'] != null
          ? (data['acceptedAt'] as Timestamp).toDate().toIso8601String()
          : null,
      'updatedAt': (data['updatedAt'] as Timestamp).toDate().toIso8601String(),
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    return {
      ...json,
      'requestedAt': Timestamp.fromDate(requestedAt),
      'acceptedAt': acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
      'updatedAt': Timestamp.fromDate(updatedAt),
    }..remove('id');
  }

  Friendship copyWith({
    String? id,
    String? requesterId,
    String? receiverId,
    FriendshipStatus? status,
    DateTime? requestedAt,
    DateTime? acceptedAt,
    DateTime? updatedAt,
  }) {
    return Friendship(
      id: id ?? this.id,
      requesterId: requesterId ?? this.requesterId,
      receiverId: receiverId ?? this.receiverId,
      status: status ?? this.status,
      requestedAt: requestedAt ?? this.requestedAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isPending => status == FriendshipStatus.pending;
  bool get isAccepted => status == FriendshipStatus.accepted;
  bool get isBlocked => status == FriendshipStatus.blocked;
}

// Enums
enum PrivacyLevel {
  @JsonValue('public')
  public,
  @JsonValue('friends')
  friends,
  @JsonValue('private')
  private,
}

enum PostType {
  @JsonValue('achievement')
  achievement,
  @JsonValue('streak')
  streak,
  @JsonValue('progress')
  progress,
  @JsonValue('milestone')
  milestone,
  @JsonValue('general')
  general,
}

enum FriendshipStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('accepted')
  accepted,
  @JsonValue('blocked')
  blocked,
  @JsonValue('declined')
  declined,
}

// Extension methods
extension PrivacyLevelExtension on PrivacyLevel {
  String get displayName {
    switch (this) {
      case PrivacyLevel.public:
        return 'Public';
      case PrivacyLevel.friends:
        return 'Friends Only';
      case PrivacyLevel.private:
        return 'Private';
    }
  }

  String get description {
    switch (this) {
      case PrivacyLevel.public:
        return 'Visible to everyone';
      case PrivacyLevel.friends:
        return 'Visible to friends only';
      case PrivacyLevel.private:
        return 'Only visible to you';
    }
  }
}

extension PostTypeExtension on PostType {
  String get displayName {
    switch (this) {
      case PostType.achievement:
        return 'Achievement';
      case PostType.streak:
        return 'Learning Streak';
      case PostType.progress:
        return 'Progress Update';
      case PostType.milestone:
        return 'Milestone';
      case PostType.general:
        return 'General';
    }
  }

  IconData get icon {
    switch (this) {
      case PostType.achievement:
        return Icons.emoji_events;
      case PostType.streak:
        return Icons.local_fire_department;
      case PostType.progress:
        return Icons.trending_up;
      case PostType.milestone:
        return Icons.flag;
      case PostType.general:
        return Icons.chat;
    }
  }
}

extension FriendshipStatusExtension on FriendshipStatus {
  String get displayName {
    switch (this) {
      case FriendshipStatus.pending:
        return 'Pending';
      case FriendshipStatus.accepted:
        return 'Friends';
      case FriendshipStatus.blocked:
        return 'Blocked';
      case FriendshipStatus.declined:
        return 'Declined';
    }
  }
}
