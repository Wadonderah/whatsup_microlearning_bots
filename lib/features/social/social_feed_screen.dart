import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/social_learning.dart';
import '../../core/services/social_learning_service.dart';
import '../auth/providers/auth_provider.dart';

// Social feed provider
final socialFeedProvider = StreamProvider<List<SocialPost>>((ref) {
  return SocialLearningService.instance.streamSocialFeed();
});

// User social profile provider
final userSocialProfileProvider =
    FutureProvider.family<SocialProfile?, String>((ref, userId) {
  return SocialLearningService.instance.getProfile(userId);
});

class SocialFeedScreen extends ConsumerStatefulWidget {
  const SocialFeedScreen({super.key});

  @override
  ConsumerState<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends ConsumerState<SocialFeedScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _postController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _postController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    if (authState.user == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view social features')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Learning'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () => _showFriendsScreen(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Feed'),
            Tab(text: 'Friends'),
            Tab(text: 'My Posts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFeedTab(),
          _buildFriendsTab(),
          _buildMyPostsTab(authState.user!.uid),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePostDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFeedTab() {
    final socialFeedAsync = ref.watch(socialFeedProvider);

    return socialFeedAsync.when(
      data: (posts) => _buildPostsList(posts),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorWidget(error),
    );
  }

  Widget _buildFriendsTab() {
    return const Center(
      child: Text('Friends tab coming soon!'),
    );
  }

  Widget _buildMyPostsTab(String userId) {
    return StreamBuilder<List<SocialPost>>(
      stream: SocialLearningService.instance.streamUserPosts(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error);
        }

        final posts = snapshot.data ?? [];
        return _buildPostsList(posts);
      },
    );
  }

  Widget _buildPostsList(List<SocialPost> posts) {
    if (posts.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        // ignore: unused_result
        ref.refresh(socialFeedProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return _buildPostCard(posts[index]);
        },
      ),
    );
  }

  Widget _buildPostCard(SocialPost post) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPostHeader(post),
            const SizedBox(height: 12),
            _buildPostContent(post),
            const SizedBox(height: 12),
            _buildPostActions(post),
          ],
        ),
      ),
    );
  }

  Widget _buildPostHeader(SocialPost post) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage:
              post.avatarUrl != null ? NetworkImage(post.avatarUrl!) : null,
          child: post.avatarUrl == null
              ? Text(post.displayName.substring(0, 1).toUpperCase())
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.displayName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _formatTimestamp(post.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getPostTypeColor(post.type).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                post.type.icon,
                size: 14,
                color: _getPostTypeColor(post.type),
              ),
              const SizedBox(width: 4),
              Text(
                post.type.displayName,
                style: TextStyle(
                  fontSize: 10,
                  color: _getPostTypeColor(post.type),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPostContent(SocialPost post) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          post.content,
          style: const TextStyle(fontSize: 14, height: 1.4),
        ),
        if (post.tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: post.tags
                .map((tag) => Chip(
                      label: Text('#$tag'),
                      backgroundColor: Colors.blue[50],
                      labelStyle: const TextStyle(fontSize: 10),
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildPostActions(SocialPost post) {
    return Row(
      children: [
        InkWell(
          onTap: () => _toggleLike(post),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  post.isLikedByCurrentUser
                      ? Icons.favorite
                      : Icons.favorite_border,
                  size: 18,
                  color:
                      post.isLikedByCurrentUser ? Colors.red : Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '${post.likesCount}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        InkWell(
          onTap: () => _showCommentsDialog(post),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.comment_outlined,
                  size: 18,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '${post.commentsCount}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        InkWell(
          onTap: () => _sharePost(post),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.share_outlined,
                  size: 18,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '${post.sharesCount}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        PopupMenuButton<String>(
          onSelected: (value) => _handlePostAction(value, post),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'report',
              child: Text('Report'),
            ),
            if (post.userId == ref.read(authProvider).user?.uid)
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete'),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No posts yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Share your learning achievements to get started!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCreatePostDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Create Post'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(Object? error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error loading social feed: $error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.refresh(socialFeedProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Color _getPostTypeColor(PostType type) {
    switch (type) {
      case PostType.achievement:
        return Colors.amber;
      case PostType.streak:
        return Colors.orange;
      case PostType.progress:
        return Colors.blue;
      case PostType.milestone:
        return Colors.green;
      case PostType.general:
        return Colors.grey;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  void _showCreatePostDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _postController,
              decoration: const InputDecoration(
                hintText: 'Share your learning progress...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _createPost(),
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    // TODO: Implement user search
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Search feature coming soon!')),
    );
  }

  void _showFriendsScreen() {
    // TODO: Navigate to friends screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Friends screen coming soon!')),
    );
  }

  void _showCommentsDialog(SocialPost post) {
    // TODO: Show comments dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comments feature coming soon!')),
    );
  }

  void _createPost() async {
    final content = _postController.text.trim();
    if (content.isEmpty) return;

    final authState = ref.read(authProvider);
    if (authState.user == null) return;

    try {
      await SocialLearningService.instance.createPost(
        userId: authState.user!.uid,
        displayName: authState.user!.displayName ?? 'Anonymous',
        avatarUrl: authState.user!.photoURL,
        type: PostType.general,
        content: content,
      );

      _postController.clear();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post created successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating post: $e')),
        );
      }
    }
  }

  void _toggleLike(SocialPost post) async {
    final authState = ref.read(authProvider);
    if (authState.user == null) return;

    try {
      await SocialLearningService.instance.togglePostLike(
        post.id,
        authState.user!.uid,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error toggling like: $e')),
        );
      }
    }
  }

  void _sharePost(SocialPost post) {
    // TODO: Implement post sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share feature coming soon!')),
    );
  }

  void _handlePostAction(String action, SocialPost post) async {
    switch (action) {
      case 'report':
        // TODO: Implement post reporting
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report feature coming soon!')),
        );
        break;
      case 'delete':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Post'),
            content: const Text('Are you sure you want to delete this post?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          try {
            final authState = ref.read(authProvider);
            await SocialLearningService.instance.deletePost(
              post.id,
              authState.user!.uid,
            );

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Post deleted')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error deleting post: $e')),
              );
            }
          }
        }
        break;
    }
  }
}
