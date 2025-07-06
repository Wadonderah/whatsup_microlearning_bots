import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/user_preferences_service.dart';
import '../../core/utils/asset_manager.dart';
import '../auth/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSplashSequence();
  }

  void _initializeAnimations() {
    // Logo animation controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Text animation controller
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Logo scale animation
    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    // Text slide animation
    _textAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutBack,
    ));

    // Fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    ));
  }

  void _startSplashSequence() async {
    // Preload critical assets in parallel with animations
    final preloadFuture = AssetManager.preloadCriticalAssets();

    // Start logo animation
    await _logoController.forward();

    // Start text animation after a short delay
    await Future.delayed(const Duration(milliseconds: 300));
    await _textController.forward();

    // Wait for assets to preload and show complete splash
    await Future.wait([
      preloadFuture,
      Future.delayed(const Duration(milliseconds: 1200)),
    ]);

    // Navigate to appropriate screen
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    try {
      // Check auth state first
      final authState = ref.read(authProvider);

      // If there's an auth error, show error and stay on splash
      if (authState.hasError) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Initialization error: ${authState.error}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      // If auth is still loading, wait a bit more
      if (authState.isLoading) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          _navigateToNextScreen(); // Retry
        }
        return;
      }

      final userPrefs = await UserPreferencesService.getInstance();
      final isFirstTime = await userPrefs.isFirstTimeUser();
      final hasCompletedOnboarding = await userPrefs.hasCompletedOnboarding();

      if (mounted) {
        if (isFirstTime || !hasCompletedOnboarding) {
          // Navigate to onboarding
          context.go('/onboarding');
        } else if (authState.isAuthenticated) {
          // User is already authenticated, go to home
          context.go('/home');
        } else {
          // Navigate to login screen
          context.go('/login');
        }
      }
    } catch (e) {
      // Fallback navigation in case of error
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Logo
              AnimatedBuilder(
                animation: _logoAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoAnimation.value,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(35),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(35),
                        child: AssetManager.getSplashImage(
                          width: 100,
                          height: 100,
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              // Animated Text
              AnimatedBuilder(
                animation: _textAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _textAnimation.value),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          Text(
                            'WhatsApp',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'MicroLearning Bot',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white.withValues(alpha: 0.9),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 50),

              // Loading indicator
              FadeTransition(
                opacity: _fadeAnimation,
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
