import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/dto/chapter_dto.dart';
import '../../data/dto/recitation_resource_dto.dart';
import '../state/providers.dart' hide audioStorageStatsProvider;
import '../../domain/services/audio_service.dart' as audio_service;
import '../../../../core/theme/theme_helper.dart';

class AudioDownloadsScreen extends ConsumerStatefulWidget {
  const AudioDownloadsScreen({super.key});

  @override
  ConsumerState<AudioDownloadsScreen> createState() => _AudioDownloadsScreenState();
}

class _AudioDownloadsScreenState extends ConsumerState<AudioDownloadsScreen> {
  int _selectedReciterId = 7; // Default to Alafasy
  bool _isDownloading = false;
  Map<int, double> _chapterProgress = {};
  String _currentDownloadStatus = '';

  @override
  Widget build(BuildContext context) {
    final chaptersAsync = ref.watch(surahListProvider);
    final recitersAsync = ref.watch(recitationResourcesProvider);
    final storageStats = ref.watch(audio_service.audioStorageStatsProvider);

    return Scaffold(
      backgroundColor: ThemeHelper.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: ThemeHelper.getBackgroundColor(context),
        elevation: 0,
        title: Text(
          'Audio Downloads',
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
          // Storage overview
          _buildStorageOverview(storageStats),
          const SizedBox(height: 20),

          // Reciter selection
          _buildReciterSelection(recitersAsync),
          const SizedBox(height: 20),

          // Quick actions
          _buildQuickActions(),
          const SizedBox(height: 20),

          // Chapter list
          _buildChaptersList(chaptersAsync),
        ],
      ),
    );
  }

  Widget _buildStorageOverview(AsyncValue<audio_service.AudioStorageStats> statsAsync) {
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
                  Icons.audiotrack,
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
                      'Audio Storage',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ThemeHelper.getTextPrimaryColor(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    statsAsync.when(
                      data: (stats) => Text(
                        '${stats.totalSizeMB.toStringAsFixed(1)} MB • ${stats.fileCount} files',
                        style: TextStyle(
                          fontSize: 12,
                          color: ThemeHelper.getTextSecondaryColor(context),
                        ),
                      ),
                      loading: () => Text(
                        'Loading...',
                        style: TextStyle(
                          fontSize: 12,
                          color: ThemeHelper.getTextSecondaryColor(context),
                        ),
                      ),
                      error: (_, __) => Text(
                        'Error loading stats',
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
          
          if (_isDownloading) ...[
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentDownloadStatus,
                  style: TextStyle(
                    fontSize: 12,
                    color: ThemeHelper.getTextSecondaryColor(context),
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  backgroundColor: ThemeHelper.getDividerColor(context),
                  valueColor: AlwaysStoppedAnimation<Color>(ThemeHelper.getPrimaryColor(context)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReciterSelection(AsyncValue<List<RecitationResourceDto>> recitersAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Reciter',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ThemeHelper.getTextPrimaryColor(context),
          ),
        ),
        const SizedBox(height: 12),
        recitersAsync.when(
          data: (reciters) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: ThemeHelper.getSurfaceColor(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ThemeHelper.getDividerColor(context)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedReciterId,
                isExpanded: true,
                style: TextStyle(
                  fontSize: 14,
                  color: ThemeHelper.getTextPrimaryColor(context),
                ),
                items: reciters.map((reciter) {
                  return DropdownMenuItem<int>(
                    value: reciter.id,
                    child: Text(reciter.name),
                  );
                }).toList(),
                onChanged: _isDownloading ? null : (value) {
                  if (value != null) {
                    setState(() {
                      _selectedReciterId = value;
                    });
                  }
                },
              ),
            ),
          ),
          loading: () => Container(
            height: 48,
            decoration: BoxDecoration(
              color: ThemeHelper.getSurfaceColor(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ThemeHelper.getDividerColor(context)),
            ),
            child: const Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => Container(
            height: 48,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ThemeHelper.getSurfaceColor(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red),
            ),
            child: Text(
              'Error loading reciters',
              style: TextStyle(color: Colors.red),
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
                'Download Popular',
                Icons.star,
                'Download most popular chapters',
                _isDownloading ? null : _downloadPopularChapters,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Download All',
                Icons.download_for_offline,
                'Download complete Quran',
                _isDownloading ? null : _downloadAllChapters,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    String subtitle,
    VoidCallback? onTap,
  ) {
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
              color: onTap != null 
                ? ThemeHelper.getPrimaryColor(context) 
                : ThemeHelper.getTextSecondaryColor(context),
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: onTap != null 
                  ? ThemeHelper.getTextPrimaryColor(context) 
                  : ThemeHelper.getTextSecondaryColor(context),
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

  Widget _buildChaptersList(AsyncValue<List<ChapterDto>> chaptersAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Individual Chapters',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ThemeHelper.getTextPrimaryColor(context),
          ),
        ),
        const SizedBox(height: 12),
        chaptersAsync.when(
          data: (chapters) => Column(
            children: chapters.map((chapter) => 
              FutureBuilder<bool>(
                future: _isChapterDownloaded(chapter.id),
                builder: (context, snapshot) {
                  final isDownloaded = snapshot.data ?? false;
                  return _buildChapterTile(chapter, persistentDownload: isDownloaded);
                },
              ),
            ).toList(),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(
              'Error loading chapters: $error',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChapterTile(ChapterDto chapter, {bool persistentDownload = false}) {
    final progress = _chapterProgress[chapter.id] ?? 0.0;
    final isDownloading = progress > 0 && progress < 1.0;
    final isDownloaded = progress >= 1.0 || persistentDownload;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: ThemeHelper.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeHelper.getDividerColor(context)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDownloaded 
              ? Colors.green.withOpacity(0.1)
              : ThemeHelper.getPrimaryColor(context).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: isDownloading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      ThemeHelper.getPrimaryColor(context),
                    ),
                  ),
                )
              : Icon(
                  isDownloaded ? Icons.download_done : Icons.download,
                  color: isDownloaded 
                    ? Colors.green 
                    : ThemeHelper.getPrimaryColor(context),
                  size: 20,
                ),
          ),
        ),
        title: Text(
          chapter.nameSimple,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ThemeHelper.getTextPrimaryColor(context),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              chapter.nameArabic,
              style: TextStyle(
                fontSize: 12,
                color: ThemeHelper.getTextSecondaryColor(context),
                fontFamily: 'Uthmani',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${chapter.versesCount} verses • ${chapter.revelationPlace}',
              style: TextStyle(
                fontSize: 11,
                color: ThemeHelper.getTextSecondaryColor(context),
              ),
            ),
            if (isDownloading) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: ThemeHelper.getDividerColor(context),
                valueColor: AlwaysStoppedAnimation<Color>(
                  ThemeHelper.getPrimaryColor(context),
                ),
              ),
            ],
          ],
        ),
        trailing: isDownloaded
          ? PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: ThemeHelper.getTextSecondaryColor(context),
              ),
              onSelected: (value) {
                if (value == 'delete') {
                  _deleteChapterAudio(chapter.id);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      const SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            )
          : IconButton(
              icon: Icon(
                Icons.download,
                color: _isDownloading 
                  ? ThemeHelper.getTextSecondaryColor(context)
                  : ThemeHelper.getPrimaryColor(context),
              ),
              onPressed: _isDownloading ? null : () => _downloadChapter(chapter.id),
            ),
      ),
    );
  }

  // Action handlers

  void _downloadPopularChapters() async {
    final popularChapters = [1, 2, 18, 36, 55, 67, 112, 113, 114]; // Popular surahs
    
    setState(() {
      _isDownloading = true;
      _currentDownloadStatus = 'Downloading popular chapters...';
    });

    try {
      for (int i = 0; i < popularChapters.length; i++) {
        final chapterId = popularChapters[i];
        await _downloadChapterInternal(chapterId, (progress, status) {
          setState(() {
            _currentDownloadStatus = 'Downloading chapter $chapterId: $status';
            _chapterProgress[chapterId] = progress;
          });
        });
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Popular chapters downloaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isDownloading = false;
        _currentDownloadStatus = '';
      });
      
      // Refresh storage stats
      ref.invalidate(audio_service.audioStorageStatsProvider);
    }
  }

  void _downloadAllChapters() async {
    final chapters = await ref.read(surahListProvider.future);
    
    setState(() {
      _isDownloading = true;
      _currentDownloadStatus = 'Downloading complete Quran...';
    });

    try {
      for (int i = 0; i < chapters.length; i++) {
        final chapter = chapters[i];
        await _downloadChapterInternal(chapter.id, (progress, status) {
          setState(() {
            _currentDownloadStatus = 'Downloading ${chapter.nameSimple}: $status';
            _chapterProgress[chapter.id] = progress;
          });
        });
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Complete Quran downloaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isDownloading = false;
        _currentDownloadStatus = '';
      });
      
      // Refresh storage stats
      ref.invalidate(audio_service.audioStorageStatsProvider);
    }
  }

  void _downloadChapter(int chapterId) async {
    setState(() {
      _chapterProgress[chapterId] = 0.01; // Show as starting
    });

    try {
      await _downloadChapterInternal(chapterId, (progress, status) {
        setState(() {
          _chapterProgress[chapterId] = progress;
        });
      });
      
      setState(() {
        _chapterProgress[chapterId] = 1.0; // Mark as complete
      });
      
      // Refresh storage stats
      ref.invalidate(audio_service.audioStorageStatsProvider);
    } catch (e) {
      setState(() {
        _chapterProgress.remove(chapterId);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _downloadChapterInternal(
    int chapterId,
    Function(double progress, String status) onProgress,
  ) async {
    try {
      final audioService = ref.read(quranAudioServiceProvider);
      
      // For now, create placeholder verse audio list
      // In a real implementation, this would fetch actual verses from the API
      final verses = <audio_service.VerseAudio>[];
      for (int i = 1; i <= 10; i++) {
        verses.add(audio_service.VerseAudio(
          verseKey: '$chapterId:$i',
          chapterId: chapterId,
          verseNumber: i,
          reciterId: _selectedReciterId,
          localPath: null,
          onlineUrl: 'https://example.com/audio/$chapterId/$i.mp3',
        ));
      }
      
      // Download chapter audio using existing method signature
      await audioService.downloadChapterAudio(
        chapterId,
        _selectedReciterId,
        verses,
        onProgress: (progress, currentVerse) {
          onProgress(progress, 'Downloading $currentVerse');
        },
      );
      
      // Mark chapter as downloaded in preferences
      await _markChapterAsDownloaded(chapterId);
      
    } catch (e) {
      print('Download error: $e');
      rethrow;
    }
  }

  Future<void> _markChapterAsDownloaded(int chapterId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final downloaded = prefs.getStringList('downloaded_chapters') ?? [];
      if (!downloaded.contains(chapterId.toString())) {
        downloaded.add(chapterId.toString());
        await prefs.setStringList('downloaded_chapters', downloaded);
      }
    } catch (e) {
      print('Error marking chapter as downloaded: $e');
    }
  }

  Future<bool> _isChapterDownloaded(int chapterId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final downloaded = prefs.getStringList('downloaded_chapters') ?? [];
      return downloaded.contains(chapterId.toString());
    } catch (e) {
      print('Error checking download status: $e');
      return false;
    }
  }

  void _deleteChapterAudio(int chapterId) async {
    try {
      final audioService = ref.read(quranAudioServiceProvider);
      
      // Delete audio files through audio service
      await audioService.deleteChapterAudio(chapterId, _selectedReciterId);
      
      // Remove from persistent storage
      await _markChapterAsNotDownloaded(chapterId);
      
      setState(() {
        _chapterProgress.remove(chapterId);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chapter audio deleted'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Refresh storage stats
      ref.invalidate(audio_service.audioStorageStatsProvider);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Delete failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _markChapterAsNotDownloaded(int chapterId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final downloaded = prefs.getStringList('downloaded_chapters') ?? [];
      downloaded.remove(chapterId.toString());
      await prefs.setStringList('downloaded_chapters', downloaded);
    } catch (e) {
      print('Error marking chapter as not downloaded: $e');
    }
  }
}
