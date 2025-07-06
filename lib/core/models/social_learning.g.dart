// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_learning.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SocialProfile _$SocialProfileFromJson(Map<String, dynamic> json) =>
    SocialProfile(
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      bio: json['bio'] as String?,
      interests:
          (json['interests'] as List<dynamic>).map((e) => e as String).toList(),
      stats: json['stats'] as Map<String, dynamic>,
      settings:
          SocialSettings.fromJson(json['settings'] as Map<String, dynamic>),
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      lastActiveAt: DateTime.parse(json['lastActiveAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$SocialProfileToJson(SocialProfile instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'displayName': instance.displayName,
      'avatarUrl': instance.avatarUrl,
      'bio': instance.bio,
      'interests': instance.interests,
      'stats': instance.stats,
      'settings': instance.settings,
      'joinedAt': instance.joinedAt.toIso8601String(),
      'lastActiveAt': instance.lastActiveAt.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

SocialSettings _$SocialSettingsFromJson(Map<String, dynamic> json) =>
    SocialSettings(
      shareAchievements: json['shareAchievements'] as bool,
      shareStreak: json['shareStreak'] as bool,
      shareProgress: json['shareProgress'] as bool,
      allowFriendRequests: json['allowFriendRequests'] as bool,
      showOnlineStatus: json['showOnlineStatus'] as bool,
      profileVisibility:
          $enumDecode(_$PrivacyLevelEnumMap, json['profileVisibility']),
      activityVisibility:
          $enumDecode(_$PrivacyLevelEnumMap, json['activityVisibility']),
    );

Map<String, dynamic> _$SocialSettingsToJson(SocialSettings instance) =>
    <String, dynamic>{
      'shareAchievements': instance.shareAchievements,
      'shareStreak': instance.shareStreak,
      'shareProgress': instance.shareProgress,
      'allowFriendRequests': instance.allowFriendRequests,
      'showOnlineStatus': instance.showOnlineStatus,
      'profileVisibility': _$PrivacyLevelEnumMap[instance.profileVisibility]!,
      'activityVisibility': _$PrivacyLevelEnumMap[instance.activityVisibility]!,
    };

const _$PrivacyLevelEnumMap = {
  PrivacyLevel.public: 'public',
  PrivacyLevel.friends: 'friends',
  PrivacyLevel.private: 'private',
};

SocialPost _$SocialPostFromJson(Map<String, dynamic> json) => SocialPost(
      id: json['id'] as String,
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      type: $enumDecode(_$PostTypeEnumMap, json['type']),
      content: json['content'] as String,
      metadata: json['metadata'] as Map<String, dynamic>,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      likesCount: (json['likesCount'] as num).toInt(),
      commentsCount: (json['commentsCount'] as num).toInt(),
      sharesCount: (json['sharesCount'] as num).toInt(),
      isLikedByCurrentUser: json['isLikedByCurrentUser'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$SocialPostToJson(SocialPost instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'displayName': instance.displayName,
      'avatarUrl': instance.avatarUrl,
      'type': _$PostTypeEnumMap[instance.type]!,
      'content': instance.content,
      'metadata': instance.metadata,
      'tags': instance.tags,
      'likesCount': instance.likesCount,
      'commentsCount': instance.commentsCount,
      'sharesCount': instance.sharesCount,
      'isLikedByCurrentUser': instance.isLikedByCurrentUser,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$PostTypeEnumMap = {
  PostType.achievement: 'achievement',
  PostType.streak: 'streak',
  PostType.progress: 'progress',
  PostType.milestone: 'milestone',
  PostType.general: 'general',
};

SocialComment _$SocialCommentFromJson(Map<String, dynamic> json) =>
    SocialComment(
      id: json['id'] as String,
      postId: json['postId'] as String,
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      content: json['content'] as String,
      likesCount: (json['likesCount'] as num).toInt(),
      isLikedByCurrentUser: json['isLikedByCurrentUser'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$SocialCommentToJson(SocialComment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'postId': instance.postId,
      'userId': instance.userId,
      'displayName': instance.displayName,
      'avatarUrl': instance.avatarUrl,
      'content': instance.content,
      'likesCount': instance.likesCount,
      'isLikedByCurrentUser': instance.isLikedByCurrentUser,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

Friendship _$FriendshipFromJson(Map<String, dynamic> json) => Friendship(
      id: json['id'] as String,
      requesterId: json['requesterId'] as String,
      receiverId: json['receiverId'] as String,
      status: $enumDecode(_$FriendshipStatusEnumMap, json['status']),
      requestedAt: DateTime.parse(json['requestedAt'] as String),
      acceptedAt: json['acceptedAt'] == null
          ? null
          : DateTime.parse(json['acceptedAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$FriendshipToJson(Friendship instance) =>
    <String, dynamic>{
      'id': instance.id,
      'requesterId': instance.requesterId,
      'receiverId': instance.receiverId,
      'status': _$FriendshipStatusEnumMap[instance.status]!,
      'requestedAt': instance.requestedAt.toIso8601String(),
      'acceptedAt': instance.acceptedAt?.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$FriendshipStatusEnumMap = {
  FriendshipStatus.pending: 'pending',
  FriendshipStatus.accepted: 'accepted',
  FriendshipStatus.blocked: 'blocked',
  FriendshipStatus.declined: 'declined',
};
