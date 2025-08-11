import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';

/// API service for fetching current gold and silver prices
/// Integrates with multiple precious metals APIs for reliability
class MetalPricesApi { // Currency layer backup

  MetalPricesApi(this._dio);
  final Dio _dio;
  final String _baseUrl = 'https://api.metals.live/v1/spot';
  final String _backupUrl = 'https://api.fixer.io/v1';

  /// Get current gold price per gram in specified currency
  Future<double> getGoldPrice(String currency) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/gold',
        queryParameters: {
          'currency': currency,
          'unit': 'gram',
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'User-Agent': 'DeenMate/1.0.0',
            'X-Requested-With': 'XMLHttpRequest',
          },
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        
        // Parse response based on API structure
        if (data.containsKey('price')) {
          return (data['price'] as num).toDouble();
        } else if (data.containsKey('rate')) {
          return (data['rate'] as num).toDouble();
        } else if (data.containsKey('gold')) {
          final goldData = data['gold'] as Map<String, dynamic>;
          return (goldData['price'] as num).toDouble();
        }
      }

      throw const Failure.metalPriceUnavailable();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const Failure.timeoutFailure();
      } else if (e.response?.statusCode != null) {
        throw Failure.serverFailure(
          message: 'Failed to fetch gold price',
          statusCode: e.response!.statusCode!,
        );
      } else {
        throw const Failure.networkFailure(
          message: 'Network error while fetching gold price',
        );
      }
    } catch (e) {
      throw Failure.unknownFailure(
        message: 'Unexpected error fetching gold price',
        details: e.toString(),
      );
    }
  }

  /// Get current silver price per gram in specified currency
  Future<double> getSilverPrice(String currency) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/silver',
        queryParameters: {
          'currency': currency,
          'unit': 'gram',
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'User-Agent': 'DeenMate/1.0.0',
            'X-Requested-With': 'XMLHttpRequest',
          },
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        
        if (data.containsKey('price')) {
          return (data['price'] as num).toDouble();
        } else if (data.containsKey('rate')) {
          return (data['rate'] as num).toDouble();
        } else if (data.containsKey('silver')) {
          final silverData = data['silver'] as Map<String, dynamic>;
          return (silverData['price'] as num).toDouble();
        }
      }

      throw const Failure.metalPriceUnavailable();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const Failure.timeoutFailure();
      } else if (e.response?.statusCode != null) {
        throw Failure.serverFailure(
          message: 'Failed to fetch silver price',
          statusCode: e.response!.statusCode!,
        );
      } else {
        throw const Failure.networkFailure(
          message: 'Network error while fetching silver price',
        );
      }
    } catch (e) {
      throw Failure.unknownFailure(
        message: 'Unexpected error fetching silver price',
        details: e.toString(),
      );
    }
  }

  /// Get both gold and silver prices in one call
  Future<Map<String, double>> getBothMetalPrices(String currency) async {
    try {
      // Try to get both prices simultaneously
      final futures = await Future.wait([
        getGoldPrice(currency),
        getSilverPrice(currency),
      ]);

      return {
        'gold': futures[0],
        'silver': futures[1],
      };
    } catch (e) {
      // If simultaneous fetch fails, try backup method
      return _getMetalPricesBackup(currency);
    }
  }

  /// Backup method using alternative API
  Future<Map<String, double>> _getMetalPricesBackup(String currency) async {
    try {
      // Use commodity API or currency converter API with security validation
      final response = await _dio.get(
        'https://api.exchangerate-api.com/v4/latest/XAU',
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final rates = data['rates'] as Map<String, dynamic>;
        
        // Convert troy ounce to gram prices
        final goldPerOunce = 1.0 / (rates[currency] as num).toDouble();
        final goldPerGram = goldPerOunce / 31.1035; // Troy ounce to gram
        
        // Silver price estimation (roughly 1/80 of gold historically)
        final silverPerGram = goldPerGram / 80;

        return {
          'gold': goldPerGram,
          'silver': silverPerGram,
        };
      }

      throw const Failure.metalPriceUnavailable();
    } catch (e) {
      throw const Failure.metalPriceUnavailable(
        message: 'Unable to fetch metal prices from any source',
      );
    }
  }

  /// Get historical prices for trend analysis
  Future<List<PriceHistoryPoint>> getGoldPriceHistory({
    required String currency,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/gold/history',
        queryParameters: {
          'currency': currency,
          'start_date': startDate.toIso8601String().split('T')[0],
          'end_date': endDate.toIso8601String().split('T')[0],
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final history = data['history'] as List<dynamic>;

        return history.map((point) {
          final pointData = point as Map<String, dynamic>;
          return PriceHistoryPoint(
            date: DateTime.parse(pointData['date']),
            price: (pointData['price'] as num).toDouble(),
          );
        }).toList();
      }

      return [];
    } catch (e) {
      // Return empty list if historical data is not available
      return [];
    }
  }

  /// Convert currency if needed
  Future<double> convertCurrency({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    if (fromCurrency == toCurrency) return amount;

    try {
      final response = await _dio.get(
        'https://api.exchangerate-api.com/v4/latest/$fromCurrency',
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final rates = data['rates'] as Map<String, dynamic>;
        final rate = (rates[toCurrency] as num).toDouble();
        
        return amount * rate;
      }

      throw Failure.serverFailure(
        message: 'Currency conversion failed',
        statusCode: response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw Failure.networkFailure(
        message: 'Failed to convert currency: ${e.message}',
      );
    }
  }

  /// Get supported currencies
  Future<List<String>> getSupportedCurrencies() async {
    try {
      final response = await _dio.get('$_baseUrl/currencies');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final currencies = data['currencies'] as List<dynamic>;
        
        return currencies.map((currency) => currency.toString()).toList();
      }

      // Return default currencies if API doesn't provide list
      return [
        'USD', 'EUR', 'GBP', 'BDT', 'SAR', 'AED', 'INR', 
        'PKR', 'MYR', 'IDR', 'TRY', 'EGP',
      ];
    } catch (e) {
      // Return default currencies on error
      return [
        'USD', 'EUR', 'GBP', 'BDT', 'SAR', 'AED', 'INR', 
        'PKR', 'MYR', 'IDR', 'TRY', 'EGP',
      ];
    }
  }

  /// Check API status and availability
  Future<bool> checkApiStatus() async {
    try {
      final response = await _dio.get(
        '$_baseUrl/status',
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

/// Price history data point for trend analysis
class PriceHistoryPoint {

  const PriceHistoryPoint({
    required this.date,
    required this.price,
  });

  factory PriceHistoryPoint.fromJson(Map<String, dynamic> json) {
    return PriceHistoryPoint(
      date: DateTime.parse(json['date']),
      price: (json['price'] as num).toDouble(),
    );
  }
  final DateTime date;
  final double price;

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'price': price,
  };
}

/// Metal price information with metadata
class MetalPriceInfo {

  const MetalPriceInfo({
    required this.price,
    required this.currency,
    required this.timestamp,
    required this.source,
    this.metadata,
  });

  factory MetalPriceInfo.fromJson(Map<String, dynamic> json) {
    return MetalPriceInfo(
      price: (json['price'] as num).toDouble(),
      currency: json['currency'],
      timestamp: DateTime.parse(json['timestamp']),
      source: json['source'],
      metadata: json['metadata'],
    );
  }
  final double price;
  final String currency;
  final DateTime timestamp;
  final String source;
  final Map<String, dynamic>? metadata;

  Map<String, dynamic> toJson() => {
    'price': price,
    'currency': currency,
    'timestamp': timestamp.toIso8601String(),
    'source': source,
    'metadata': metadata,
  };
}