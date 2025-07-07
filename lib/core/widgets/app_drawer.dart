import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../config/development_config.dart';
import '../providers/theme_provider.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Drawer(
      child: Column(
        children: [
          // Header
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF4CAF50), // Green
                  Color(0xFF2196F3), // Blue
                ],
              ),
            ),
            accountName: Text(
              user?.displayName ?? 'Learning User',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            accountEmail: Text(
              user?.email ?? 'demo@microlearning.com',
              style: const TextStyle(fontSize: 14),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: user?.photoURL != null
                  ? ClipOval(
                      child: Image.network(
                        user!.photoURL!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.green,
                          );
                        },
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.green,
                    ),
            ),
            otherAccountsPictures: [
              if (DevelopmentConfig.isDevelopmentMode)
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.developer_mode,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
            ],
          ),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.home,
                  title: 'Home',
                  subtitle: 'Main dashboard',
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/home');
                  },
                  isSelected: _isCurrentRoute(context, '/home'),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.dashboard,
                  title: 'Learning Dashboard',
                  subtitle: 'Progress & analytics',
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/dashboard');
                  },
                  isSelected: _isCurrentRoute(context, '/dashboard'),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.quiz,
                  title: 'Take Quiz',
                  subtitle: 'Test your knowledge',
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/quiz');
                  },
                  isSelected: _isCurrentRoute(context, '/quiz'),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.psychology,
                  title: 'AI Assistant',
                  subtitle: 'Chat with AI tutor',
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/ai-assistant');
                  },
                  isSelected: _isCurrentRoute(context, '/ai-assistant'),
                ),

                const Divider(),

                _buildDrawerItem(
                  context,
                  icon: Icons.notifications,
                  title: 'Notifications',
                  subtitle: 'Learning reminders',
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/notifications');
                  },
                  isSelected: _isCurrentRoute(context, '/notifications'),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.settings,
                  title: 'Settings',
                  subtitle: 'App preferences',
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/theme-settings');
                  },
                  isSelected: _isCurrentRoute(context, '/theme-settings'),
                ),

                // Theme Toggle
                _buildThemeToggleItem(context, ref),

                const Divider(),

                // Quick Stats Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Stats',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      _buildStatRow(
                        context,
                        icon: Icons.school,
                        label: 'Categories',
                        value: '7',
                        color: Colors.blue,
                      ),
                      _buildStatRow(
                        context,
                        icon: Icons.quiz,
                        label: 'Questions',
                        value: '44',
                        color: Colors.green,
                      ),
                      _buildStatRow(
                        context,
                        icon: Icons.trending_up,
                        label: 'Progress',
                        value: '0%',
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Column(
              children: [
                if (DevelopmentConfig.isDevelopmentMode)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.developer_mode,
                          size: 16,
                          color: Colors.orange[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Development Mode',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          Navigator.pop(context);
                          await ref.read(authProvider.notifier).signOut();
                          if (context.mounted) {
                            context.go('/login');
                          }
                        },
                        icon: const Icon(Icons.logout, size: 18),
                        label: const Text('Sign Out'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isSelected ? Colors.blue.withValues(alpha: 0.1) : null,
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : Colors.grey[600],
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.blue : null,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeToggleItem(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final isDarkMode = themeState.isDarkMode;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (isDarkMode ? Colors.amber : Colors.orange)
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isDarkMode ? Icons.dark_mode : Icons.light_mode,
            color: isDarkMode ? Colors.amber : Colors.orange,
            size: 20,
          ),
        ),
        title: Text(
          'Theme',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        subtitle: Text(
          isDarkMode ? 'Dark Mode' : 'Light Mode',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Switch(
          value: isDarkMode,
          onChanged: (value) {
            ref.read(themeProvider.notifier).toggleTheme();
          },
          activeColor: Colors.amber,
        ),
        onTap: () {
          ref.read(themeProvider.notifier).toggleTheme();
        },
      ),
    );
  }

  bool _isCurrentRoute(BuildContext context, String route) {
    final currentLocation = GoRouterState.of(context).uri.toString();
    return currentLocation == route;
  }
}
