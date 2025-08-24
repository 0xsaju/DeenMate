import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../state/providers.dart';
import '../../../../core/theme/theme_helper.dart';

class BookmarksScreen extends ConsumerStatefulWidget {
  const BookmarksScreen({super.key});

  @override
  ConsumerState<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends ConsumerState<BookmarksScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategoryId;
  bool _isSelectionMode = false;
  Set<String> _selectedBookmarks = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Initialize default categories if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Note: This would call the actual service when implemented
      // ref.read(bookmarksServiceProvider).initializeDefaultCategories();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookmarksAsync = ref.watch(bookmarksListProvider);
    final categoriesAsync = ref.watch(bookmarkCategoriesProvider);

    return Scaffold(
      backgroundColor: ThemeHelper.getBackgroundColor(context),
      appBar: _buildAppBar(),
      body: _buildBody(bookmarksAsync, categoriesAsync),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: ThemeHelper.getBackgroundColor(context),
      elevation: 0,
      title: _isSelectionMode
          ? Text(
              '${_selectedBookmarks.length} selected',
              style: TextStyle(
                color: ThemeHelper.getTextPrimaryColor(context),
                fontWeight: FontWeight.w600,
              ),
            )
          : Text(
              'Bookmarks',
              style: TextStyle(
                color: ThemeHelper.getTextPrimaryColor(context),
                fontWeight: FontWeight.w600,
              ),
            ),
      leading: _isSelectionMode
          ? IconButton(
              icon: Icon(
                Icons.close,
                color: ThemeHelper.getTextPrimaryColor(context),
              ),
              onPressed: _exitSelectionMode,
            )
          : null,
      actions: _buildAppBarActions(),
      bottom: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'All', icon: Icon(Icons.bookmark)),
          Tab(text: 'Categories', icon: Icon(Icons.folder)),
          Tab(text: 'Recent', icon: Icon(Icons.access_time)),
        ],
        labelColor: ThemeHelper.getPrimaryColor(context),
        unselectedLabelColor: ThemeHelper.getTextSecondaryColor(context),
        indicatorColor: ThemeHelper.getPrimaryColor(context),
      ),
    );
  }

  List<Widget> _buildAppBarActions() {
    if (_isSelectionMode) {
      return [
        IconButton(
          icon: Icon(
            Icons.share,
            color: ThemeHelper.getTextPrimaryColor(context),
          ),
          onPressed: _shareSelectedBookmarks,
        ),
        IconButton(
          icon: Icon(
            Icons.delete,
            color: Colors.red,
          ),
          onPressed: _deleteSelectedBookmarks,
        ),
      ];
    }

    return [
      IconButton(
        icon: Icon(
          Icons.search,
          color: ThemeHelper.getTextPrimaryColor(context),
        ),
        onPressed: _showSearchDialog,
      ),
      PopupMenuButton<String>(
        icon: Icon(
          Icons.more_vert,
          color: ThemeHelper.getTextPrimaryColor(context),
        ),
        onSelected: _handleMenuAction,
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'sort',
            child: Row(
              children: [
                Icon(Icons.sort),
                SizedBox(width: 12),
                Text('Sort'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'categories',
            child: Row(
              children: [
                Icon(Icons.category),
                SizedBox(width: 12),
                Text('Manage Categories'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'export',
            child: Row(
              children: [
                Icon(Icons.download),
                SizedBox(width: 12),
                Text('Export'),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  Widget _buildBody(
    AsyncValue<List<dynamic>> bookmarksAsync,
    AsyncValue<List<dynamic>> categoriesAsync,
  ) {
    return Column(
      children: [
        // Search bar (when search is active)
        if (_searchQuery.isNotEmpty) _buildSearchBar(),
        
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildBookmarksList(bookmarksAsync),
              _buildCategoriesList(categoriesAsync),
              _buildRecentBookmarks(bookmarksAsync),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeHelper.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ThemeHelper.getDividerColor(context),
        ),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search bookmarks...',
          prefixIcon: Icon(
            Icons.search,
            color: ThemeHelper.getTextSecondaryColor(context),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              Icons.close,
              color: ThemeHelper.getTextSecondaryColor(context),
            ),
            onPressed: _clearSearch,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildBookmarksList(AsyncValue<List<dynamic>> bookmarksAsync) {
    return bookmarksAsync.when(
      data: (bookmarks) {
        if (bookmarks.isEmpty) {
          return _buildEmptyState(
            icon: Icons.bookmark_outline,
            title: 'No bookmarks yet',
            subtitle: 'Bookmark verses while reading to save them here',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bookmarks.length,
          itemBuilder: (context, index) {
            // For now, creating placeholder bookmark items
            return _buildBookmarkItem(
              verseKey: '${index + 1}:${(index % 10) + 1}',
              note: 'Sample bookmark note ${index + 1}',
              category: index % 3 == 0 ? 'Personal' : index % 3 == 1 ? 'Study' : null,
              tags: index % 2 == 0 ? ['Important', 'Reflection'] : ['Study'],
              createdAt: DateTime.now().subtract(Duration(days: index)),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildCategoriesList(AsyncValue<List<dynamic>> categoriesAsync) {
    return categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) {
          return _buildEmptyState(
            icon: Icons.folder,
            title: 'No categories yet',
            subtitle: 'Create categories to organize your bookmarks',
            actionText: 'Create Category',
            onAction: _showCreateCategoryDialog,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: categories.length + 1, // +1 for "Add Category" tile
          itemBuilder: (context, index) {
            if (index == categories.length) {
              return _buildAddCategoryTile();
            }

            // For now, creating placeholder category items
            return _buildCategoryItem(
              name: 'Category ${index + 1}',
              description: 'Sample category description',
              bookmarkCount: (index + 1) * 3,
              color: Colors.blue,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildRecentBookmarks(AsyncValue<List<dynamic>> bookmarksAsync) {
    return bookmarksAsync.when(
      data: (bookmarks) {
        if (bookmarks.isEmpty) {
          return _buildEmptyState(
            icon: Icons.access_time,
            title: 'No recent bookmarks',
            subtitle: 'Your recently added bookmarks will appear here',
          );
        }

        // Show only recent bookmarks (last 7 days)
        final recentBookmarks = bookmarks.take(10).toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: recentBookmarks.length,
          itemBuilder: (context, index) {
            return _buildBookmarkItem(
              verseKey: '${index + 1}:${(index % 10) + 1}',
              note: 'Recent bookmark ${index + 1}',
              category: null,
              tags: ['Recent'],
              createdAt: DateTime.now().subtract(Duration(hours: index * 6)),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildBookmarkItem({
    required String verseKey,
    String? note,
    String? category,
    List<String> tags = const [],
    required DateTime createdAt,
  }) {
    final isSelected = _selectedBookmarks.contains(verseKey);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _onBookmarkTap(verseKey),
        onLongPress: () => _onBookmarkLongPress(verseKey),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(
                    color: ThemeHelper.getPrimaryColor(context),
                    width: 2,
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with verse reference and actions
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: ThemeHelper.getPrimaryColor(context).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      verseKey,
                      style: TextStyle(
                        color: ThemeHelper.getPrimaryColor(context),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (_isSelectionMode)
                    Icon(
                      isSelected ? Icons.check_circle : Icons.circle_outlined,
                      color: isSelected
                          ? ThemeHelper.getPrimaryColor(context)
                          : ThemeHelper.getTextSecondaryColor(context),
                    )
                  else
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: ThemeHelper.getTextSecondaryColor(context),
                        size: 20,
                      ),
                      onSelected: (action) => _handleBookmarkAction(action, verseKey),
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(value: 'share', child: Text('Share')),
                        const PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                ],
              ),

              const SizedBox(height: 8),

              // Note (if available)
              if (note != null && note.isNotEmpty)
                Text(
                  note,
                  style: TextStyle(
                    color: ThemeHelper.getTextPrimaryColor(context),
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

              const SizedBox(height: 8),

              // Category and tags
              Row(
                children: [
                  if (category != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  
                  if (category != null && tags.isNotEmpty)
                    const SizedBox(width: 8),
                  
                  ...tags.map((tag) => Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '#$tag',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )),

                  const Spacer(),

                  Text(
                    _formatDate(createdAt),
                    style: TextStyle(
                      color: ThemeHelper.getTextSecondaryColor(context),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem({
    required String name,
    required String description,
    required int bookmarkCount,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(Icons.folder, color: color),
        ),
        title: Text(
          name,
          style: TextStyle(
            color: ThemeHelper.getTextPrimaryColor(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description,
              style: TextStyle(
                color: ThemeHelper.getTextSecondaryColor(context),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$bookmarkCount bookmarks',
              style: TextStyle(
                color: ThemeHelper.getTextSecondaryColor(context),
                fontSize: 10,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: ThemeHelper.getTextSecondaryColor(context),
          ),
          onSelected: (action) => _handleCategoryAction(action, name),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
        onTap: () => _openCategory(name),
      ),
    );
  }

  Widget _buildAddCategoryTile() {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: ThemeHelper.getDividerColor(context),
          style: BorderStyle.solid,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: ThemeHelper.getPrimaryColor(context).withOpacity(0.1),
          child: Icon(
            Icons.add,
            color: ThemeHelper.getPrimaryColor(context),
          ),
        ),
        title: Text(
          'Create New Category',
          style: TextStyle(
            color: ThemeHelper.getPrimaryColor(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'Organize your bookmarks into categories',
          style: TextStyle(
            color: ThemeHelper.getTextSecondaryColor(context),
            fontSize: 12,
          ),
        ),
        onTap: _showCreateCategoryDialog,
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: ThemeHelper.getTextSecondaryColor(context).withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ThemeHelper.getTextPrimaryColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: ThemeHelper.getTextSecondaryColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionText),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeHelper.getPrimaryColor(context),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Error loading bookmarks',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ThemeHelper.getTextPrimaryColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                fontSize: 14,
                color: ThemeHelper.getTextSecondaryColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {}); // Trigger rebuild
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeHelper.getPrimaryColor(context),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    if (_isSelectionMode) return null;

    return FloatingActionButton.extended(
      onPressed: _showAddBookmarkDialog,
      backgroundColor: ThemeHelper.getPrimaryColor(context),
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add),
      label: const Text('Add Bookmark'),
    );
  }

  // Action methods
  void _onBookmarkTap(String verseKey) {
    if (_isSelectionMode) {
      _toggleBookmarkSelection(verseKey);
    } else {
      _openBookmarkDetails(verseKey);
    }
  }

  void _onBookmarkLongPress(String verseKey) {
    if (!_isSelectionMode) {
      setState(() {
        _isSelectionMode = true;
        _selectedBookmarks.add(verseKey);
      });
    }
  }

  void _toggleBookmarkSelection(String verseKey) {
    setState(() {
      if (_selectedBookmarks.contains(verseKey)) {
        _selectedBookmarks.remove(verseKey);
        if (_selectedBookmarks.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedBookmarks.add(verseKey);
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedBookmarks.clear();
    });
  }

  void _shareSelectedBookmarks() {
    final bookmarksText = _selectedBookmarks.join(', ');
    Share.share('My bookmarked verses: $bookmarksText');
    _exitSelectionMode();
  }

  void _deleteSelectedBookmarks() async {
    if (_selectedBookmarks.isEmpty) return;
    
    final service = ref.read(bookmarksServiceProvider);
    final count = _selectedBookmarks.length;
    
    try {
      // Delete all selected bookmarks
      for (final verseKey in _selectedBookmarks) {
        await service.removeBookmark(verseKey);
      }
      
      _exitSelectionMode();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$count bookmarks deleted'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Refresh the bookmark list
      ref.invalidate(bookmarksListProvider);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting bookmarks: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSearchDialog() {
    setState(() {
      _searchQuery = 'search'; // Trigger search bar display
    });
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
    });
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'sort':
        _showSortDialog();
        break;
      case 'categories':
        _showManageCategoriesDialog();
        break;
      case 'export':
        _exportBookmarks();
        break;
    }
  }

  void _handleBookmarkAction(String action, String verseKey) {
    switch (action) {
      case 'edit':
        _editBookmark(verseKey);
        break;
      case 'share':
        Share.share('Bookmarked verse: $verseKey');
        break;
      case 'delete':
        _deleteBookmark(verseKey);
        break;
    }
  }

  void _handleCategoryAction(String action, String categoryName) {
    switch (action) {
      case 'edit':
        _editCategory(categoryName);
        break;
      case 'delete':
        _deleteCategory(categoryName);
        break;
    }
  }

  void _openBookmarkDetails(String verseKey) {
    // Navigate to the verse in Enhanced Quran Reader
    final parts = verseKey.split(':');
    final chapterId = int.tryParse(parts.first) ?? 1;
    final verseNumber = int.tryParse(parts.last) ?? 1;
    
    // Navigate to Quran reader with specific verse
    context.go('/quran/surah/$chapterId/verse/$verseKey');
  }

  void _openCategory(String categoryName) {
    setState(() {
      _selectedCategoryId = categoryName;
      _tabController.animateTo(0); // Switch to "All" tab with filter
    });
  }

  void _showAddBookmarkDialog() {
    // TODO: Show dialog to add bookmark manually
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add bookmark dialog - Coming soon')),
    );
  }

  void _showCreateCategoryDialog() {
    // TODO: Show dialog to create new category
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create category dialog - Coming soon')),
    );
  }

  void _showSortDialog() {
    // TODO: Show sort options dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sort options - Coming soon')),
    );
  }

  void _showManageCategoriesDialog() {
    // TODO: Show category management dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Manage categories - Coming soon')),
    );
  }

  void _exportBookmarks() {
    // TODO: Export bookmarks functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export bookmarks - Coming soon')),
    );
  }

  void _editBookmark(String verseKey) {
    // TODO: Edit bookmark functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit bookmark $verseKey - Coming soon')),
    );
  }

  void _deleteBookmark(String verseKey) async {
    final service = ref.read(bookmarksServiceProvider);
    
    try {
      await service.removeBookmark(verseKey);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bookmark removed: $verseKey'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Refresh the bookmark list
      ref.invalidate(bookmarksListProvider);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error removing bookmark: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _editCategory(String categoryName) {
    // TODO: Edit category functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit category $categoryName - Coming soon')),
    );
  }

  void _deleteCategory(String categoryName) {
    // TODO: Delete category functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Delete category $categoryName - Coming soon')),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}