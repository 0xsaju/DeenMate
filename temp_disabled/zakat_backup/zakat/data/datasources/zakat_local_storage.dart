import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/zakat_calculation.dart';

/// Local storage service for Zakat calculations using Hive
/// Provides offline capability and data persistence
class ZakatLocalStorage {
  static const String _calculationsBoxName = 'zakat_calculations';
  static const String _metalPricesBoxName = 'metal_prices_cache';
  static const String _userPreferencesKey = 'zakat_user_preferences';
  static const String _lastSyncKey = 'zakat_last_sync';

  Box<Map>? _calculationsBox;
  Box<Map>? _metalPricesBox;
  SharedPreferences? _prefs;

  /// Initialize Hive boxes for local storage
  Future<void> initialize() async {
    try {
      // Initialize Hive
      await Hive.initFlutter();
      
      // Open boxes
      _calculationsBox = await Hive.openBox<Map>(_calculationsBoxName);
      _metalPricesBox = await Hive.openBox<Map>(_metalPricesBoxName);
      
      // Initialize SharedPreferences
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      throw Failure.databaseFailure(
        operation: 'initialize',
        message: 'Failed to initialize local storage: ${e.toString()}',
      );
    }
  }

  /// Save Zakat calculation to local storage
  Future<void> saveCalculation(ZakatCalculation calculation) async {
    try {
      await _ensureInitialized();
      
      final calculationJson = calculation.toJson();
      await _calculationsBox!.put(calculation.id, calculationJson);
      
      // Update last sync timestamp
      await _updateLastSync();
    } catch (e) {
      throw Failure.databaseFailure(
        operation: 'save_calculation',
        message: 'Failed to save Zakat calculation: ${e.toString()}',
      );
    }
  }

  /// Get all Zakat calculations for a user
  Future<List<ZakatCalculation>> getUserCalculations(String userId) async {
    try {
      await _ensureInitialized();
      
      final calculations = <ZakatCalculation>[];
      
      for (final entry in _calculationsBox!.values) {
        try {
          final calculationMap = Map<String, dynamic>.from(entry);
          final calculation = ZakatCalculation.fromJson(calculationMap);
          
          if (calculation.userId == userId) {
            calculations.add(calculation);
          }
        } catch (e) {
          // Skip corrupted entries
          continue;
        }
      }
      
      // Sort by date (newest first)
      calculations.sort((a, b) => b.calculationDate.compareTo(a.calculationDate));
      
      return calculations;
    } catch (e) {
      throw Failure.databaseFailure(
        operation: 'get_user_calculations',
        message: 'Failed to retrieve calculations: ${e.toString()}',
      );
    }
  }

  /// Get specific calculation by ID
  Future<ZakatCalculation?> getCalculationById(String calculationId) async {
    try {
      await _ensureInitialized();
      
      final calculationMap = _calculationsBox!.get(calculationId);
      if (calculationMap == null) return null;
      
      return ZakatCalculation.fromJson(Map<String, dynamic>.from(calculationMap));
    } catch (e) {
      throw Failure.databaseFailure(
        operation: 'get_calculation_by_id',
        message: 'Failed to retrieve calculation: ${e.toString()}',
      );
    }
  }

  /// Update existing calculation
  Future<void> updateCalculation(ZakatCalculation calculation) async {
    try {
      await _ensureInitialized();
      
      final calculationJson = calculation.toJson();
      await _calculationsBox!.put(calculation.id, calculationJson);
      
      await _updateLastSync();
    } catch (e) {
      throw Failure.databaseFailure(
        operation: 'update_calculation',
        message: 'Failed to update calculation: ${e.toString()}',
      );
    }
  }

  /// Delete calculation
  Future<void> deleteCalculation(String calculationId) async {
    try {
      await _ensureInitialized();
      
      await _calculationsBox!.delete(calculationId);
      await _updateLastSync();
    } catch (e) {
      throw Failure.databaseFailure(
        operation: 'delete_calculation',
        message: 'Failed to delete calculation: ${e.toString()}',
      );
    }
  }

  /// Cache metal prices for offline use
  Future<void> cacheMetalPrices({
    required String currency,
    required double goldPrice,
    required double silverPrice,
  }) async {
    try {
      await _ensureInitialized();
      
      final priceData = {
        'gold_price': goldPrice,
        'silver_price': silverPrice,
        'currency': currency,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      await _metalPricesBox!.put(currency, priceData);
    } catch (e) {
      throw Failure.cacheFailure(
        message: 'Failed to cache metal prices: ${e.toString()}',
      );
    }
  }

  /// Get cached metal prices
  Future<Map<String, double>?> getCachedMetalPrices(String currency) async {
    try {
      await _ensureInitialized();
      
      final cachedData = _metalPricesBox!.get(currency);
      if (cachedData == null) return null;
      
      final priceMap = Map<String, dynamic>.from(cachedData);
      final timestamp = DateTime.parse(priceMap['timestamp']);
      
      // Check if cache is still valid (24 hours)
      final cacheAge = DateTime.now().difference(timestamp);
      if (cacheAge.inHours > 24) {
        await _metalPricesBox!.delete(currency);
        return null;
      }
      
      return {
        'gold': (priceMap['gold_price'] as num).toDouble(),
        'silver': (priceMap['silver_price'] as num).toDouble(),
      };
    } catch (e) {
      return null; // Return null if cache read fails
    }
  }

  /// Save user preferences for Zakat calculations
  Future<void> saveUserPreferences(Map<String, dynamic> preferences) async {
    try {
      await _ensureInitialized();
      
      final preferencesJson = jsonEncode(preferences);
      await _prefs!.setString(_userPreferencesKey, preferencesJson);
    } catch (e) {
      throw Failure.databaseFailure(
        operation: 'save_preferences',
        message: 'Failed to save user preferences: ${e.toString()}',
      );
    }
  }

  /// Get user preferences
  Future<Map<String, dynamic>> getUserPreferences() async {
    try {
      await _ensureInitialized();
      
      final preferencesJson = _prefs!.getString(_userPreferencesKey);
      if (preferencesJson == null) return {};
      
      return Map<String, dynamic>.from(jsonDecode(preferencesJson));
    } catch (e) {
      return {}; // Return empty map if preferences can't be loaded
    }
  }

  /// Get calculations within date range
  Future<List<ZakatCalculation>> getCalculationsInRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final allCalculations = await getUserCalculations(userId);
      
      return allCalculations.where((calculation) {
        return calculation.calculationDate.isAfter(startDate) &&
               calculation.calculationDate.isBefore(endDate);
      }).toList();
    } catch (e) {
      throw Failure.databaseFailure(
        operation: 'get_calculations_in_range',
        message: 'Failed to retrieve calculations in range: ${e.toString()}',
      );
    }
  }

  /// Get calculation statistics
  Future<ZakatStatistics> getCalculationStatistics(String userId) async {
    try {
      final calculations = await getUserCalculations(userId);
      
      if (calculations.isEmpty) {
        return const ZakatStatistics(
          totalCalculations: 0,
          totalZakatPaid: 0,
          averageWealth: 0,
        );
      }

      final totalCalculations = calculations.length;
      final totalZakatPaid = calculations
          .where((calc) => calc.isPaid)
          .map((calc) => calc.result.zakatDue)
          .fold(0, (sum, amount) => sum + amount);
      
      final averageWealth = calculations
          .map((calc) => calc.result.zakatableWealth)
          .fold(0, (sum, wealth) => sum + wealth) / totalCalculations;
      
      final lastCalculationDate = calculations.first.calculationDate;

      return ZakatStatistics(
        totalCalculations: totalCalculations,
        totalZakatPaid: totalZakatPaid,
        averageWealth: averageWealth,
        lastCalculationDate: lastCalculationDate,
      );
    } catch (e) {
      throw Failure.databaseFailure(
        operation: 'get_statistics',
        message: 'Failed to calculate statistics: ${e.toString()}',
      );
    }
  }

  /// Export calculations as JSON
  Future<String> exportCalculationsAsJson(String userId) async {
    try {
      final calculations = await getUserCalculations(userId);
      final calculationsJson = calculations.map((calc) => calc.toJson()).toList();
      
      final exportData = {
        'export_date': DateTime.now().toIso8601String(),
        'user_id': userId,
        'calculations': calculationsJson,
      };
      
      return jsonEncode(exportData);
    } catch (e) {
      throw Failure.fileWriteFailure(
        fileName: 'zakat_export.json',
        message: 'Failed to export calculations: ${e.toString()}',
      );
    }
  }

  /// Import calculations from JSON
  Future<void> importCalculationsFromJson(String jsonData) async {
    try {
      await _ensureInitialized();
      
      final importData = jsonDecode(jsonData) as Map<String, dynamic>;
      final calculationsData = importData['calculations'] as List<dynamic>;
      
      for (final calcData in calculationsData) {
        final calculation = ZakatCalculation.fromJson(
          Map<String, dynamic>.from(calcData),
        );
        await saveCalculation(calculation);
      }
      
      await _updateLastSync();
    } catch (e) {
      throw Failure.fileReadFailure(
        fileName: 'import_file',
        message: 'Failed to import calculations: ${e.toString()}',
      );
    }
  }

  /// Clear all data (for reset/logout)
  Future<void> clearAllData() async {
    try {
      await _ensureInitialized();
      
      await _calculationsBox!.clear();
      await _metalPricesBox!.clear();
      await _prefs!.remove(_userPreferencesKey);
      await _prefs!.remove(_lastSyncKey);
    } catch (e) {
      throw Failure.databaseFailure(
        operation: 'clear_data',
        message: 'Failed to clear local data: ${e.toString()}',
      );
    }
  }

  /// Get storage size information
  Future<StorageInfo> getStorageInfo() async {
    try {
      await _ensureInitialized();
      
      final calculationsCount = _calculationsBox!.length;
      final metalPricesCount = _metalPricesBox!.length;
      
      // Estimate storage size (rough calculation)
      final estimatedSize = (calculationsCount * 2048) + (metalPricesCount * 512);
      
      return StorageInfo(
        calculationsCount: calculationsCount,
        cachedPricesCount: metalPricesCount,
        estimatedSizeBytes: estimatedSize,
      );
    } catch (e) {
      return const StorageInfo(
        calculationsCount: 0,
        cachedPricesCount: 0,
        estimatedSizeBytes: 0,
      );
    }
  }

  /// Ensure storage is initialized
  Future<void> _ensureInitialized() async {
    if (_calculationsBox == null || _metalPricesBox == null || _prefs == null) {
      await initialize();
    }
  }

  /// Update last sync timestamp
  Future<void> _updateLastSync() async {
    await _prefs?.setString(_lastSyncKey, DateTime.now().toIso8601String());
  }

  /// Get last sync timestamp
  Future<DateTime?> getLastSync() async {
    try {
      await _ensureInitialized();
      
      final lastSyncString = _prefs!.getString(_lastSyncKey);
      if (lastSyncString == null) return null;
      
      return DateTime.parse(lastSyncString);
    } catch (e) {
      return null;
    }
  }

  /// Close storage boxes
  Future<void> dispose() async {
    await _calculationsBox?.close();
    await _metalPricesBox?.close();
  }

  double getTotalZakatPaid() {
    return _calculationsBox!.values
        .map((payment) => payment['amount'] as double? ?? 0.0)
        .fold(0.0, (sum, amount) => sum + amount);
  }

  double getAverageZakatAmount() {
    final totalCalculations = _calculationsBox!.length;
    if (totalCalculations == 0) return 0.0;
    
    return _calculationsBox!.values
        .map((calc) => calc['zakatAmount'] as double? ?? 0.0)
        .fold(0.0, (sum, wealth) => sum + wealth) / totalCalculations;
  }

  ZakatSummary getZakatSummary() {
    final totalZakatPaid = getTotalZakatPaid();
    
    return ZakatSummary(
      totalCalculations: _calculationsBox!.length,
      totalZakatDue: getAverageZakatAmount(),
      totalZakatPaid: totalZakatPaid,
      lastCalculationDate: getLastSync(),
    );
  }
}

/// Statistics for user's Zakat calculations
class ZakatStatistics {

  const ZakatStatistics({
    required this.totalCalculations,
    required this.totalZakatPaid,
    required this.averageWealth,
    this.lastCalculationDate,
  });
  final int totalCalculations;
  final double totalZakatPaid;
  final double averageWealth;
  final DateTime? lastCalculationDate;
}

/// Storage information for diagnostics
class StorageInfo {

  const StorageInfo({
    required this.calculationsCount,
    required this.cachedPricesCount,
    required this.estimatedSizeBytes,
  });
  final int calculationsCount;
  final int cachedPricesCount;
  final int estimatedSizeBytes;

  String get formattedSize {
    if (estimatedSizeBytes < 1024) {
      return '$estimatedSizeBytes B';
    } else if (estimatedSizeBytes < 1024 * 1024) {
      return '${(estimatedSizeBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(estimatedSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}

/// Summary of Zakat calculations
class ZakatSummary {
  const ZakatSummary({
    required this.totalCalculations,
    required this.totalZakatDue,
    required this.totalZakatPaid,
    this.lastCalculationDate,
  });

  final int totalCalculations;
  final double totalZakatDue;
  final double totalZakatPaid;
  final DateTime? lastCalculationDate;
}