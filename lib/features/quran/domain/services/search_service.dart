import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/dto/verse_dto.dart';
import '../../data/dto/chapter_dto.dart';
import '../../data/repo/quran_repository.dart';
import '../../../../core/storage/hive_boxes.dart' as boxes;

/// Advanced search service for Quran content
/// Supports searching verses, translations, chapters, and topics
class QuranSearchService {
  QuranSearchService(this._quranRepo);
  
  final QuranRepository _quranRepo;
  
  // Search cache to improve performance
  Map<String, List<SearchResult>> _searchCache = {};
  final int _maxCacheSize = 100;

  /// Search for verses by text content
  Future<List<SearchResult>> searchVerses({
    required String query,
    List<int>? chapterIds,
    List<int>? translationIds,
    SearchScope scope = SearchScope.all,
    int limit = 50,
  }) async {
    if (query.trim().isEmpty) return [];

    final cacheKey = _generateCacheKey(query, chapterIds, translationIds, scope);
    if (_searchCache.containsKey(cacheKey)) {
      return _searchCache[cacheKey]!;
    }

    final results = <SearchResult>[];
    
    try {
      // Search in different scopes
      switch (scope) {
        case SearchScope.arabic:
          results.addAll(await _searchArabicText(query, chapterIds, limit));
          break;
        case SearchScope.translation:
          results.addAll(await _searchTranslationText(query, chapterIds, translationIds, limit));
          break;
        case SearchScope.all:
          results.addAll(await _searchArabicText(query, chapterIds, limit ~/ 2));
          results.addAll(await _searchTranslationText(query, chapterIds, translationIds, limit ~/ 2));
          break;
      }

      // Sort by relevance
      results.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
      
      // Limit results
      final limitedResults = results.take(limit).toList();
      
      // Cache results
      _cacheResults(cacheKey, limitedResults);
      
      return limitedResults;
    } catch (e) {
      if (kDebugMode) {
        print('Search error: $e');
      }
      return [];
    }
  }

  /// Search for chapters by name
  Future<List<ChapterSearchResult>> searchChapters(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final chapters = await _quranRepo.getChapters();
      final results = <ChapterSearchResult>[];
      
      final queryLower = query.toLowerCase();
      final queryArabic = query.trim();

      for (final chapter in chapters) {
        double score = 0.0;
        List<String> matchedFields = [];

        // Search in English name
        if (chapter.nameSimple.toLowerCase().contains(queryLower)) {
          score += chapter.nameSimple.toLowerCase() == queryLower ? 100 : 80;
          matchedFields.add('English name');
        }

        // Search in Arabic name
        if (chapter.nameArabic.contains(queryArabic)) {
          score += chapter.nameArabic == queryArabic ? 100 : 80;
          matchedFields.add('Arabic name');
        }

        // Search by chapter number
        if (chapter.id.toString() == query.trim()) {
          score += 100;
          matchedFields.add('Chapter number');
        }

        // Partial matches
        if (chapter.nameSimple.toLowerCase().startsWith(queryLower)) {
          score += 60;
        }

        if (score > 0) {
          results.add(ChapterSearchResult(
            chapter: chapter,
            matchedFields: matchedFields,
            relevanceScore: score,
          ));
        }
      }

      // Sort by relevance
      results.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
      
      return results;
    } catch (e) {
      if (kDebugMode) {
        print('Chapter search error: $e');
      }
      return [];
    }
  }

  /// Search for verses by reference (e.g., "2:255", "Al-Baqarah 255")
  Future<List<VerseReferenceResult>> searchByReference(String query) async {
    if (query.trim().isEmpty) return [];

    final results = <VerseReferenceResult>[];
    
    try {
      // Parse different reference formats
      final references = _parseReferences(query);
      
      for (final ref in references) {
        final verse = await _getVerseByReference(ref.chapterId, ref.verseNumber);
        if (verse != null) {
          results.add(VerseReferenceResult(
            verse: verse,
            reference: ref,
            matchType: ref.matchType,
          ));
        }
      }
      
      return results;
    } catch (e) {
      if (kDebugMode) {
        print('Reference search error: $e');
      }
      return [];
    }
  }

  /// Search with advanced filters and options
  Future<SearchResults> advancedSearch({
    required String query,
    SearchFilters? filters,
    SearchOptions? options,
  }) async {
    final effectiveFilters = filters ?? SearchFilters();
    final effectiveOptions = options ?? SearchOptions();
    
    final results = SearchResults(
      query: query,
      filters: effectiveFilters,
      options: effectiveOptions,
    );

    if (query.trim().isEmpty) {
      return results;
    }

    try {
      // Search verses
      if (effectiveFilters.includeVerses) {
        final verseResults = await searchVerses(
          query: query,
          chapterIds: effectiveFilters.chapterIds,
          translationIds: effectiveFilters.translationIds,
          scope: effectiveFilters.scope,
          limit: effectiveOptions.maxResults,
        );
        results.verses.addAll(verseResults);
      }

      // Search chapters
      if (effectiveFilters.includeChapters) {
        final chapterResults = await searchChapters(query);
        results.chapters.addAll(chapterResults);
      }

      // Search by reference
      if (effectiveFilters.includeReferences) {
        final referenceResults = await searchByReference(query);
        results.references.addAll(referenceResults);
      }

      // Apply additional filtering and sorting
      _applyFinalFiltering(results, effectiveFilters, effectiveOptions);
      
      return results;
    } catch (e) {
      if (kDebugMode) {
        print('Advanced search error: $e');
      }
      return results;
    }
  }

  /// Get search suggestions based on query
  Future<List<SearchSuggestion>> getSearchSuggestions(String query) async {
    if (query.trim().isEmpty) return [];

    final suggestions = <SearchSuggestion>[];
    
    try {
      // Chapter name suggestions
      final chapters = await _quranRepo.getChapters();
      final queryLower = query.toLowerCase();
      
      for (final chapter in chapters) {
        if (chapter.nameSimple.toLowerCase().startsWith(queryLower)) {
          suggestions.add(SearchSuggestion(
            text: chapter.nameSimple,
            type: SuggestionType.chapter,
            data: chapter,
          ));
        }
      }

      // Common search terms (could be loaded from a predefined list)
      final commonTerms = _getCommonSearchTerms();
      for (final term in commonTerms) {
        if (term.toLowerCase().startsWith(queryLower)) {
          suggestions.add(SearchSuggestion(
            text: term,
            type: SuggestionType.topic,
            data: term,
          ));
        }
      }

      // Verse reference suggestions
      if (RegExp(r'^\d+:?\d*$').hasMatch(query)) {
        suggestions.add(SearchSuggestion(
          text: 'Search verse $query',
          type: SuggestionType.reference,
          data: query,
        ));
      }

      return suggestions.take(10).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Suggestions error: $e');
      }
      return [];
    }
  }

  /// Save search to history
  Future<void> saveSearchToHistory(String query) async {
    try {
      final box = await Hive.openBox(boxes.Boxes.searchHistory);
      final history = box.get('searches', defaultValue: <String>[]) as List;
      
      // Remove if already exists
      history.remove(query);
      
      // Add to beginning
      history.insert(0, query);
      
      // Keep only last 50 searches
      if (history.length > 50) {
        history.removeRange(50, history.length);
      }
      
      await box.put('searches', history);
    } catch (e) {
      if (kDebugMode) {
        print('Save search history error: $e');
      }
    }
  }

  /// Get search history
  Future<List<String>> getSearchHistory() async {
    try {
      final box = await Hive.openBox(boxes.Boxes.searchHistory);
      final history = box.get('searches', defaultValue: <String>[]) as List;
      return history.cast<String>();
    } catch (e) {
      if (kDebugMode) {
        print('Get search history error: $e');
      }
      return [];
    }
  }

  /// Clear search history
  Future<void> clearSearchHistory() async {
    try {
      final box = await Hive.openBox(boxes.Boxes.searchHistory);
      await box.delete('searches');
    } catch (e) {
      if (kDebugMode) {
        print('Clear search history error: $e');
      }
    }
  }

  // Private methods

  Future<List<SearchResult>> _searchArabicText(
    String query,
    List<int>? chapterIds,
    int limit,
  ) async {
    final results = <SearchResult>[];
    
    try {
      // Check offline cache first
      final cachedResults = await _searchInOfflineCache(
        query, 
        chapterIds, 
        SearchScope.arabic,
      );
      
      if (cachedResults.isNotEmpty) {
        for (final verse in cachedResults.take(limit)) {
          // Calculate relevance based on Arabic text matching
          final relevance = _calculateArabicRelevance(query, verse);
          if (relevance > 0) {
            results.add(SearchResult(
              verse: verse,
              matchedText: _extractMatchingText(verse.textUthmani, query) ?? verse.textUthmani,
              relevanceScore: relevance,
            ));
          }
        }
      } else {
        // Fall back to API search if no offline cache
        final apiResults = await _searchVersesFromAPI(
          query, 
          chapterIds, 
          SearchScope.arabic,
          limit,
        );
        results.addAll(apiResults);
      }
      
      // Sort by relevance
      results.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
      
    } catch (e) {
      if (kDebugMode) {
        print('Arabic search error: $e');
      }
    }
    
    return results.take(limit).toList();
  }

  Future<List<SearchResult>> _searchTranslationText(
    String query,
    List<int>? chapterIds,
    List<int>? translationIds,
    int limit,
  ) async {
    final results = <SearchResult>[];
    
    try {
      // Check offline cache first
      final cachedResults = await _searchInOfflineCache(
        query, 
        chapterIds, 
        SearchScope.translation,
        translationIds: translationIds,
      );
      
      if (cachedResults.isNotEmpty) {
        for (final verse in cachedResults.take(limit)) {
          // Search in translation text
          final relevance = _calculateTranslationRelevance(query, verse, translationIds);
          if (relevance > 0) {
            final matchingTranslation = _findMatchingTranslation(verse, query, translationIds);
            results.add(SearchResult(
              verse: verse,
              matchedText: matchingTranslation != null 
                  ? (_extractMatchingText(matchingTranslation.text, query) ?? matchingTranslation.text)
                  : verse.textUthmani,
              relevanceScore: relevance,
            ));
          }
        }
      } else {
        // Fall back to API search if no offline cache
        final apiResults = await _searchVersesFromAPI(
          query, 
          chapterIds, 
          SearchScope.translation,
          limit,
          translationIds: translationIds,
        );
        results.addAll(apiResults);
      }
      
      // Sort by relevance
      results.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
      
    } catch (e) {
      if (kDebugMode) {
        print('Translation search error: $e');
      }
    }
    
    return results.take(limit).toList();
  }

  List<VerseReference> _parseReferences(String query) {
    final references = <VerseReference>[];
    
    // Parse "2:255" format
    final colonMatch = RegExp(r'^(\d+):(\d+)$').firstMatch(query.trim());
    if (colonMatch != null) {
      references.add(VerseReference(
        chapterId: int.parse(colonMatch.group(1)!),
        verseNumber: int.parse(colonMatch.group(2)!),
        matchType: 'exact_reference',
      ));
    }
    
    // Parse "Surah 2 verse 255" format
    final verbalMatch = RegExp(r'(?:surah|chapter)\s*(\d+)\s*(?:verse|ayah)\s*(\d+)', 
        caseSensitive: false).firstMatch(query);
    if (verbalMatch != null) {
      references.add(VerseReference(
        chapterId: int.parse(verbalMatch.group(1)!),
        verseNumber: int.parse(verbalMatch.group(2)!),
        matchType: 'verbal_reference',
      ));
    }
    
    return references;
  }

  Future<VerseDto?> _getVerseByReference(int chapterId, int verseNumber) async {
    try {
      // TODO: Implement verse fetching by reference
      // This would involve getting the specific verse from cache or API
      return null;
    } catch (e) {
      return null;
    }
  }

  List<String> _getCommonSearchTerms() {
    return [
      'prayer', 'salat', 'fasting', 'hajj', 'zakat', 'charity',
      'paradise', 'hell', 'angels', 'prophets', 'Muhammad',
      'Allah', 'God', 'mercy', 'forgiveness', 'guidance',
      'faith', 'belief', 'righteous', 'patience', 'gratitude',
      'family', 'parents', 'children', 'marriage', 'divorce',
      'knowledge', 'wisdom', 'creation', 'judgment', 'afterlife',
    ];
  }

  String _generateCacheKey(
    String query,
    List<int>? chapterIds,
    List<int>? translationIds,
    SearchScope scope,
  ) {
    return '${query}_${chapterIds?.join(',') ?? 'all'}_${translationIds?.join(',') ?? 'all'}_${scope.name}';
  }

  void _cacheResults(String key, List<SearchResult> results) {
    if (_searchCache.length >= _maxCacheSize) {
      // Remove oldest entries
      final keys = _searchCache.keys.toList();
      _searchCache.remove(keys.first);
    }
    _searchCache[key] = results;
  }

  void _applyFinalFiltering(
    SearchResults results,
    SearchFilters filters,
    SearchOptions options,
  ) {
    // Apply relevance threshold
    results.verses.removeWhere((r) => r.relevanceScore < options.minRelevanceScore);
    results.chapters.removeWhere((r) => r.relevanceScore < options.minRelevanceScore);
    
    // Apply result limits
    if (results.verses.length > options.maxResults) {
      final limitedVerses = results.verses.take(options.maxResults).toList();
      results.verses.clear();
      results.verses.addAll(limitedVerses);
    }
    if (results.chapters.length > options.maxResults) {
      final limitedChapters = results.chapters.take(options.maxResults).toList();
      results.chapters.clear();
      results.chapters.addAll(limitedChapters);
    }
  }
}

// Data classes

enum SearchScope {
  all,
  arabic,
  translation,
}

enum MatchType {
  arabicText,
  translation,
  reference,
}

enum SuggestionType {
  chapter,
  verse,
  topic,
  reference,
}

class SearchResult {
  const SearchResult({
    required this.verse,
    required this.matchedText,
    required this.relevanceScore,
    this.highlightRanges = const [],
  });

  final VerseDto verse;
  final String matchedText;
  final double relevanceScore;
  final List<TextRange> highlightRanges;
}

class ChapterSearchResult {
  const ChapterSearchResult({
    required this.chapter,
    required this.matchedFields,
    required this.relevanceScore,
  });

  final ChapterDto chapter;
  final List<String> matchedFields;
  final double relevanceScore;
}

class VerseReferenceResult {
  const VerseReferenceResult({
    required this.verse,
    required this.reference,
    required this.matchType,
  });

  final VerseDto verse;
  final VerseReference reference;
  final String matchType;
}

class VerseReference {
  const VerseReference({
    required this.chapterId,
    required this.verseNumber,
    required this.matchType,
  });

  final int chapterId;
  final int verseNumber;
  final String matchType;
}

class SearchFilters {
  const SearchFilters({
    this.chapterIds,
    this.translationIds,
    this.scope = SearchScope.all,
    this.includeVerses = true,
    this.includeChapters = true,
    this.includeReferences = true,
  });

  final List<int>? chapterIds;
  final List<int>? translationIds;
  final SearchScope scope;
  final bool includeVerses;
  final bool includeChapters;
  final bool includeReferences;
}

class SearchOptions {
  const SearchOptions({
    this.maxResults = 50,
    this.minRelevanceScore = 0.1,
    this.highlightMatches = true,
  });

  final int maxResults;
  final double minRelevanceScore;
  final bool highlightMatches;
}

class SearchResults {
  SearchResults({
    required this.query,
    required this.filters,
    required this.options,
  });

  final String query;
  final SearchFilters filters;
  final SearchOptions options;
  final List<SearchResult> verses = [];
  final List<ChapterSearchResult> chapters = [];
  final List<VerseReferenceResult> references = [];

  int get totalResults => verses.length + chapters.length + references.length;
  bool get hasResults => totalResults > 0;
}

class SearchSuggestion {
  const SearchSuggestion({
    required this.text,
    required this.type,
    this.data,
  });

  final String text;
  final SuggestionType type;
  final dynamic data;
}

class TextRange {
  const TextRange({
    required this.start,
    required this.end,
  });

  final int start;
  final int end;
}

// Private helper methods for search implementation

extension _QuranSearchServiceHelpers on QuranSearchService {
  /// Search in offline cache using Hive storage
  Future<List<VerseDto>> _searchInOfflineCache(
    String query, 
    List<int>? chapterIds, 
    SearchScope scope, {
    List<int>? translationIds,
  }) async {
    try {
      final vBox = await Hive.openBox(boxes.Boxes.verses);
      final results = <VerseDto>[];
      final queryLower = query.toLowerCase();
      
      // Search through cached verses
      for (final key in vBox.keys) {
        final verseData = vBox.get(key);
        if (verseData is Map) {
          try {
            final verse = VerseDto.fromJson(Map<String, dynamic>.from(verseData));
            
            // Filter by chapter if specified
            if (chapterIds != null) {
              final chapterId = int.tryParse(verse.verseKey.split(':').first) ?? 0;
              if (!chapterIds.contains(chapterId)) continue;
            }
            
            bool matches = false;
            
            if (scope == SearchScope.arabic || scope == SearchScope.all) {
              // Search in Arabic text (remove diacritics for better matching)
              final arabicText = _removeDiacritics(verse.textUthmani).toLowerCase();
              final searchQuery = _removeDiacritics(query).toLowerCase();
              if (arabicText.contains(searchQuery)) {
                matches = true;
              }
            }
            
            if ((scope == SearchScope.translation || scope == SearchScope.all) && !matches) {
              // Search in translations
              for (final translation in verse.translations) {
                if (translationIds == null || translationIds.contains(translation.resourceId)) {
                  if (translation.text.toLowerCase().contains(queryLower)) {
                    matches = true;
                    break;
                  }
                }
              }
            }
            
            if (matches) {
              results.add(verse);
            }
            
          } catch (e) {
            // Skip invalid verse data
          }
        }
        
        // Limit search to prevent memory issues
        if (results.length >= 100) break;
      }
      
      return results;
    } catch (e) {
      if (kDebugMode) {
        print('Offline cache search error: $e');
      }
      return [];
    }
  }

  /// Calculate relevance score for Arabic text matches
  double _calculateArabicRelevance(String query, VerseDto verse) {
    final arabicText = _removeDiacritics(verse.textUthmani).toLowerCase();
    final searchQuery = _removeDiacritics(query).toLowerCase();
    
    if (arabicText == searchQuery) return 100.0; // Exact match
    if (arabicText.startsWith(searchQuery)) return 90.0; // Starts with
    if (arabicText.contains(' $searchQuery ')) return 80.0; // Whole word
    if (arabicText.contains(searchQuery)) return 60.0; // Contains
    
    return 0.0;
  }

  /// Calculate relevance score for translation matches
  double _calculateTranslationRelevance(String query, VerseDto verse, List<int>? translationIds) {
    double maxRelevance = 0.0;
    final queryLower = query.toLowerCase();
    
    for (final translation in verse.translations) {
      if (translationIds == null || translationIds.contains(translation.resourceId)) {
        final text = translation.text.toLowerCase();
        
        double relevance = 0.0;
        if (text == queryLower) relevance = 100.0; // Exact match
        else if (text.startsWith(queryLower)) relevance = 90.0; // Starts with
        else if (text.contains(' $queryLower ')) relevance = 80.0; // Whole word
        else if (text.contains(queryLower)) relevance = 60.0; // Contains
        
        maxRelevance = math.max(maxRelevance, relevance);
      }
    }
    
    return maxRelevance;
  }

  /// Find the translation that matches the search query
  TranslationDto? _findMatchingTranslation(VerseDto verse, String query, List<int>? translationIds) {
    final queryLower = query.toLowerCase();
    
    for (final translation in verse.translations) {
      if (translationIds == null || translationIds.contains(translation.resourceId)) {
        if (translation.text.toLowerCase().contains(queryLower)) {
          return translation;
        }
      }
    }
    
    return null;
  }

  /// Extract text with highlighted matches
  String? _extractMatchingText(String text, String query) {
    final queryLower = query.toLowerCase();
    final textLower = text.toLowerCase();
    final index = textLower.indexOf(queryLower);
    
    if (index == -1) return null;
    
    // Extract surrounding context
    const contextLength = 50;
    final start = math.max(0, index - contextLength);
    final end = math.min(text.length, index + query.length + contextLength);
    
    String excerpt = text.substring(start, end);
    if (start > 0) excerpt = '...$excerpt';
    if (end < text.length) excerpt = '$excerpt...';
    
    return excerpt;
  }

  /// Remove Arabic diacritics for better search matching
  String _removeDiacritics(String text) {
    // Remove common Arabic diacritics
    return text
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Search verses from API (fallback when offline cache is empty)
  Future<List<SearchResult>> _searchVersesFromAPI(
    String query,
    List<int>? chapterIds,
    SearchScope scope,
    int limit, {
    List<int>? translationIds,
  }) async {
    try {
      // This would call the actual search API
      // For now, return empty results
      // TODO: Implement API search as fallback
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('API search error: $e');
      }
      return [];
    }
  }
}
