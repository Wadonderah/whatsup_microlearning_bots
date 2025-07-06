// ignore_for_file: unused_result

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_assets.dart';
import '../../core/models/learning_category.dart';
import '../../core/services/learning_content_service.dart';
import '../auth/providers/auth_provider.dart';
import 'category_detail_screen.dart';

// Learning categories provider
final learningCategoriesProvider =
    FutureProvider<List<LearningCategory>>((ref) {
  return LearningContentService.instance.getCategories();
});

// Featured categories provider
final featuredCategoriesProvider =
    FutureProvider<List<LearningCategory>>((ref) {
  return LearningContentService.instance.getFeaturedCategories();
});

// User learning stats provider
final userLearningStatsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, userId) {
  return LearningContentService.instance.getUserLearningStats(userId);
});

class LearningCategoriesScreen extends ConsumerStatefulWidget {
  const LearningCategoriesScreen({super.key});

  @override
  ConsumerState<LearningCategoriesScreen> createState() =>
      _LearningCategoriesScreenState();
}

class _LearningCategoriesScreenState
    extends ConsumerState<LearningCategoriesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initialize default categories if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      LearningContentService.instance.initializeDefaultCategories();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Categories'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Featured'),
            Tab(text: 'All Categories'),
            Tab(text: 'My Progress'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFeaturedTab(),
                _buildAllCategoriesTab(),
                _buildMyProgressTab(authState.user?.uid),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search categories...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }

  Widget _buildFeaturedTab() {
    final featuredCategoriesAsync = ref.watch(featuredCategoriesProvider);

    return featuredCategoriesAsync.when(
      data: (categories) {
        final filteredCategories = _filterCategories(categories);
        return _buildCategoriesGrid(filteredCategories, isFeatured: true);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorWidget(error),
    );
  }

  Widget _buildAllCategoriesTab() {
    final categoriesAsync = ref.watch(learningCategoriesProvider);

    return categoriesAsync.when(
      data: (categories) {
        final filteredCategories = _filterCategories(categories);
        return _buildCategoriesGrid(filteredCategories);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorWidget(error),
    );
  }

  Widget _buildMyProgressTab(String? userId) {
    if (userId == null) {
      return const Center(
        child: Text('Please log in to view your progress'),
      );
    }

    final statsAsync = ref.watch(userLearningStatsProvider(userId));

    return statsAsync.when(
      data: (stats) => _buildProgressView(stats),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorWidget(error),
    );
  }

  Widget _buildCategoriesGrid(List<LearningCategory> categories,
      {bool isFeatured = false}) {
    if (categories.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return _buildCategoryCard(categories[index], isFeatured: isFeatured);
      },
    );
  }

  Widget _buildCategoryCard(LearningCategory category,
      {bool isFeatured = false}) {
    final color =
        Color(int.parse(category.colorCode.replaceFirst('#', '0xFF')));

    return Card(
      elevation: isFeatured ? 6 : 2,
      child: InkWell(
        onTap: () => _openCategoryDetail(category),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: isFeatured
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withValues(alpha: 0.1),
                      color.withValues(alpha: 0.05)
                    ],
                  )
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          AppAssets.getCategoryImage(category.name),
                          width: 40,
                          height: 40,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback to icon if image not found
                            return Icon(
                              _getIconData(category.iconName),
                              color: color,
                              size: 28,
                            );
                          },
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (isFeatured)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'FEATURED',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  category.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Row(
                  children: [
                    Icon(Icons.topic, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      '${category.topicCount} topics',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      category.averageRating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(category.difficulty)
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        category.difficulty.displayName,
                        style: TextStyle(
                          fontSize: 10,
                          color: _getDifficultyColor(category.difficulty),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressView(Map<String, dynamic> stats) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsCards(stats),
          const SizedBox(height: 24),
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          // TODO: Add recent activity list
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text('Recent activity coming soon!'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(Map<String, dynamic> stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          'Topics Completed',
          '${stats['completedTopics'] ?? 0}',
          Icons.check_circle,
          Colors.green,
        ),
        _buildStatCard(
          'In Progress',
          '${stats['inProgressTopics'] ?? 0}',
          Icons.play_circle,
          Colors.blue,
        ),
        _buildStatCard(
          'Time Spent',
          '${((stats['totalTimeMinutes'] ?? 0) / 60).round()}h',
          Icons.timer,
          Colors.orange,
        ),
        _buildStatCard(
          'Categories',
          '${stats['categoriesExplored'] ?? 0}',
          Icons.category,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No categories found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search terms',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error loading categories: $error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              ref.refresh(learningCategoriesProvider);
              ref.refresh(featuredCategoriesProvider);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  List<LearningCategory> _filterCategories(List<LearningCategory> categories) {
    if (_searchQuery.isEmpty) return categories;

    return categories.where((category) {
      return category.name.toLowerCase().contains(_searchQuery) ||
          category.description.toLowerCase().contains(_searchQuery) ||
          category.tags.any((tag) => tag.toLowerCase().contains(_searchQuery));
    }).toList();
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'code':
        return Icons.code;
      case 'analytics':
        return Icons.analytics;
      case 'palette':
        return Icons.palette;
      case 'business':
        return Icons.business;
      case 'language':
        return Icons.language;
      default:
        return Icons.category;
    }
  }

  Color _getDifficultyColor(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return Colors.green;
      case DifficultyLevel.intermediate:
        return Colors.orange;
      case DifficultyLevel.advanced:
        return Colors.red;
      case DifficultyLevel.expert:
        return Colors.purple;
    }
  }

  void _openCategoryDetail(LearningCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryDetailScreen(category: category),
      ),
    );
  }
}
