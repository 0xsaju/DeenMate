import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/offline_content_service.dart';
import '../state/providers.dart';
import '../../../../core/theme/theme_helper.dart';

class OfflineManagementScreen extends ConsumerStatefulWidget {
  const OfflineManagementScreen({super.key});

  @override
  ConsumerState<OfflineManagementScreen> createState() => _OfflineManagementScreenState();
}

class _OfflineManagementScreenState extends ConsumerState<OfflineManagementScreen> {
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String _downloadStatus = '';

  @override
  Widget build(BuildContext context) {
    final offlineStatus = ref.watch(offlineContentStatusProvider);
    final storageStats = ref.watch(offlineStorageStatsProvider);

    return Scaffold(
      backgroundColor: ThemeHelper.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: ThemeHelper.getBackgroundColor(context),
        elevation: 0,
        title: Text(
          'Offline Downloads',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: ThemeHelper.getTextPrimaryColor(context),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ThemeHelper.getTextPrimaryColor(context)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status Overview Card
          _buildStatusCard(offlineStatus, storageStats),
          const SizedBox(height: 20),

          // Quick Actions
          _buildQuickActions(),
          const SizedBox(height: 20),

          // Translation Downloads
          _buildTranslationSection(),
          const SizedBox(height: 20),

          // Chapter Downloads
          _buildChapterSection(),
          const SizedBox(height: 20),

          // Storage Management
          _buildStorageSection(storageStats),
        ],
      ),
    );
  }

  Widget _buildStatusCard(AsyncValue<OfflineContentStatus> statusAsync, AsyncValue<OfflineStorageStats> statsAsync) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeHelper.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeHelper.getDividerColor(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ThemeHelper.getPrimaryColor(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.cloud_download,
                  color: ThemeHelper.getPrimaryColor(context),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Offline Content Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ThemeHelper.getTextPrimaryColor(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    statusAsync.when(
                      data: (status) => Text(
                        status.isFullyOffline 
                          ? 'Fully Available Offline'
                          : status.hasEssentialContent
                            ? 'Essential Content Available'
                            : 'Limited Offline Content',
                        style: TextStyle(
                          fontSize: 12,
                          color: status.isFullyOffline 
                            ? Colors.green 
                            : status.hasEssentialContent
                              ? Colors.orange
                              : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      loading: () => Text(
                        'Checking status...',
                        style: TextStyle(
                          fontSize: 12,
                          color: ThemeHelper.getTextSecondaryColor(context),
                        ),
                      ),
                      error: (_, __) => Text(
                        'Error checking status',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (!_isDownloading) ...[
            const SizedBox(height: 16),
            // Progress indicators
            statusAsync.when(
              data: (status) => Column(
                children: [
                  _buildProgressRow(
                    'Coverage',
                    status.estimatedCoverage,
                    '${(status.estimatedCoverage * 100).toStringAsFixed(1)}%',
                  ),
                  const SizedBox(height: 8),
                  _buildProgressRow(
                    'Translations',
                    status.downloadedTranslations.length / 10.0, // Assume 10 is good coverage
                    '${status.downloadedTranslations.length} downloaded',
                  ),
                ],
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],

          if (_isDownloading) ...[
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _downloadStatus,
                  style: TextStyle(
                    fontSize: 12,
                    color: ThemeHelper.getTextSecondaryColor(context),
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _downloadProgress,
                  backgroundColor: ThemeHelper.getDividerColor(context),
                  valueColor: AlwaysStoppedAnimation<Color>(ThemeHelper.getPrimaryColor(context)),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(_downloadProgress * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 10,
                    color: ThemeHelper.getTextSecondaryColor(context),
                  ),
                ),
              ],
            ),
          ],

          // Storage info
          const SizedBox(height: 16),
          statsAsync.when(
            data: (stats) => Row(
              children: [
                Icon(
                  Icons.storage,
                  size: 16,
                  color: ThemeHelper.getTextSecondaryColor(context),
                ),
                const SizedBox(width: 8),
                Text(
                  'Storage: ${stats.estimatedSizeMB.toStringAsFixed(1)} MB • ${stats.versesCount} verses cached',
                  style: TextStyle(
                    fontSize: 12,
                    color: ThemeHelper.getTextSecondaryColor(context),
                  ),
                ),
              ],
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRow(String label, double progress, String value) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: ThemeHelper.getTextSecondaryColor(context),
            ),
          ),
        ),
        Expanded(
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: ThemeHelper.getDividerColor(context),
            valueColor: AlwaysStoppedAnimation<Color>(ThemeHelper.getPrimaryColor(context)),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 60,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 11,
              color: ThemeHelper.getTextSecondaryColor(context),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ThemeHelper.getTextPrimaryColor(context),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Download Essential',
                Icons.download,
                'Download most commonly read chapters',
                _isDownloading ? null : _downloadEssentialContent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Clear Cache',
                Icons.delete_outline,
                'Free up storage space',
                _isDownloading ? null : _showClearCacheDialog,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String title, IconData icon, String subtitle, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ThemeHelper.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ThemeHelper.getDividerColor(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: onTap != null ? ThemeHelper.getPrimaryColor(context) : ThemeHelper.getTextSecondaryColor(context),
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: onTap != null ? ThemeHelper.getTextPrimaryColor(context) : ThemeHelper.getTextSecondaryColor(context),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: ThemeHelper.getTextSecondaryColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTranslationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Translation Downloads',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ThemeHelper.getTextPrimaryColor(context),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Download complete translations for offline reading',
          style: TextStyle(
            fontSize: 12,
            color: ThemeHelper.getTextSecondaryColor(context),
          ),
        ),
        const SizedBox(height: 12),
        // Translation list will be populated from available translations
        _buildPlaceholderCard('Translation management coming soon...'),
      ],
    );
  }

  Widget _buildChapterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chapter Downloads',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ThemeHelper.getTextPrimaryColor(context),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Download specific chapters for offline reading',
          style: TextStyle(
            fontSize: 12,
            color: ThemeHelper.getTextSecondaryColor(context),
          ),
        ),
        const SizedBox(height: 12),
        _buildPlaceholderCard('Individual chapter downloads coming soon...'),
      ],
    );
  }

  Widget _buildStorageSection(AsyncValue<OfflineStorageStats> statsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Storage Management',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ThemeHelper.getTextPrimaryColor(context),
          ),
        ),
        const SizedBox(height: 12),
        statsAsync.when(
          data: (stats) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ThemeHelper.getSurfaceColor(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ThemeHelper.getDividerColor(context)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cached Chapters',
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeHelper.getTextPrimaryColor(context),
                      ),
                    ),
                    Text(
                      '${stats.chaptersCount}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ThemeHelper.getTextPrimaryColor(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cached Verses',
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeHelper.getTextPrimaryColor(context),
                      ),
                    ),
                    Text(
                      '${stats.versesCount}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ThemeHelper.getTextPrimaryColor(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Storage Used',
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeHelper.getTextPrimaryColor(context),
                      ),
                    ),
                    Text(
                      '${stats.estimatedSizeMB.toStringAsFixed(1)} MB',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ThemeHelper.getTextPrimaryColor(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => _buildPlaceholderCard('Error loading storage info'),
        ),
      ],
    );
  }

  Widget _buildPlaceholderCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeHelper.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeHelper.getDividerColor(context)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: ThemeHelper.getTextSecondaryColor(context),
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Future<void> _downloadEssentialContent() async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _downloadStatus = 'Preparing download...';
    });

    try {
      final service = ref.read(offlineContentServiceProvider);
      await service.preloadEssentialContent(
        onProgress: (progress, status) {
          if (mounted) {
            setState(() {
              _downloadProgress = progress;
              _downloadStatus = status;
            });
          }
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Essential content downloaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Refresh providers
        ref.invalidate(offlineContentStatusProvider);
        ref.invalidate(offlineStorageStatsProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _downloadProgress = 0.0;
          _downloadStatus = '';
        });
      }
    }
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'This will remove downloaded content to free up storage space. '
          'Essential chapters can be kept for basic offline functionality.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearCache(keepEssential: true);
            },
            child: const Text('Keep Essential'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearCache(keepEssential: false);
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearCache({required bool keepEssential}) async {
    try {
      final service = ref.read(offlineContentServiceProvider);
      await service.clearOfflineContent(keepEssential: keepEssential);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              keepEssential 
                ? 'Cache cleared, essential content preserved'
                : 'All cached content cleared',
            ),
            backgroundColor: Colors.green,
          ),
        );
        
        // Refresh providers
        ref.invalidate(offlineContentStatusProvider);
        ref.invalidate(offlineStorageStatsProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to clear cache: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
