import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_themes.dart';

// Theme mode enum
enum AppThemeMode {
  light,
  dark,
  system,
}

// Theme state class
class ThemeState {
  final AppThemeMode themeMode;
  final bool isDarkMode;

  const ThemeState({
    required this.themeMode,
    required this.isDarkMode,
  });

  ThemeState copyWith({
    AppThemeMode? themeMode,
    bool? isDarkMode,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

// Theme provider
class ThemeNotifier extends StateNotifier<ThemeState> {
  static const String _themeKey = 'app_theme_mode';
  
  ThemeNotifier() : super(const ThemeState(
    themeMode: AppThemeMode.system,
    isDarkMode: false,
  )) {
    _loadTheme();
  }

  // Load saved theme from preferences
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themeKey);
      
      if (savedTheme != null) {
        final themeMode = AppThemeMode.values.firstWhere(
          (mode) => mode.name == savedTheme,
          orElse: () => AppThemeMode.system,
        );
        
        final isDark = _calculateIsDarkMode(themeMode);
        
        state = ThemeState(
          themeMode: themeMode,
          isDarkMode: isDark,
        );
      } else {
        // First time - use system theme
        final isDark = _calculateIsDarkMode(AppThemeMode.system);
        state = ThemeState(
          themeMode: AppThemeMode.system,
          isDarkMode: isDark,
        );
      }
    } catch (e) {
      // If there's an error, use default light theme
      state = const ThemeState(
        themeMode: AppThemeMode.light,
        isDarkMode: false,
      );
    }
  }

  // Save theme to preferences
  Future<void> _saveTheme(AppThemeMode themeMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, themeMode.name);
    } catch (e) {
      // Handle error silently
    }
  }

  // Calculate if dark mode should be active
  bool _calculateIsDarkMode(AppThemeMode themeMode) {
    switch (themeMode) {
      case AppThemeMode.light:
        return false;
      case AppThemeMode.dark:
        return true;
      case AppThemeMode.system:
        // Get system brightness
        final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
        return brightness == Brightness.dark;
    }
  }

  // Set theme mode
  Future<void> setThemeMode(AppThemeMode themeMode) async {
    final isDark = _calculateIsDarkMode(themeMode);
    
    state = ThemeState(
      themeMode: themeMode,
      isDarkMode: isDark,
    );
    
    await _saveTheme(themeMode);
  }

  // Toggle between light and dark (ignores system)
  Future<void> toggleTheme() async {
    final newMode = state.isDarkMode ? AppThemeMode.light : AppThemeMode.dark;
    await setThemeMode(newMode);
  }

  // Update system theme when system brightness changes
  void updateSystemTheme() {
    if (state.themeMode == AppThemeMode.system) {
      final isDark = _calculateIsDarkMode(AppThemeMode.system);
      if (isDark != state.isDarkMode) {
        state = state.copyWith(isDarkMode: isDark);
      }
    }
  }
}

// Provider instance
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});

// Helper providers
final isDarkModeProvider = Provider<bool>((ref) {
  return ref.watch(themeProvider).isDarkMode;
});

final currentThemeModeProvider = Provider<AppThemeMode>((ref) {
  return ref.watch(themeProvider).themeMode;
});
