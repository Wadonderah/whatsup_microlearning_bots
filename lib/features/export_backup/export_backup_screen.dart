import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/export_backup_service.dart';
import '../auth/providers/auth_provider.dart';

// Available backups provider
final availableBackupsProvider =
    FutureProvider.family<List<BackupInfo>, String>((ref, userId) {
  return ExportBackupService.instance.getAvailableBackups(userId);
});

class ExportBackupScreen extends ConsumerStatefulWidget {
  const ExportBackupScreen({super.key});

  @override
  ConsumerState<ExportBackupScreen> createState() => _ExportBackupScreenState();
}

class _ExportBackupScreenState extends ConsumerState<ExportBackupScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    if (authState.user == null) {
      return const Scaffold(
        body: Center(
            child: Text('Please log in to access export and backup features')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Export & Backup'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Export'),
            Tab(text: 'Backup'),
            Tab(text: 'Sync'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExportTab(authState.user!.uid),
          _buildBackupTab(authState.user!.uid),
          _buildSyncTab(authState.user!.uid),
        ],
      ),
    );
  }

  Widget _buildExportTab(String userId) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Export Your Data',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Export your learning progress, conversations, and achievements to share or keep as a record.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          _buildExportOptions(userId),
          const SizedBox(height: 24),
          _buildExportInfo(),
        ],
      ),
    );
  }

  Widget _buildExportOptions(String userId) {
    return Column(
      children: [
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.file_download, color: Colors.blue),
                title: const Text('Export as JSON'),
                subtitle: const Text('Complete data export in JSON format'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _exportData(userId, ExportFormat.json),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.table_chart, color: Colors.green),
                title: const Text('Export as CSV'),
                subtitle: const Text('Simplified data export for spreadsheets'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _exportData(userId, ExportFormat.csv),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.share, color: Colors.orange),
                title: const Text('Share Export'),
                subtitle: const Text('Export and share via other apps'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _shareExport(userId),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExportInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.blue[600]),
                const SizedBox(width: 8),
                const Text(
                  'What\'s Included',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
                'User Profile', 'Your personal information and preferences'),
            _buildInfoItem(
                'Conversations', 'All your AI chat conversations and history'),
            _buildInfoItem('Study Plans', 'Your learning plans and progress'),
            _buildInfoItem(
                'Achievements', 'Unlocked achievements and XP points'),
            _buildInfoItem(
                'Learning Progress', 'Topic completion and statistics'),
            _buildInfoItem(
                'Social Data', 'Posts and social learning activities'),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupTab(String userId) {
    final backupsAsync = ref.watch(availableBackupsProvider(userId));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Backups',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : () => _createBackup(userId),
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.backup),
                label: const Text('Create Backup'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Create and manage local backups of your data.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          backupsAsync.when(
            data: (backups) => _buildBackupsList(backups),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => _buildErrorWidget(error),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupsList(List<BackupInfo> backups) {
    if (backups.isEmpty) {
      return _buildEmptyBackupsState();
    }

    return Column(
      children: backups.map((backup) => _buildBackupItem(backup)).toList(),
    );
  }

  Widget _buildBackupItem(BackupInfo backup) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.backup, color: Colors.blue),
        title: Text(backup.fileName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Created: ${backup.formattedDate}'),
            Text('Size: ${backup.formattedSize}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleBackupAction(value, backup),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'restore',
              child: Text('Restore'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyBackupsState() {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.backup_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No backups yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first backup to secure your data',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncTab(String userId) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Data Sync',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sync your data across multiple devices.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.cloud_sync,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Cloud Sync Coming Soon',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We\'re working on cloud sync functionality to keep your data synchronized across all your devices.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: null, // Disabled for now
                    child: const Text('Enable Sync'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildErrorWidget(Object error) {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: $error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final authState = ref.read(authProvider);
              if (authState.user != null) {
                final _ =
                    ref.refresh(availableBackupsProvider(authState.user!.uid));
              }
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(String userId, ExportFormat format) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final filePath = await ExportBackupService.instance
          .exportToFile(userId, format: format);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data exported successfully to $filePath'),
            action: SnackBarAction(
              label: 'Share',
              onPressed: () => _shareExport(userId),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _shareExport(String userId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ExportBackupService.instance.shareExportedData(userId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Share failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _createBackup(String userId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ExportBackupService.instance.createBackup(userId);

      // Refresh backups list
      final _ = ref.refresh(availableBackupsProvider(userId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleBackupAction(String action, BackupInfo backup) async {
    switch (action) {
      case 'restore':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Restore Backup'),
            content: Text(
              'This will restore your data from ${backup.formattedDate}. '
              'Current data may be overwritten. Continue?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Restore'),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          try {
            await ExportBackupService.instance
                .restoreFromBackup(backup.filePath);

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Backup restored successfully')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Restore failed: $e')),
              );
            }
          }
        }
        break;

      case 'delete':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Backup'),
            content: const Text('Are you sure you want to delete this backup?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          try {
            await ExportBackupService.instance.deleteBackup(backup.filePath);

            // Refresh backups list
            final authState = ref.read(authProvider);
            if (authState.user != null) {
              final _ =
                  ref.refresh(availableBackupsProvider(authState.user!.uid));
            }

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Backup deleted')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Delete failed: $e')),
              );
            }
          }
        }
        break;
    }
  }
}
