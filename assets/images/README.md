# Assets Directory

This directory contains all the image assets for the WhatsApp MicroLearning Bot application.

## Directory Structure

```
assets/
├── images/
│   ├── splash/
│   │   ├── logo_animated.gif
│   │   ├── loading_animation.gif
│   │   ├── brain_animation.gif
│   │   └── welcome_animation.gif
│   ├── onboarding/
│   │   ├── onboarding_1.png
│   │   ├── onboarding_2.png
│   │   ├── onboarding_3.png
│   │   └── onboarding_4.png
│   ├── categories/
│   │   ├── programming.png
│   │   ├── design.png
│   │   ├── business.png
│   │   ├── science.png
│   │   ├── language.png
│   │   ├── mathematics.png
│   │   ├── history.png
│   │   └── art.png
│   ├── achievements/
│   │   ├── first_lesson.png
│   │   ├── streak_7.png
│   │   ├── streak_30.png
│   │   ├── level_up.png
│   │   ├── topic_master.png
│   │   └── social_learner.png
│   ├── social/
│   │   ├── default_avatar.png
│   │   ├── achievement_badge.png
│   │   ├── streak_fire.png
│   │   └── milestone_flag.png
│   ├── illustrations/
│   │   ├── empty_state_study_plans.png
│   │   ├── empty_state_social.png
│   │   ├── empty_state_categories.png
│   │   ├── offline_mode.png
│   │   ├── export_data.png
│   │   └── backup_success.png
│   ├── icons/
│   │   ├── app_icon.png
│   │   ├── notification_icon.png
│   │   └── widget_icon.png
│   └── animations/
│       ├── loading_dots.gif
│       ├── success_checkmark.gif
│       ├── error_animation.gif
│       └── progress_animation.gif
```

## Image Guidelines

### Splash Screen Images
- **logo_animated.gif**: Main app logo with animation
- **loading_animation.gif**: Loading spinner/animation
- **brain_animation.gif**: Brain learning animation
- **welcome_animation.gif**: Welcome screen animation

### Onboarding Images
- High-quality illustrations showing app features
- Consistent style and color scheme
- Optimized for different screen sizes

### Category Images
- Representative icons for each learning category
- Consistent size and style
- Clear and recognizable symbols

### Achievement Images
- Celebratory and motivating designs
- Different levels of achievements
- Consistent badge/medal style

### Social Images
- Default avatars and social elements
- Achievement badges for social sharing
- Streak and milestone indicators

### Illustration Images
- Empty state illustrations
- Feature explanation graphics
- Error and success states

### Animation Files
- GIF format for compatibility
- Optimized file sizes
- Smooth animations

## Usage in Code

Images are referenced in the pubspec.yaml file and used throughout the app:

```dart
// Example usage
Image.asset('assets/images/splash/logo_animated.gif')
Image.asset('assets/images/categories/programming.png')
Image.asset('assets/images/achievements/streak_7.png')
```

## Optimization

All images are optimized for:
- Multiple screen densities (1x, 2x, 3x)
- Appropriate file sizes
- Fast loading times
- Consistent quality across devices
