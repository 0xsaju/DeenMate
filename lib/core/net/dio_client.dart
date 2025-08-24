import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../env/app_config.dart';


final dioProvider = Provider<Dio>((ref) {
  final cfg = const AppConfig();
  final dio = Dio(BaseOptions(
    baseUrl: cfg.qfBase,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 20),
  ));

  // Bypass auth for development using api.quran.com
  // If using Quran.Foundation secured API, re-enable token headers below.
  // dio.interceptors.add(...)

  return dio;
});
