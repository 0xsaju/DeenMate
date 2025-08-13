import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/network_info.dart';
import '../network/retry_interceptor.dart';

/// Dio HTTP client provider
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();

  dio.options.connectTimeout = const Duration(seconds: 30);
  dio.options.receiveTimeout = const Duration(seconds: 30);
  dio.options.headers = {
    'Accept': 'application/json',
    'User-Agent': 'DeenMate/1.0.0',
  };

  // Interceptors: logging then retry
  dio.interceptors.add(
    LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print('HTTP: $obj'),
    ),
  );
  dio.interceptors.add(RetryInterceptor(dio: dio));

  return dio;
});

/// Network connectivity provider
final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

/// Network info provider
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return NetworkInfoImpl(connectivity);
});

/// Network connectivity stream provider
final connectivityStreamProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return connectivity.onConnectivityChanged;
});

/// Current network status provider
final networkStatusProvider = FutureProvider<List<ConnectivityResult>>((ref) async {
  final connectivity = ref.watch(connectivityProvider);
  return connectivity.checkConnectivity();
});
