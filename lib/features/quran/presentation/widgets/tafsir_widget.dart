import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/dto/verse_dto.dart';
import '../../data/dto/tafsir_dto.dart';
import '../state/providers.dart';
import '../../../../core/theme/theme_helper.dart';

class TafsirWidget extends ConsumerStatefulWidget {
  const TafsirWidget({
    super.key,
    required this.verse,
    this.selectedTafsirId,
  });

  final VerseDto verse;
  final int? selectedTafsirId;

  @override
  ConsumerState<TafsirWidget> createState() => _TafsirWidgetState();
}

class _TafsirWidgetState extends ConsumerState<TafsirWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int? _selectedTafsirId;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _selectedTafsirId = widget.selectedTafsirId;
    _tabController = TabController(length: 0, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tafsirResourcesAsync = ref.watch(tafsirResourcesProvider);
    // final prefs = ref.watch(prefsProvider); // TODO: Use when implementing tafsir preferences

    return tafsirResourcesAsync.when(
      data: (resources) {
        if (resources.isEmpty) {
          return _buildNoTafsirAvailable();
        }

        // Update tab controller if needed
        if (_tabController.length != resources.length) {
          _tabController.dispose();
          _tabController = TabController(length: resources.length, vsync: this);
        }

        // Set default tafsir if none selected
        if (_selectedTafsirId == null && resources.isNotEmpty) {
          _selectedTafsirId = resources.first.id;
        }

        return Container(
          margin: const EdgeInsets.only(top: 16),
          decoration: BoxDecoration(
            color: ThemeHelper.getSurfaceColor(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: ThemeHelper.getDividerColor(context),
              width: 1,
            ),
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
              _buildTafsirHeader(resources),
              if (_isExpanded) ...[
                _buildTafsirTabs(resources),
                _buildTafsirContent(),
              ],
            ],
          ),
        );
      },
      loading: () => _buildLoadingTafsir(),
      error: (error, _) => _buildErrorTafsir(error),
    );
  }

  Widget _buildTafsirHeader(List<TafsirResourceDto> resources) {
    return InkWell(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ThemeHelper.getPrimaryColor(context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.menu_book,
                color: ThemeHelper.getPrimaryColor(context),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tafsir (Commentary)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ThemeHelper.getTextPrimaryColor(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isExpanded 
                      ? 'Tap to hide commentary'
                      : '${resources.length} commentaries available',
                    style: TextStyle(
                      fontSize: 12,
                      color: ThemeHelper.getTextSecondaryColor(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
              color: ThemeHelper.getTextSecondaryColor(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTafsirTabs(List<TafsirResourceDto> resources) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: ThemeHelper.getDividerColor(context),
            width: 1,
          ),
          bottom: BorderSide(
            color: ThemeHelper.getDividerColor(context),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: ThemeHelper.getPrimaryColor(context),
        indicatorWeight: 3,
        labelColor: ThemeHelper.getPrimaryColor(context),
        unselectedLabelColor: ThemeHelper.getTextSecondaryColor(context),
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        onTap: (index) {
          setState(() {
            _selectedTafsirId = resources[index].id;
          });
        },
        tabs: resources.map((resource) {
          return Tab(
            text: _getTafsirDisplayName(resource),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTafsirContent() {
    if (_selectedTafsirId == null) {
      return const SizedBox.shrink();
    }

    final tafsirAsync = ref.watch(tafsirByVerseProvider({
      'verseKey': widget.verse.verseKey,
      'resourceId': _selectedTafsirId!,
    }));

    return Container(
      constraints: const BoxConstraints(
        minHeight: 200,
        maxHeight: 500,
      ),
      child: tafsirAsync.when(
        data: (tafsir) => _buildTafsirText(tafsir),
        loading: () => _buildLoadingContent(),
        error: (error, _) => _buildErrorContent(error),
      ),
    );
  }

  Widget _buildTafsirText(TafsirDto tafsir) {
    final prefs = ref.watch(prefsProvider);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tafsir source info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: ThemeHelper.getPrimaryColor(context).withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.person,
                  size: 14,
                  color: ThemeHelper.getPrimaryColor(context),
                ),
                const SizedBox(width: 6),
                Text(
                  tafsir.resourceName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ThemeHelper.getPrimaryColor(context),
                  ),
                ),
                if (tafsir.languageName != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: ThemeHelper.getDividerColor(context),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tafsir.languageName!,
                      style: TextStyle(
                        fontSize: 10,
                        color: ThemeHelper.getTextSecondaryColor(context),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Tafsir text
          SelectableText(
            _cleanTafsirText(tafsir.text),
            style: TextStyle(
              fontSize: prefs.tafsirFontSize,
              height: prefs.tafsirLineHeight,
              color: ThemeHelper.getTextPrimaryColor(context),
              letterSpacing: 0.2,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Action buttons
          Row(
            children: [
              _buildActionButton(
                Icons.copy,
                'Copy',
                () => _copyTafsir(tafsir),
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                Icons.share,
                'Share',
                () => _shareTafsir(tafsir),
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                Icons.bookmark_outline,
                'Save',
                () => _saveTafsir(tafsir),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: ThemeHelper.getDividerColor(context),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: ThemeHelper.getTextSecondaryColor(context),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: ThemeHelper.getTextSecondaryColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingTafsir() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeHelper.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeHelper.getDividerColor(context)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                ThemeHelper.getPrimaryColor(context),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Loading tafsir...',
            style: TextStyle(
              fontSize: 14,
              color: ThemeHelper.getTextSecondaryColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingContent() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                ThemeHelper.getPrimaryColor(context),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading commentary...',
              style: TextStyle(
                fontSize: 14,
                color: ThemeHelper.getTextSecondaryColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorTafsir(Object error) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Error loading tafsir: $error',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorContent(Object error) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error loading commentary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$error',
              style: TextStyle(
                fontSize: 12,
                color: ThemeHelper.getTextSecondaryColor(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoTafsirAvailable() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeHelper.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeHelper.getDividerColor(context)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.menu_book_outlined,
            color: ThemeHelper.getTextSecondaryColor(context),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'No tafsir available for this verse',
              style: TextStyle(
                fontSize: 14,
                color: ThemeHelper.getTextSecondaryColor(context),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods

  String _getTafsirDisplayName(TafsirResourceDto resource) {
    // Shorten common tafsir names for tabs
    final name = resource.name ?? 'Unknown';
    if (name.contains('Ibn Kathir')) return 'Ibn Kathir';
    if (name.contains('Tabari')) return 'Tabari';
    if (name.contains('Jalalayn')) return 'Jalalayn';
    if (name.contains('Qurtubi')) return 'Qurtubi';
    if (name.contains('Baghawi')) return 'Baghawi';
    if (name.contains('Sa\'di')) return 'Sa\'di';
    if (name.length > 15) return '${name.substring(0, 12)}...';
    return name;
  }

  String _cleanTafsirText(String text) {
    return text
        .replaceAll(RegExp(r'<[^>]+>'), '') // Remove HTML tags
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize whitespace
        .trim();
  }

  void _copyTafsir(TafsirDto tafsir) {
    // TODO: Implement copy functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tafsir copied to clipboard')),
    );
  }

  void _shareTafsir(TafsirDto tafsir) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share tafsir functionality coming soon')),
    );
  }

  void _saveTafsir(TafsirDto tafsir) {
    // TODO: Implement save functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Save tafsir functionality coming soon')),
    );
  }
}
