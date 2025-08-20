import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthTokenState {
  const AuthTokenState({this.token, this.expiresAt});
  final String? token;
  final DateTime? expiresAt;

  bool get isValid =>
      token != null && expiresAt != null && DateTime.now().isBefore(expiresAt!);
}

final authTokenNotifierProvider =
    NotifierProvider<AuthTokenNotifier, AuthTokenState>(
  AuthTokenNotifier.new,
);

class AuthTokenNotifier extends Notifier<AuthTokenState> {
  final Dio _dio = Dio();
  Completer<void>? _refreshing;

  @override
  AuthTokenState build() {
    return const AuthTokenState();
  }

  InterceptorsWrapper createInterceptor({required String clientId}) {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Ensure token
        await ensureValidToken();
        if (state.token != null) {
          options.headers['Authorization'] = 'Bearer ${state.token}';
          options.headers['x-auth-token'] = state.token;
          options.headers['x-client-id'] = clientId;
        }
        handler.next(options);
      },
      onError: (e, handler) async {
        if ((e.response?.statusCode == 401 || e.response?.statusCode == 403)) {
          // Attempt refresh
          final reqOptions = e.requestOptions;
          try {
            await refreshTokenWithBackoff();
            // Retry
            final clone = await _retryRequest(reqOptions);
            return handler.resolve(clone);
          } catch (_) {
            return handler.next(e);
          }
        }
        handler.next(e);
      },
    );
  }

  Future<Response<dynamic>> _retryRequest(RequestOptions ro) async {
    final dio = Dio();
    dio.options
      ..baseUrl = ro.baseUrl
      ..headers = ro.headers
      ..connectTimeout = ro.connectTimeout
      ..receiveTimeout = ro.receiveTimeout;
    return dio.request(
      ro.path,
      data: ro.data,
      queryParameters: ro.queryParameters,
      options: Options(method: ro.method, headers: ro.headers),
    );
  }

  Future<void> ensureValidToken() async {
    if (state.isValid) return;
    await refreshTokenWithBackoff();
  }

  Future<void> refreshTokenWithBackoff() async {
    if (_refreshing != null) return _refreshing!.future;
    _refreshing = Completer<void>();
    int attempt = 0;
    while (true) {
      try {
        final t = await _fetchToken();
        state = AuthTokenState(token: t.item1, expiresAt: t.item2);
        _refreshing!.complete();
        _refreshing = null;
        return;
      } catch (e) {
        attempt++;
        final delayMs = (200 * (1 << (attempt - 1))).clamp(200, 5000);
        await Future.delayed(Duration(milliseconds: delayMs));
        if (attempt >= 5) {
          _refreshing!.completeError(e);
          _refreshing = null;
          rethrow;
        }
      }
    }
  }

  // Replace with your Cloudflare Worker endpoint
  static const String _tokenEndpoint = 'https://your-worker.example.com/token';

  Future<(String, DateTime)> _fetchToken() async {
    final res = await _dio.get(_tokenEndpoint);
    final data = res.data as Map<String, dynamic>;
    final token = data['token'] as String;
    final expiresIn = data['expires_in'] as int? ?? 3300; // seconds
    final expiry = DateTime.now().add(Duration(seconds: expiresIn - 60));
    return (token, expiry);
  }
}
