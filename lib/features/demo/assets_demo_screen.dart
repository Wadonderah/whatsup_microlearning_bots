import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';

/// Demo screen to showcase all the assets in the app
/// This screen demonstrates how to use images and animations throughout the app
class AssetsDemoScreen extends StatefulWidget {
  const AssetsDemoScreen({super.key});

  @override
  State<AssetsDemoScreen> createState() => _AssetsDemoScreenState();
}

class _AssetsDemoScreenState extends State<AssetsDemoScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assets Demo'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Splash'),
            Tab(text: 'Onboarding'),
            Tab(text: 'Categories'),
            Tab(text: 'Achievements'),
            Tab(text: 'Social'),
            Tab(text: 'Illustrations'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSplashDemo(),
          _buildOnboardingDemo(),
          _buildCategoriesDemo(),
          _buildAchievementsDemo(),
          _buildSocialDemo(),
          _buildIllustrationsDemo(),
        ],
      ),
    );
  }

  Widget _buildSplashDemo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Splash Screen Assets',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildAssetCard(
            'Animated Logo',
            AppAssets.logoAnimated,
            'Main app logo with animation for splash screen',
          ),
          _buildAssetCard(
            'Brain Animation',
            AppAssets.brainAnimation,
            'Learning brain animation for educational theme',
          ),
          _buildAssetCard(
            'Welcome Animation',
            AppAssets.welcomeAnimation,
            'Welcome animation for user onboarding',
          ),
          _buildAssetCard(
            'Loading Animation',
            AppAssets.loadingAnimation,
            'Loading spinner animation',
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingDemo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Onboarding Assets',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...AppAssets.onboardingImages.asMap().entries.map((entry) {
            final index = entry.key;
            final imagePath = entry.value;
            return _buildAssetCard(
              'Onboarding ${index + 1}',
              imagePath,
              'Onboarding illustration ${index + 1}',
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCategoriesDemo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Learning Categories',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: AppAssets.categoryImages.length,
            itemBuilder: (context, index) {
              final imagePath = AppAssets.categoryImages[index];
              final categoryName = _getCategoryNameFromPath(imagePath);
              return _buildCategoryCard(categoryName, imagePath);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsDemo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Achievement Badges',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.0,
            ),
            itemCount: AppAssets.achievementImages.length,
            itemBuilder: (context, index) {
              final imagePath = AppAssets.achievementImages[index];
              final achievementName = _getAchievementNameFromPath(imagePath);
              return _buildAchievementCard(achievementName, imagePath);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSocialDemo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Social Learning Assets',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildAssetCard(
            'Default Avatar',
            AppAssets.defaultAvatar,
            'Default user avatar for social profiles',
          ),
          _buildAssetCard(
            'Achievement Badge',
            AppAssets.achievementBadge,
            'Badge icon for social achievements',
          ),
          _buildAssetCard(
            'Streak Fire',
            AppAssets.streakFire,
            'Fire icon for learning streaks',
          ),
          _buildAssetCard(
            'Milestone Flag',
            AppAssets.milestoneFlag,
            'Flag icon for learning milestones',
          ),
        ],
      ),
    );
  }

  Widget _buildIllustrationsDemo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Illustrations & Animations',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildAssetCard(
            'Empty Study Plans',
            AppAssets.emptyStateStudyPlans,
            'Empty state for study plans screen',
          ),
          _buildAssetCard(
            'Empty Social Feed',
            AppAssets.emptyStateSocial,
            'Empty state for social feed',
          ),
          _buildAssetCard(
            'Offline Mode',
            AppAssets.offlineMode,
            'Illustration for offline mode',
          ),
          _buildAssetCard(
            'Export Data',
            AppAssets.exportData,
            'Illustration for data export feature',
          ),
          _buildAssetCard(
            'Success Animation',
            AppAssets.successCheckmark,
            'Success checkmark animation',
          ),
          _buildAssetCard(
            'Loading Dots',
            AppAssets.loadingDots,
            'Loading dots animation',
          ),
        ],
      ),
    );
  }

  Widget _buildAssetCard(String title, String assetPath, String description) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  assetPath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.image_not_supported,
                      color: Colors.grey[400],
                      size: 40,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    assetPath,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String categoryName, String imagePath) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.category,
                      color: Colors.blue,
                      size: 30,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              categoryName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementCard(String achievementName, String imagePath) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(35),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(35),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.emoji_events,
                      color: Colors.amber,
                      size: 35,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              achievementName,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryNameFromPath(String path) {
    final fileName = path.split('/').last.split('.').first;
    return fileName
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _getAchievementNameFromPath(String path) {
    final fileName = path.split('/').last.split('.').first;
    return fileName
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
