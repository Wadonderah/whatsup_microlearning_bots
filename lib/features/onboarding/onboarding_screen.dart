import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_assets.dart';
import '../../core/services/user_preferences_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to WhatsApp MicroLearning',
      description:
          'Learn new skills through bite-sized lessons delivered right to your WhatsApp.',
      icon: Icons.school,
      color: Colors.blue,
      imagePath: AppAssets.onboarding1,
    ),
    OnboardingPage(
      title: 'AI-Powered Learning',
      description:
          'Get personalized learning experiences powered by advanced AI technology.',
      icon: Icons.psychology,
      color: Colors.purple,
      imagePath: AppAssets.onboarding2,
    ),
    OnboardingPage(
      title: 'Learn Anytime, Anywhere',
      description:
          'Access your lessons whenever you want, directly through WhatsApp messaging.',
      icon: Icons.access_time,
      color: Colors.green,
      imagePath: AppAssets.onboarding3,
    ),
    OnboardingPage(
      title: 'Track Your Progress',
      description:
          'Monitor your learning journey with detailed progress tracking and achievements.',
      icon: Icons.trending_up,
      color: Colors.orange,
      imagePath: AppAssets.onboarding4,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() async {
    final userPrefs = await UserPreferencesService.getInstance();
    await userPrefs.setOnboardingCompleted();
    await userPrefs.setFirstTimeUserComplete();

    if (mounted) {
      context.go('/login');
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: _skipOnboarding,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildOnboardingPage(_pages[index]);
                },
              ),
            ),

            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => _buildPageIndicator(index),
              ),
            ),

            const SizedBox(height: 30),

            // Next/Get Started button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _pages[_currentPage].color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: page.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: page.imagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      page.imagePath!,
                      width: 180,
                      height: 180,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to icon if image not found
                        return Icon(
                          page.icon,
                          size: 100,
                          color: page.color,
                        );
                      },
                    ),
                  )
                : Icon(
                    page.icon,
                    size: 100,
                    color: page.color,
                  ),
          ),
          const SizedBox(height: 40),
          Text(
            page.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            page.description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 12 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? _pages[_currentPage].color
            : Colors.grey.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String? imagePath;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.imagePath,
  });
}
