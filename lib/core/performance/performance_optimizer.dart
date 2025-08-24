import 'dart:async';
import 'dart:collection';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// High-performance optimization utilities for the Quran app
/// Includes caching, lazy loading, memory management, and background processing
class PerformanceOptimizer {
  static final PerformanceOptimizer _instance = PerformanceOptimizer._internal();
  factory PerformanceOptimizer() => _instance;
  PerformanceOptimizer._internal();

  // LRU Cache for frequently accessed data
  late final LRUCache<String, dynamic> _memoryCache;
  late final LRUCache<String, List<int>> _imageCache;
  
  // Background processing
  final Map<String, Isolate> _activeIsolates = {};
  final Map<String, Completer> _isolateCompleters = {};
  
  // Performance metrics
  final Map<String, PerformanceMetric> _metrics = {};
  
  // Batch operations queue
  final Queue<BatchOperation> _batchQueue = Queue();
  Timer? _batchTimer;
  
  bool _isInitialized = false;

  /// Initialize the performance optimizer
  Future<void> initialize({
    int memoryCacheSize = 100,
    int imageCacheSize = 50,
  }) async {
    if (_isInitialized) return;
    
    _memoryCache = LRUCache<String, dynamic>(memoryCacheSize);
    _imageCache = LRUCache<String, List<int>>(imageCacheSize);
    
    // Start batch processing timer
    _batchTimer = Timer.periodic(
      const Duration(milliseconds: 500),
      (_) => _processBatchQueue(),
    );
    
    _isInitialized = true;
    
    if (kDebugMode) {
      print('PerformanceOptimizer initialized');
    }
  }

  /// Enhanced caching with TTL and compression
  Future<T?> getFromCache<T>(
    String key, {
    Duration? ttl,
    bool useCompression = false,
  }) async {
    // Check memory cache first
    final memoryResult = _memoryCache.get(key);
    if (memoryResult != null) {
      _recordMetric('cache_hit_memory', 1);
      return memoryResult as T?;
    }

    // Check persistent cache
    try {
      final box = await Hive.openBox('performance_cache');
      final cachedData = box.get(key) as Map<String, dynamic>?;
      
      if (cachedData != null) {
        final timestamp = DateTime.fromMillisecondsSinceEpoch(cachedData['timestamp']);
        final isExpired = ttl != null && DateTime.now().difference(timestamp) > ttl;
        
        if (!isExpired) {
          dynamic data = cachedData['data'];
          
          // Decompress if needed
          if (useCompression && cachedData['compressed'] == true) {
            data = await _decompressData(data);
          }
          
          // Store in memory cache for faster access
          _memoryCache.put(key, data);
          _recordMetric('cache_hit_persistent', 1);
          return data as T?;
        } else {
          // Remove expired data
          await box.delete(key);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Cache read error: $e');
      }
    }
    
    _recordMetric('cache_miss', 1);
    return null;
  }

  /// Store data in cache with TTL and optional compression
  Future<void> putInCache<T>(
    String key,
    T data, {
    Duration? ttl,
    bool useCompression = false,
    CachePriority priority = CachePriority.normal,
  }) async {
    // Store in memory cache
    _memoryCache.put(key, data);

    // Store in persistent cache
    try {
      final box = await Hive.openBox('performance_cache');
      
      dynamic dataToStore = data;
      bool isCompressed = false;
      
      // Compress large data
      if (useCompression && _shouldCompress(data)) {
        dataToStore = await _compressData(data);
        isCompressed = true;
      }
      
      await box.put(key, {
        'data': dataToStore,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'compressed': isCompressed,
        'priority': priority.index,
      });
      
      _recordMetric('cache_write', 1);
    } catch (e) {
      if (kDebugMode) {
        print('Cache write error: $e');
      }
    }
  }

  /// Lazy loading with automatic pagination
  Stream<List<T>> lazyLoad<T>({
    required Future<List<T>> Function(int offset, int limit) loader,
    int pageSize = 20,
    int preloadThreshold = 5,
    String? cacheKey,
  }) async* {
    final List<T> allItems = [];
    int currentOffset = 0;
    bool hasMore = true;
    
    while (hasMore) {
      // Check cache first
      List<T>? cachedPage;
      if (cacheKey != null) {
        cachedPage = await getFromCache<List<T>>('${cacheKey}_$currentOffset');
      }
      
      List<T> pageItems;
      if (cachedPage != null) {
        pageItems = cachedPage;
      } else {
        final stopwatch = Stopwatch()..start();
        pageItems = await loader(currentOffset, pageSize);
        stopwatch.stop();
        
        _recordMetric('lazy_load_time', stopwatch.elapsedMilliseconds.toDouble());
        
        // Cache the page
        if (cacheKey != null && pageItems.isNotEmpty) {
          await putInCache('${cacheKey}_$currentOffset', pageItems, 
            ttl: const Duration(minutes: 30));
        }
      }
      
      if (pageItems.isEmpty || pageItems.length < pageSize) {
        hasMore = false;
      }
      
      allItems.addAll(pageItems);
      yield List.from(allItems);
      
      currentOffset += pageSize;
      
      // Add delay to prevent UI blocking
      if (hasMore) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
    }
  }

  /// Background data processing using isolates
  Future<T> processInBackground<T>({
    required String taskId,
    required Map<String, dynamic> data,
    required String Function(Map<String, dynamic>) taskFunction,
  }) async {
    if (_activeIsolates.containsKey(taskId)) {
      // Return existing task result
      return await _isolateCompleters[taskId]!.future as T;
    }

    final completer = Completer<T>();
    _isolateCompleters[taskId] = completer;

    try {
      final receivePort = ReceivePort();
      
      final isolate = await Isolate.spawn(
        _isolateWorker,
        {
          'sendPort': receivePort.sendPort,
          'taskFunction': taskFunction,
          'data': data,
        },
      );
      
      _activeIsolates[taskId] = isolate;
      
      receivePort.listen((message) {
        if (message is Map<String, dynamic>) {
          if (message['error'] != null) {
            completer.completeError(message['error']);
          } else {
            completer.complete(message['result'] as T);
          }
        }
        
        // Cleanup
        isolate.kill();
        receivePort.close();
        _activeIsolates.remove(taskId);
        _isolateCompleters.remove(taskId);
      });
      
      _recordMetric('background_task_started', 1.0);
      return await completer.future;
    } catch (e) {
      _activeIsolates.remove(taskId);
      _isolateCompleters.remove(taskId);
      rethrow;
    }
  }

  /// Batch operations for database efficiency
  void addToBatch(BatchOperation operation) {
    _batchQueue.add(operation);
    
    // If queue is getting large, process immediately
    if (_batchQueue.length >= 50) {
      _processBatchQueue();
    }
  }

  /// Memory management and cleanup
  Future<void> cleanupMemory({
    bool aggressive = false,
  }) async {
    _recordMetric('memory_cleanup_started', 1);
    
    // Clear memory caches
    if (aggressive) {
      _memoryCache.clear();
      _imageCache.clear();
    } else {
      // Remove least recently used items
      _memoryCache.evictLRU(percent: 0.3);
      _imageCache.evictLRU(percent: 0.5);
    }
    
    // Clean expired persistent cache entries
    await _cleanupPersistentCache();
    
    // Force garbage collection
    if (aggressive) {
      await SystemChannels.platform.invokeMethod('System.gc');
    }
    
    _recordMetric('memory_cleanup_completed', 1);
    
    if (kDebugMode) {
      print('Memory cleanup completed (aggressive: $aggressive)');
    }
  }

  /// Get cache statistics
  CacheStats getCacheStats() {
    return CacheStats(
      memoryCacheSize: _memoryCache.length,
      memoryCacheCapacity: _memoryCache.capacity,
      imageCacheSize: _imageCache.length,
      imageCacheCapacity: _imageCache.capacity,
      cacheHitRate: _getCacheHitRate(),
      totalCacheWrites: _getMetricValue('cache_write'),
      totalCacheReads: _getMetricValue('cache_hit_memory') + _getMetricValue('cache_hit_persistent'),
    );
  }

  /// Get performance metrics
  Map<String, double> getPerformanceMetrics() {
    return _metrics.map((key, metric) => MapEntry(key, metric.average));
  }

  /// Preload frequently accessed data
  Future<void> preloadData({
    required List<String> keys,
    required Future<dynamic> Function(String key) loader,
  }) async {
    final futures = keys.map((key) async {
      if (!_memoryCache.containsKey(key)) {
        try {
          final data = await loader(key);
          await putInCache(key, data, 
            ttl: const Duration(hours: 1),
            priority: CachePriority.high);
        } catch (e) {
          if (kDebugMode) {
            print('Preload failed for $key: $e');
          }
        }
      }
    });
    
    await Future.wait(futures);
    _recordMetric('preload_completed', keys.length.toDouble());
  }

  /// Optimize image loading and caching
  Future<List<int>?> loadOptimizedImage(
    String imageKey,
    Future<List<int>> Function() loader, {
    int? maxWidth,
    int? maxHeight,
    int quality = 85,
  }) async {
    // Check image cache
    final cached = _imageCache.get(imageKey);
    if (cached != null) {
      return cached;
    }

    // Load and optimize image
    final imageData = await loader();
    
    // TODO: Add image resizing and compression if needed
    // For now, just cache the original data
    _imageCache.put(imageKey, imageData);
    
    return imageData;
  }

  // Private methods

  static void _isolateWorker(Map<String, dynamic> params) {
    final sendPort = params['sendPort'] as SendPort;
    final taskFunction = params['taskFunction'] as String Function(Map<String, dynamic>);
    final data = params['data'] as Map<String, dynamic>;

    try {
      final result = taskFunction(data);
      sendPort.send({'result': result});
    } catch (e) {
      sendPort.send({'error': e.toString()});
    }
  }

  void _processBatchQueue() {
    if (_batchQueue.isEmpty) return;

    final operations = <BatchOperation>[];
    while (_batchQueue.isNotEmpty && operations.length < 20) {
      operations.add(_batchQueue.removeFirst());
    }

    // Group operations by type for efficiency
    final groupedOps = <String, List<BatchOperation>>{};
    for (final op in operations) {
      groupedOps.putIfAbsent(op.type, () => []).add(op);
    }

    // Process each group
    for (final entry in groupedOps.entries) {
      _processBatchGroup(entry.key, entry.value);
    }

    _recordMetric('batch_operations_processed', operations.length.toDouble());
  }

  void _processBatchGroup(String type, List<BatchOperation> operations) {
    // TODO: Implement specific batch processing logic for different operation types
    if (kDebugMode) {
      print('Processing ${operations.length} $type operations');
    }
  }

  Future<void> _cleanupPersistentCache() async {
    try {
      final box = await Hive.openBox('performance_cache');
      final keysToDelete = <String>[];
      
      for (final key in box.keys) {
        final data = box.get(key) as Map<String, dynamic>?;
        if (data != null) {
          final timestamp = DateTime.fromMillisecondsSinceEpoch(data['timestamp']);
          if (DateTime.now().difference(timestamp) > const Duration(days: 7)) {
            keysToDelete.add(key.toString());
          }
        }
      }
      
      for (final key in keysToDelete) {
        await box.delete(key);
      }
      
      if (kDebugMode) {
        print('Cleaned up ${keysToDelete.length} expired cache entries');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Cache cleanup error: $e');
      }
    }
  }

  bool _shouldCompress(dynamic data) {
    if (data is String) {
      return data.length > 1000; // Compress strings over 1KB
    }
    if (data is List) {
      return data.length > 100; // Compress large lists
    }
    return false;
  }

  Future<dynamic> _compressData(dynamic data) async {
    // TODO: Implement data compression (e.g., gzip)
    // For now, return data as-is
    return data;
  }

  Future<dynamic> _decompressData(dynamic data) async {
    // TODO: Implement data decompression
    // For now, return data as-is
    return data;
  }

  void _recordMetric(String name, double value) {
    _metrics.putIfAbsent(name, () => PerformanceMetric(name));
    _metrics[name]!.record(value);
  }

  double _getMetricValue(String name) {
    return _metrics[name]?.total ?? 0.0;
  }

  double _getCacheHitRate() {
    final hits = _getMetricValue('cache_hit_memory') + _getMetricValue('cache_hit_persistent');
    final total = hits + _getMetricValue('cache_miss');
    return total > 0 ? hits / total : 0.0;
  }

  void dispose() {
    _batchTimer?.cancel();
    
    // Kill all active isolates
    for (final isolate in _activeIsolates.values) {
      isolate.kill();
    }
    _activeIsolates.clear();
    _isolateCompleters.clear();
    
    _memoryCache.clear();
    _imageCache.clear();
  }
}

/// LRU Cache implementation
class LRUCache<K, V> {
  LRUCache(this.capacity);

  final int capacity;
  final Map<K, _CacheNode<K, V>> _cache = {};
  _CacheNode<K, V>? _head;
  _CacheNode<K, V>? _tail;

  int get length => _cache.length;

  V? get(K key) {
    final node = _cache[key];
    if (node != null) {
      _moveToHead(node);
      return node.value;
    }
    return null;
  }

  void put(K key, V value) {
    final existingNode = _cache[key];
    if (existingNode != null) {
      existingNode.value = value;
      _moveToHead(existingNode);
    } else {
      final newNode = _CacheNode(key, value);
      _cache[key] = newNode;
      _addToHead(newNode);

      if (_cache.length > capacity) {
        final tail = _removeTail();
        if (tail != null) {
          _cache.remove(tail.key);
        }
      }
    }
  }

  bool containsKey(K key) => _cache.containsKey(key);

  void remove(K key) {
    final node = _cache[key];
    if (node != null) {
      _cache.remove(key);
      _removeNode(node);
    }
  }

  void clear() {
    _cache.clear();
    _head = null;
    _tail = null;
  }

  void evictLRU({double percent = 0.3}) {
    final itemsToRemove = (length * percent).round();
    for (int i = 0; i < itemsToRemove && _tail != null; i++) {
      final tail = _removeTail();
      if (tail != null) {
        _cache.remove(tail.key);
      }
    }
  }

  void _addToHead(_CacheNode<K, V> node) {
    node.prev = null;
    node.next = _head;

    if (_head != null) {
      _head!.prev = node;
    }
    _head = node;

    if (_tail == null) {
      _tail = _head;
    }
  }

  void _removeNode(_CacheNode<K, V> node) {
    if (node.prev != null) {
      node.prev!.next = node.next;
    } else {
      _head = node.next;
    }

    if (node.next != null) {
      node.next!.prev = node.prev;
    } else {
      _tail = node.prev;
    }
  }

  void _moveToHead(_CacheNode<K, V> node) {
    _removeNode(node);
    _addToHead(node);
  }

  _CacheNode<K, V>? _removeTail() {
    final lastNode = _tail;
    if (lastNode != null) {
      _removeNode(lastNode);
    }
    return lastNode;
  }
}

class _CacheNode<K, V> {
  _CacheNode(this.key, this.value);

  final K key;
  V value;
  _CacheNode<K, V>? prev;
  _CacheNode<K, V>? next;
}

/// Performance metric tracking
class PerformanceMetric {
  PerformanceMetric(this.name);

  final String name;
  final List<double> _values = [];
  double _total = 0.0;

  void record(double value) {
    _values.add(value);
    _total += value;
    
    // Keep only recent values to prevent memory growth
    if (_values.length > 100) {
      final removed = _values.removeAt(0);
      _total -= removed;
    }
  }

  double get average => _values.isNotEmpty ? _total / _values.length : 0.0;
  double get total => _total;
  int get count => _values.length;
}

/// Cache priority levels
enum CachePriority {
  low,
  normal,
  high,
  critical,
}

/// Batch operation for database efficiency
class BatchOperation {
  const BatchOperation({
    required this.type,
    required this.data,
    this.priority = CachePriority.normal,
  });

  final String type;
  final Map<String, dynamic> data;
  final CachePriority priority;
}

/// Cache statistics
class CacheStats {
  const CacheStats({
    required this.memoryCacheSize,
    required this.memoryCacheCapacity,
    required this.imageCacheSize,
    required this.imageCacheCapacity,
    required this.cacheHitRate,
    required this.totalCacheWrites,
    required this.totalCacheReads,
  });

  final int memoryCacheSize;
  final int memoryCacheCapacity;
  final int imageCacheSize;
  final int imageCacheCapacity;
  final double cacheHitRate;
  final double totalCacheWrites;
  final double totalCacheReads;

  double get memoryCacheUsage => memoryCacheCapacity > 0 
    ? memoryCacheSize / memoryCacheCapacity
    : 0.0;

  double get imageCacheUsage => imageCacheCapacity > 0 
    ? imageCacheSize / imageCacheCapacity
    : 0.0;
}
