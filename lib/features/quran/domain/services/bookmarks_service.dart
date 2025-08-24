import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/storage/hive_boxes.dart' as boxes;

/// Comprehensive bookmarks and notes service for Quran verses
/// Supports categories, tags, personal notes, and advanced organization
class BookmarksService {
  final StreamController<List<Bookmark>> _bookmarksController = StreamController<List<Bookmark>>.broadcast();
  final StreamController<List<BookmarkCategory>> _categoriesController = StreamController<List<BookmarkCategory>>.broadcast();

  Stream<List<Bookmark>> get bookmarksStream => _bookmarksController.stream;
  Stream<List<BookmarkCategory>> get categoriesStream => _categoriesController.stream;

  /// Add a bookmark for a verse
  Future<void> addBookmark({
    required String verseKey,
    required int chapterId,
    required int verseNumber,
    String? categoryId,
    String? note,
    List<String> tags = const [],
    String? customTitle,
  }) async {
    try {
      final box = await Hive.openBox(boxes.Boxes.bookmarks);
      final bookmarks = await getAllBookmarks();
      
      // Check if already bookmarked
      final existingIndex = bookmarks.indexWhere((b) => b.verseKey == verseKey);
      if (existingIndex != -1) {
        // Update existing bookmark
        final existing = bookmarks[existingIndex];
        final updated = existing.copyWith(
          categoryId: categoryId ?? existing.categoryId,
          note: note ?? existing.note,
          tags: tags.isNotEmpty ? tags : existing.tags,
          customTitle: customTitle ?? existing.customTitle,
          updatedAt: DateTime.now(),
        );
        bookmarks[existingIndex] = updated;
      } else {
        // Create new bookmark
        final bookmark = Bookmark(
          id: _generateId(),
          verseKey: verseKey,
          chapterId: chapterId,
          verseNumber: verseNumber,
          categoryId: categoryId,
          note: note,
          tags: tags,
          customTitle: customTitle,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        bookmarks.add(bookmark);
      }
      
      // Sort by creation date (newest first)
      bookmarks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      await box.put('bookmarks', bookmarks.map((b) => b.toMap()).toList());
      _bookmarksController.add(bookmarks);
      
      if (kDebugMode) {
        print('Bookmark added/updated for verse: $verseKey');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error adding bookmark: $e');
      }
      rethrow;
    }
  }

  /// Remove a bookmark
  Future<void> removeBookmark(String verseKey) async {
    try {
      final box = await Hive.openBox(boxes.Boxes.bookmarks);
      final bookmarks = await getAllBookmarks();
      
      bookmarks.removeWhere((b) => b.verseKey == verseKey);
      
      await box.put('bookmarks', bookmarks.map((b) => b.toMap()).toList());
      _bookmarksController.add(bookmarks);
      
      if (kDebugMode) {
        print('Bookmark removed for verse: $verseKey');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error removing bookmark: $e');
      }
      rethrow;
    }
  }

  /// Update bookmark note
  Future<void> updateBookmarkNote(String verseKey, String note) async {
    try {
      final box = await Hive.openBox(boxes.Boxes.bookmarks);
      final bookmarks = await getAllBookmarks();
      
      final index = bookmarks.indexWhere((b) => b.verseKey == verseKey);
      if (index != -1) {
        bookmarks[index] = bookmarks[index].copyWith(
          note: note,
          updatedAt: DateTime.now(),
        );
        
        await box.put('bookmarks', bookmarks.map((b) => b.toMap()).toList());
        _bookmarksController.add(bookmarks);
        
        if (kDebugMode) {
          print('Bookmark note updated for verse: $verseKey');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating bookmark note: $e');
      }
      rethrow;
    }
  }

  /// Update bookmark category
  Future<void> updateBookmarkCategory(String verseKey, String? categoryId) async {
    try {
      final box = await Hive.openBox(boxes.Boxes.bookmarks);
      final bookmarks = await getAllBookmarks();
      
      final index = bookmarks.indexWhere((b) => b.verseKey == verseKey);
      if (index != -1) {
        bookmarks[index] = bookmarks[index].copyWith(
          categoryId: categoryId,
          updatedAt: DateTime.now(),
        );
        
        await box.put('bookmarks', bookmarks.map((b) => b.toMap()).toList());
        _bookmarksController.add(bookmarks);
        
        if (kDebugMode) {
          print('Bookmark category updated for verse: $verseKey');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating bookmark category: $e');
      }
      rethrow;
    }
  }

  /// Add or update bookmark tags
  Future<void> updateBookmarkTags(String verseKey, List<String> tags) async {
    try {
      final box = await Hive.openBox(boxes.Boxes.bookmarks);
      final bookmarks = await getAllBookmarks();
      
      final index = bookmarks.indexWhere((b) => b.verseKey == verseKey);
      if (index != -1) {
        bookmarks[index] = bookmarks[index].copyWith(
          tags: tags,
          updatedAt: DateTime.now(),
        );
        
        await box.put('bookmarks', bookmarks.map((b) => b.toMap()).toList());
        _bookmarksController.add(bookmarks);
        
        if (kDebugMode) {
          print('Bookmark tags updated for verse: $verseKey');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating bookmark tags: $e');
      }
      rethrow;
    }
  }

  /// Get all bookmarks
  Future<List<Bookmark>> getAllBookmarks() async {
    try {
      final box = await Hive.openBox(boxes.Boxes.bookmarks);
      final data = box.get('bookmarks', defaultValue: <Map>[]) as List;
      
      return data
          .map((item) => Bookmark.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting bookmarks: $e');
      }
      return [];
    }
  }

  /// Get bookmarks by category
  Future<List<Bookmark>> getBookmarksByCategory(String? categoryId) async {
    final allBookmarks = await getAllBookmarks();
    
    if (categoryId == null) {
      return allBookmarks.where((b) => b.categoryId == null).toList();
    }
    
    return allBookmarks.where((b) => b.categoryId == categoryId).toList();
  }

  /// Get bookmarks by tag
  Future<List<Bookmark>> getBookmarksByTag(String tag) async {
    final allBookmarks = await getAllBookmarks();
    return allBookmarks.where((b) => b.tags.contains(tag)).toList();
  }

  /// Search bookmarks
  Future<List<Bookmark>> searchBookmarks(String query) async {
    if (query.trim().isEmpty) return [];
    
    final allBookmarks = await getAllBookmarks();
    final queryLower = query.toLowerCase();
    
    return allBookmarks.where((bookmark) {
      // Search in note
      if (bookmark.note != null && bookmark.note!.toLowerCase().contains(queryLower)) {
        return true;
      }
      
      // Search in custom title
      if (bookmark.customTitle != null && bookmark.customTitle!.toLowerCase().contains(queryLower)) {
        return true;
      }
      
      // Search in tags
      if (bookmark.tags.any((tag) => tag.toLowerCase().contains(queryLower))) {
        return true;
      }
      
      // Search in verse key
      if (bookmark.verseKey.contains(query)) {
        return true;
      }
      
      return false;
    }).toList();
  }

  /// Check if verse is bookmarked
  Future<bool> isBookmarked(String verseKey) async {
    final bookmarks = await getAllBookmarks();
    return bookmarks.any((b) => b.verseKey == verseKey);
  }

  /// Get bookmark for specific verse
  Future<Bookmark?> getBookmark(String verseKey) async {
    final bookmarks = await getAllBookmarks();
    try {
      return bookmarks.firstWhere((b) => b.verseKey == verseKey);
    } catch (e) {
      return null;
    }
  }

  /// Export bookmarks as text
  Future<String> exportBookmarks({List<String>? categoryIds}) async {
    final bookmarks = await getAllBookmarks();
    final categories = await getAllCategories();
    
    final buffer = StringBuffer();
    buffer.writeln('📚 My Quran Bookmarks');
    buffer.writeln('Generated on: ${DateTime.now().toString().split('.')[0]}');
    buffer.writeln('=' * 50);
    buffer.writeln();
    
    // Group bookmarks by category
    final Map<String?, List<Bookmark>> groupedBookmarks = {};
    
    for (final bookmark in bookmarks) {
      if (categoryIds != null && !categoryIds.contains(bookmark.categoryId)) {
        continue;
      }
      
      groupedBookmarks.putIfAbsent(bookmark.categoryId, () => []).add(bookmark);
    }
    
    // Write each category
    for (final entry in groupedBookmarks.entries) {
      final categoryId = entry.key;
      final categoryBookmarks = entry.value;
      
      // Category header
      if (categoryId != null) {
        final category = categories.firstWhere((c) => c.id == categoryId, 
            orElse: () => BookmarkCategory(
              id: categoryId, 
              name: 'Unknown Category', 
              color: 0xFF6200EE,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ));
        buffer.writeln('📂 ${category.name}');
      } else {
        buffer.writeln('📂 Uncategorized');
      }
      buffer.writeln('-' * 30);
      
      // Bookmarks in category
      for (final bookmark in categoryBookmarks) {
        buffer.writeln('🔖 ${bookmark.verseKey}');
        if (bookmark.customTitle != null) {
          buffer.writeln('   Title: ${bookmark.customTitle}');
        }
        if (bookmark.note != null && bookmark.note!.isNotEmpty) {
          buffer.writeln('   Note: ${bookmark.note}');
        }
        if (bookmark.tags.isNotEmpty) {
          buffer.writeln('   Tags: ${bookmark.tags.join(', ')}');
        }
        buffer.writeln('   Date: ${bookmark.createdAt.toString().split('.')[0]}');
        buffer.writeln();
      }
      buffer.writeln();
    }
    
    return buffer.toString();
  }

  /// Get bookmark statistics
  Future<BookmarkStats> getBookmarkStats() async {
    final bookmarks = await getAllBookmarks();
    final categories = await getAllCategories();
    
    final Map<int, int> chapterCounts = {};
    final Map<String, int> tagCounts = {};
    int totalNotes = 0;
    
    for (final bookmark in bookmarks) {
      // Count by chapter
      chapterCounts[bookmark.chapterId] = (chapterCounts[bookmark.chapterId] ?? 0) + 1;
      
      // Count tags
      for (final tag in bookmark.tags) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
      
      // Count notes
      if (bookmark.note != null && bookmark.note!.isNotEmpty) {
        totalNotes++;
      }
    }
    
    return BookmarkStats(
      totalBookmarks: bookmarks.length,
      totalCategories: categories.length,
      totalNotes: totalNotes,
      chapterCounts: chapterCounts,
      tagCounts: tagCounts,
      oldestBookmark: bookmarks.isNotEmpty 
          ? bookmarks.reduce((a, b) => a.createdAt.isBefore(b.createdAt) ? a : b).createdAt
          : null,
      newestBookmark: bookmarks.isNotEmpty 
          ? bookmarks.reduce((a, b) => a.createdAt.isAfter(b.createdAt) ? a : b).createdAt
          : null,
    );
  }

  // Category management

  /// Create a new bookmark category
  Future<void> createCategory({
    required String name,
    String? description,
    int color = 0xFF6200EE,
    String? icon,
  }) async {
    try {
      final box = await Hive.openBox(boxes.Boxes.bookmarks);
      final categories = await getAllCategories();
      
      final category = BookmarkCategory(
        id: _generateId(),
        name: name,
        description: description,
        color: color,
        icon: icon,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      categories.add(category);
      
      await box.put('categories', categories.map((c) => c.toMap()).toList());
      _categoriesController.add(categories);
      
      if (kDebugMode) {
        print('Category created: $name');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating category: $e');
      }
      rethrow;
    }
  }

  /// Update a bookmark category
  Future<void> updateCategory({
    required String id,
    String? name,
    String? description,
    int? color,
    String? icon,
  }) async {
    try {
      final box = await Hive.openBox(boxes.Boxes.bookmarks);
      final categories = await getAllCategories();
      
      final index = categories.indexWhere((c) => c.id == id);
      if (index != -1) {
        categories[index] = categories[index].copyWith(
          name: name,
          description: description,
          color: color,
          icon: icon,
          updatedAt: DateTime.now(),
        );
        
        await box.put('categories', categories.map((c) => c.toMap()).toList());
        _categoriesController.add(categories);
        
        if (kDebugMode) {
          print('Category updated: $id');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating category: $e');
      }
      rethrow;
    }
  }

  /// Delete a bookmark category
  Future<void> deleteCategory(String id) async {
    try {
      final box = await Hive.openBox(boxes.Boxes.bookmarks);
      final categories = await getAllCategories();
      final bookmarks = await getAllBookmarks();
      
      // Remove category
      categories.removeWhere((c) => c.id == id);
      
      // Remove category from bookmarks
      for (int i = 0; i < bookmarks.length; i++) {
        if (bookmarks[i].categoryId == id) {
          bookmarks[i] = bookmarks[i].copyWith(categoryId: null);
        }
      }
      
      await box.put('categories', categories.map((c) => c.toMap()).toList());
      await box.put('bookmarks', bookmarks.map((b) => b.toMap()).toList());
      
      _categoriesController.add(categories);
      _bookmarksController.add(bookmarks);
      
      if (kDebugMode) {
        print('Category deleted: $id');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting category: $e');
      }
      rethrow;
    }
  }

  /// Get all bookmark categories
  Future<List<BookmarkCategory>> getAllCategories() async {
    try {
      final box = await Hive.openBox(boxes.Boxes.bookmarks);
      final data = box.get('categories', defaultValue: <Map>[]) as List;
      
      return data
          .map((item) => BookmarkCategory.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting categories: $e');
      }
      return [];
    }
  }

  /// Initialize with default categories
  Future<void> initializeDefaultCategories() async {
    final categories = await getAllCategories();
    if (categories.isNotEmpty) return; // Already initialized
    
    final defaultCategories = [
      BookmarkCategory(
        id: 'favorites',
        name: 'Favorites',
        description: 'My favorite verses',
        color: 0xFFE91E63,
        icon: 'favorite',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      BookmarkCategory(
        id: 'study',
        name: 'Study',
        description: 'Verses for study and reflection',
        color: 0xFF2196F3,
        icon: 'school',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      BookmarkCategory(
        id: 'comfort',
        name: 'Comfort',
        description: 'Verses for comfort and peace',
        color: 0xFF4CAF50,
        icon: 'healing',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      BookmarkCategory(
        id: 'guidance',
        name: 'Guidance',
        description: 'Verses for guidance and direction',
        color: 0xFFFF9800,
        icon: 'explore',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
    
    final box = await Hive.openBox(boxes.Boxes.bookmarks);
    await box.put('categories', defaultCategories.map((c) => c.toMap()).toList());
    _categoriesController.add(defaultCategories);
  }

  // Helper methods

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Clear all bookmarks and categories
  Future<void> clearAll() async {
    try {
      final box = await Hive.openBox(boxes.Boxes.bookmarks);
      await box.clear();
      
      _bookmarksController.add([]);
      _categoriesController.add([]);
      
      if (kDebugMode) {
        print('All bookmarks and categories cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing bookmarks: $e');
      }
      rethrow;
    }
  }

  void dispose() {
    _bookmarksController.close();
    _categoriesController.close();
  }
}

// Data classes

class Bookmark {
  const Bookmark({
    required this.id,
    required this.verseKey,
    required this.chapterId,
    required this.verseNumber,
    required this.createdAt,
    required this.updatedAt,
    this.categoryId,
    this.note,
    this.tags = const [],
    this.customTitle,
  });

  final String id;
  final String verseKey;
  final int chapterId;
  final int verseNumber;
  final String? categoryId;
  final String? note;
  final List<String> tags;
  final String? customTitle;
  final DateTime createdAt;
  final DateTime updatedAt;

  Bookmark copyWith({
    String? id,
    String? verseKey,
    int? chapterId,
    int? verseNumber,
    String? categoryId,
    String? note,
    List<String>? tags,
    String? customTitle,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Bookmark(
      id: id ?? this.id,
      verseKey: verseKey ?? this.verseKey,
      chapterId: chapterId ?? this.chapterId,
      verseNumber: verseNumber ?? this.verseNumber,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      tags: tags ?? this.tags,
      customTitle: customTitle ?? this.customTitle,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'verseKey': verseKey,
      'chapterId': chapterId,
      'verseNumber': verseNumber,
      'categoryId': categoryId,
      'note': note,
      'tags': tags,
      'customTitle': customTitle,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Bookmark.fromMap(Map<String, dynamic> map) {
    return Bookmark(
      id: map['id'] ?? '',
      verseKey: map['verseKey'] ?? '',
      chapterId: map['chapterId'] ?? 0,
      verseNumber: map['verseNumber'] ?? 0,
      categoryId: map['categoryId'],
      note: map['note'],
      tags: List<String>.from(map['tags'] ?? []),
      customTitle: map['customTitle'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }
}

class BookmarkCategory {
  const BookmarkCategory({
    required this.id,
    required this.name,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.icon,
  });

  final String id;
  final String name;
  final String? description;
  final int color;
  final String? icon;
  final DateTime createdAt;
  final DateTime updatedAt;

  BookmarkCategory copyWith({
    String? id,
    String? name,
    String? description,
    int? color,
    String? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookmarkCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
      'icon': icon,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory BookmarkCategory.fromMap(Map<String, dynamic> map) {
    return BookmarkCategory(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'],
      color: map['color'] ?? 0xFF6200EE,
      icon: map['icon'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }
}

class BookmarkStats {
  const BookmarkStats({
    required this.totalBookmarks,
    required this.totalCategories,
    required this.totalNotes,
    required this.chapterCounts,
    required this.tagCounts,
    this.oldestBookmark,
    this.newestBookmark,
  });

  final int totalBookmarks;
  final int totalCategories;
  final int totalNotes;
  final Map<int, int> chapterCounts;
  final Map<String, int> tagCounts;
  final DateTime? oldestBookmark;
  final DateTime? newestBookmark;
}
