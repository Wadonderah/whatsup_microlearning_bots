import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/offline_service.dart';

// Connectivity provider
final connectivityProvider = StreamProvider<bool>((ref) {
  return OfflineService.instance.connectivityStream;
});

// Cache stats provider
final cacheStatsProvider = FutureProvider<Map<String, dynamic>>((ref) {
  return OfflineService.instance.getCacheStats();
});

class OfflineModeWidget extends ConsumerWidget {
  final Widget child;
  final bool showOfflineBanner;

  const OfflineModeWidget({
    super.key,
    required this.child,
    this.showOfflineBanner = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityAsync = ref.watch(connectivityProvider);

    return connectivityAsync.when(
      data: (isOnline) => Column(
        children: [
          if (!isOnline && showOfflineBanner) _buildOfflineBanner(context),
          Expanded(child: child),
        ],
      ),
      loading: () => child,
      error: (_, __) => child,
    );
  }

  Widget _buildOfflineBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.orange[100],
      child: Row(
        children: [
          Icon(
            Icons.cloud_off,
            color: Colors.orange[800],
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'You\'re offline. Using cached content.',
              style: TextStyle(
                color: Colors.orange[800],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () => _showOfflineDialog(context),
            child: Text(
              'Learn More',
              style: TextStyle(
                color: Colors.orange[800],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOfflineDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const OfflineModeDialog(),
    );
  }
}

class OfflineModeDialog extends ConsumerWidget {
  const OfflineModeDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cacheStatsAsync = ref.watch(cacheStatsProvider);

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.cloud_off, color: Colors.orange),
          SizedBox(width: 8),
          Text('Offline Mode'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'You\'re currently offline, but you can still:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            _buildFeatureItem(
              Icons.chat,
              'View cached conversations',
              'Access your recent chat history',
            ),
            _buildFeatureItem(
              Icons.school,
              'Browse learning content',
              'Explore cached categories and topics',
            ),
            _buildFeatureItem(
              Icons.assignment,
              'Review study plans',
              'Check your cached study plans and progress',
            ),
            _buildFeatureItem(
              Icons.settings,
              'Adjust settings',
              'Modify app preferences',
            ),
            const SizedBox(height: 16),
            const Text(
              'Cache Status:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            cacheStatsAsync.when(
              data: (stats) => _buildCacheStats(stats),
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Text('Error loading cache stats'),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue[600], size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'New AI conversations require an internet connection.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
        TextButton(
          onPressed: () => _showCacheManagement(context),
          child: const Text('Manage Cache'),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCacheStats(Map<String, dynamic> stats) {
    return Column(
      children: [
        _buildStatRow('Conversations', '${stats['conversations'] ?? 0}'),
        _buildStatRow('Categories', '${stats['categories'] ?? 0}'),
        _buildStatRow('Topics', '${stats['topics'] ?? 0}'),
        _buildStatRow('Study Plans', '${stats['studyPlans'] ?? 0}'),
        _buildStatRow('Progress Entries', '${stats['progress'] ?? 0}'),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showCacheManagement(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CacheManagementScreen(),
      ),
    );
  }
}

class CacheManagementScreen extends ConsumerStatefulWidget {
  const CacheManagementScreen({super.key});

  @override
  ConsumerState<CacheManagementScreen> createState() =>
      _CacheManagementScreenState();
}

class _CacheManagementScreenState extends ConsumerState<CacheManagementScreen> {
  bool _isClearing = false;

  @override
  Widget build(BuildContext context) {
    final cacheStatsAsync = ref.watch(cacheStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cache Management'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cached Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            cacheStatsAsync.when(
              data: (stats) => _buildCacheDetails(stats),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text('Error: $error'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Cache Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildCacheDetails(Map<String, dynamic> stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDetailRow(
                'Conversations', '${stats['conversations'] ?? 0}', Icons.chat),
            _buildDetailRow(
                'Categories', '${stats['categories'] ?? 0}', Icons.category),
            _buildDetailRow('Topics', '${stats['topics'] ?? 0}', Icons.topic),
            _buildDetailRow(
                'Study Plans', '${stats['studyPlans'] ?? 0}', Icons.assignment),
            _buildDetailRow(
                'Progress', '${stats['progress'] ?? 0}', Icons.trending_up),
            _buildDetailRow(
                'Settings', '${stats['settings'] ?? 0}', Icons.settings),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Connection Status',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Row(
                  children: [
                    Icon(
                      stats['isOnline'] == true ? Icons.cloud : Icons.cloud_off,
                      color: stats['isOnline'] == true
                          ? Colors.green
                          : Colors.orange,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      stats['isOnline'] == true ? 'Online' : 'Offline',
                      style: TextStyle(
                        color: stats['isOnline'] == true
                            ? Colors.green
                            : Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Card(
          child: Column(
            children: [
              ListTile(
                leading:
                    const Icon(Icons.cleaning_services, color: Colors.orange),
                title: const Text('Clear Expired Cache'),
                subtitle: const Text('Remove outdated cached data'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _isClearing ? null : _clearExpiredCache,
              ),
              ListTile(
                leading: const Icon(Icons.delete_sweep, color: Colors.red),
                title: const Text('Clear All Cache'),
                subtitle: const Text('Remove all cached data'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _isClearing ? null : _showClearAllDialog,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_isClearing)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text('Clearing cache...'),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _clearExpiredCache() async {
    setState(() {
      _isClearing = true;
    });

    try {
      await OfflineService.instance.clearExpiredCache();
      final _ = ref.refresh(cacheStatsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expired cache cleared')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error clearing cache: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isClearing = false;
        });
      }
    }
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Cache'),
        content: const Text(
          'This will remove all cached data including conversations, learning content, and progress. '
          'You\'ll need an internet connection to reload this data.\n\n'
          'Are you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearAllCache();
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllCache() async {
    setState(() {
      _isClearing = true;
    });

    try {
      await OfflineService.instance.clearAllCache();
      final _ = ref.refresh(cacheStatsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All cache cleared')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error clearing cache: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isClearing = false;
        });
      }
    }
  }
}
