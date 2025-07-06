import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_assets.dart';

/// Asset Manager utility class for handling asset loading with fallbacks
class AssetManager {
  AssetManager._();

  static final Map<String, bool> _assetCache = {};

  /// Check if an asset exists
  static Future<bool> assetExists(String assetPath) async {
    if (_assetCache.containsKey(assetPath)) {
      return _assetCache[assetPath]!;
    }

    try {
      await rootBundle.load(assetPath);
      _assetCache[assetPath] = true;
      return true;
    } catch (e) {
      _assetCache[assetPath] = false;
      return false;
    }
  }

  /// Get a safe image widget with fallback
  static Widget getSafeImage({
    required String assetPath,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    Widget? fallback,
  }) {
    return FutureBuilder<bool>(
      future: assetExists(assetPath),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget(width, height);
        }

        if (snapshot.data == true) {
          return Image.asset(
            assetPath,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              return fallback ?? _buildFallbackWidget(width, height);
            },
          );
        }

        return fallback ?? _buildFallbackWidget(width, height);
      },
    );
  }

  /// Get splash screen image with fallback
  static Widget getSplashImage({
    double? width,
    double? height,
  }) {
    return getSafeImage(
      assetPath: AppAssets.brainAnimation,
      width: width,
      height: height,
      fallback: _buildBrainIcon(width, height),
    );
  }

  /// Get onboarding image with fallback
  static Widget getOnboardingImage({
    required int index,
    double? width,
    double? height,
  }) {
    return getSafeImage(
      assetPath: AppAssets.getOnboardingImage(index),
      width: width,
      height: height,
      fallback: _buildOnboardingFallback(index, width, height),
    );
  }

  /// Get category image with fallback
  static Widget getCategoryImage({
    required String categoryName,
    double? width,
    double? height,
  }) {
    return getSafeImage(
      assetPath: AppAssets.getCategoryImage(categoryName),
      width: width,
      height: height,
      fallback: _buildCategoryFallback(categoryName, width, height),
    );
  }

  /// Build loading widget
  static Widget _buildLoadingWidget(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  /// Build generic fallback widget
  static Widget _buildFallbackWidget(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.shade400,
            Colors.blue.shade400,
          ],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.image,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  /// Build brain icon fallback for splash
  static Widget _buildBrainIcon(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.shade400,
            Colors.blue.shade400,
          ],
        ),
        borderRadius: BorderRadius.circular(35),
      ),
      child: const Icon(
        Icons.psychology,
        color: Colors.white,
        size: 35,
      ),
    );
  }

  /// Build onboarding fallback
  static Widget _buildOnboardingFallback(int index, double? width, double? height) {
    final icons = [
      Icons.school,
      Icons.lightbulb,
      Icons.trending_up,
      Icons.celebration,
    ];

    final colors = [
      [Colors.blue.shade400, Colors.purple.shade400],
      [Colors.orange.shade400, Colors.red.shade400],
      [Colors.green.shade400, Colors.teal.shade400],
      [Colors.purple.shade400, Colors.pink.shade400],
    ];

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors[index % colors.length],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icons[index % icons.length],
        color: Colors.white,
        size: (width ?? 100) * 0.4,
      ),
    );
  }

  /// Build category fallback
  static Widget _buildCategoryFallback(String categoryName, double? width, double? height) {
    final categoryIcons = {
      'programming': Icons.code,
      'design': Icons.palette,
      'business': Icons.business,
      'science': Icons.science,
      'language': Icons.language,
      'mathematics': Icons.calculate,
      'history': Icons.history_edu,
      'art': Icons.brush,
    };

    final categoryColors = {
      'programming': [Colors.blue.shade600, Colors.indigo.shade600],
      'design': [Colors.purple.shade600, Colors.pink.shade600],
      'business': [Colors.green.shade600, Colors.teal.shade600],
      'science': [Colors.orange.shade600, Colors.red.shade600],
      'language': [Colors.cyan.shade600, Colors.blue.shade600],
      'mathematics': [Colors.indigo.shade600, Colors.purple.shade600],
      'history': [Colors.brown.shade600, Colors.orange.shade600],
      'art': [Colors.pink.shade600, Colors.red.shade600],
    };

    final icon = categoryIcons[categoryName.toLowerCase()] ?? Icons.category;
    final colors = categoryColors[categoryName.toLowerCase()] ?? 
                  [Colors.grey.shade600, Colors.blueGrey.shade600];

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: (width ?? 50) * 0.5,
      ),
    );
  }

  /// Clear asset cache
  static void clearCache() {
    _assetCache.clear();
  }

  /// Preload critical assets
  static Future<void> preloadCriticalAssets() async {
    final criticalAssets = [
      AppAssets.brainAnimation,
      AppAssets.logoAnimated,
      AppAssets.onboarding1,
      AppAssets.onboarding2,
      AppAssets.onboarding3,
      AppAssets.onboarding4,
    ];

    for (final asset in criticalAssets) {
      await assetExists(asset);
    }
  }
}
