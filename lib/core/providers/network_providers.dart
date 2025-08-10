import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/network_info.dart';

/// Dio HTTP client provider
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();
  
  // Add interceptors for logging and error handling
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
    logPrint: (obj) => print('HTTP: $obj'),
  ),);
  
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
