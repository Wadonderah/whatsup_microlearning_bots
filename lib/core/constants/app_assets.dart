/// App Assets Constants
/// 
/// This class contains all the asset paths used throughout the application.
/// It provides a centralized way to manage and reference image assets.
class AppAssets {
  AppAssets._(); // Private constructor to prevent instantiation

  // Base paths
  static const String _imagesPath = 'assets/images';
  static const String _splashPath = '$_imagesPath/splash';
  static const String _onboardingPath = '$_imagesPath/onboarding';
  static const String _categoriesPath = '$_imagesPath/categories';
  static const String _achievementsPath = '$_imagesPath/achievements';
  static const String _socialPath = '$_imagesPath/social';
  static const String _illustrationsPath = '$_imagesPath/illustrations';
  static const String _iconsPath = '$_imagesPath/icons';
  static const String _animationsPath = '$_imagesPath/animations';

  // Splash Screen Assets
  static const String logoAnimated = '$_splashPath/logo_animated.gif';
  static const String loadingAnimation = '$_splashPath/loading_animation.gif';
  static const String brainAnimation = '$_splashPath/brain_animation.gif';
  static const String welcomeAnimation = '$_splashPath/welcome_animation.gif';

  // Onboarding Assets
  static const String onboarding1 = '$_onboardingPath/onboarding_1.png';
  static const String onboarding2 = '$_onboardingPath/onboarding_2.png';
  static const String onboarding3 = '$_onboardingPath/onboarding_3.png';
  static const String onboarding4 = '$_onboardingPath/onboarding_4.png';

  // Category Assets
  static const String categoryProgramming = '$_categoriesPath/programming.png';
  static const String categoryDesign = '$_categoriesPath/design.png';
  static const String categoryBusiness = '$_categoriesPath/business.png';
  static const String categoryScience = '$_categoriesPath/science.png';
  static const String categoryLanguage = '$_categoriesPath/language.png';
  static const String categoryMathematics = '$_categoriesPath/mathematics.png';
  static const String categoryHistory = '$_categoriesPath/history.png';
  static const String categoryArt = '$_categoriesPath/art.png';

  // Achievement Assets
  static const String achievementFirstLesson = '$_achievementsPath/first_lesson.png';
  static const String achievementStreak7 = '$_achievementsPath/streak_7.png';
  static const String achievementStreak30 = '$_achievementsPath/streak_30.png';
  static const String achievementLevelUp = '$_achievementsPath/level_up.png';
  static const String achievementTopicMaster = '$_achievementsPath/topic_master.png';
  static const String achievementSocialLearner = '$_achievementsPath/social_learner.png';

  // Social Assets
  static const String defaultAvatar = '$_socialPath/default_avatar.png';
  static const String achievementBadge = '$_socialPath/achievement_badge.png';
  static const String streakFire = '$_socialPath/streak_fire.png';
  static const String milestoneFlag = '$_socialPath/milestone_flag.png';

  // Illustration Assets
  static const String emptyStateStudyPlans = '$_illustrationsPath/empty_state_study_plans.png';
  static const String emptyStateSocial = '$_illustrationsPath/empty_state_social.png';
  static const String emptyStateCategories = '$_illustrationsPath/empty_state_categories.png';
  static const String offlineMode = '$_illustrationsPath/offline_mode.png';
  static const String exportData = '$_illustrationsPath/export_data.png';
  static const String backupSuccess = '$_illustrationsPath/backup_success.png';

  // Icon Assets
  static const String appIcon = '$_iconsPath/app_icon.png';
  static const String notificationIcon = '$_iconsPath/notification_icon.png';
  static const String widgetIcon = '$_iconsPath/widget_icon.png';

  // Animation Assets
  static const String loadingDots = '$_animationsPath/loading_dots.gif';
  static const String successCheckmark = '$_animationsPath/success_checkmark.gif';
  static const String errorAnimation = '$_animationsPath/error_animation.gif';
  static const String progressAnimation = '$_animationsPath/progress_animation.gif';

  // Helper methods to get category images by name
  static String getCategoryImage(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'programming':
        return categoryProgramming;
      case 'design':
        return categoryDesign;
      case 'business':
        return categoryBusiness;
      case 'science':
        return categoryScience;
      case 'language':
        return categoryLanguage;
      case 'mathematics':
        return categoryMathematics;
      case 'history':
        return categoryHistory;
      case 'art':
        return categoryArt;
      default:
        return categoryProgramming; // Default fallback
    }
  }

  // Helper method to get achievement images by type
  static String getAchievementImage(String achievementType) {
    switch (achievementType.toLowerCase()) {
      case 'first_lesson':
        return achievementFirstLesson;
      case 'streak_7':
        return achievementStreak7;
      case 'streak_30':
        return achievementStreak30;
      case 'level_up':
        return achievementLevelUp;
      case 'topic_master':
        return achievementTopicMaster;
      case 'social_learner':
        return achievementSocialLearner;
      default:
        return achievementFirstLesson; // Default fallback
    }
  }

  // Helper method to get onboarding images by index
  static String getOnboardingImage(int index) {
    switch (index) {
      case 0:
        return onboarding1;
      case 1:
        return onboarding2;
      case 2:
        return onboarding3;
      case 3:
        return onboarding4;
      default:
        return onboarding1; // Default fallback
    }
  }

  // List of all splash animations for random selection
  static const List<String> splashAnimations = [
    logoAnimated,
    brainAnimation,
    welcomeAnimation,
  ];

  // List of all loading animations
  static const List<String> loadingAnimations = [
    loadingAnimation,
    loadingDots,
    progressAnimation,
  ];

  // List of all category images
  static const List<String> categoryImages = [
    categoryProgramming,
    categoryDesign,
    categoryBusiness,
    categoryScience,
    categoryLanguage,
    categoryMathematics,
    categoryHistory,
    categoryArt,
  ];

  // List of all achievement images
  static const List<String> achievementImages = [
    achievementFirstLesson,
    achievementStreak7,
    achievementStreak30,
    achievementLevelUp,
    achievementTopicMaster,
    achievementSocialLearner,
  ];

  // List of all onboarding images
  static const List<String> onboardingImages = [
    onboarding1,
    onboarding2,
    onboarding3,
    onboarding4,
  ];

  // List of all illustration images
  static const List<String> illustrationImages = [
    emptyStateStudyPlans,
    emptyStateSocial,
    emptyStateCategories,
    offlineMode,
    exportData,
    backupSuccess,
  ];

  // Validation method to check if asset exists
  static bool isValidAsset(String assetPath) {
    return assetPath.isNotEmpty && assetPath.startsWith('assets/');
  }

  // Method to get fallback image for any category
  static String getFallbackImage(String category) {
    switch (category.toLowerCase()) {
      case 'splash':
        return logoAnimated;
      case 'onboarding':
        return onboarding1;
      case 'category':
        return categoryProgramming;
      case 'achievement':
        return achievementFirstLesson;
      case 'social':
        return defaultAvatar;
      case 'illustration':
        return emptyStateCategories;
      case 'icon':
        return appIcon;
      case 'animation':
        return loadingAnimation;
      default:
        return appIcon;
    }
  }
}
