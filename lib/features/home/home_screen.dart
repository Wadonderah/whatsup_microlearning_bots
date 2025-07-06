import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('WhatsApp MicroLearning Bot'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => context.go('/notifications'),
            tooltip: 'Notifications',
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                await ref.read(authProvider.notifier).signOut();
                if (context.mounted) {
                  context.go('/login');
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout, color: Colors.red),
                    const SizedBox(width: 8),
                    Text('Logout', style: TextStyle(color: Colors.red[700])),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.chat_bubble_outline,
              size: 100,
              color: Colors.green,
            ),
            const SizedBox(height: 20),
            Text(
              user != null
                  ? 'Welcome back, ${user.displayNameOrEmail}!'
                  : 'Welcome to the Main App!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Your WhatsApp MicroLearning Bot is ready.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => context.go('/ai-assistant'),
              icon: const Icon(Icons.psychology),
              label: const Text('AI Learning Assistant'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.go('/notification-settings'),
              icon: const Icon(Icons.notifications_active),
              label: const Text('Notification Settings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
