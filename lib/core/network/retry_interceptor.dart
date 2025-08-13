import 'dart:async';

import 'package:dio/dio.dart';

/// A simple retry interceptor with exponential backoff.
/// Retries on transient network errors and 5xx responses.
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required Dio dio,
    int maxRetries = 3,
    Duration baseDelay = const Duration(milliseconds: 400),
    List<int> retryableStatusCodes = const [500, 502, 503, 504],
  })  : _dio = dio,
        _maxRetries = maxRetries,
        _baseDelay = baseDelay,
        _retryableStatusCodes = retryableStatusCodes;

  final Dio _dio;
  final int _maxRetries;
  final Duration _baseDelay;
  final List<int> _retryableStatusCodes;

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;
    final retries = (requestOptions.extra['retries'] as int?) ?? 0;

    final isTimeout = err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout;

    final statusCode = err.response?.statusCode;
    final isRetryableStatus =
        statusCode != null && _retryableStatusCodes.contains(statusCode);

    // Only retry idempotent GET requests to be safe
    final isGet = requestOptions.method.toUpperCase() == 'GET';

    if (isGet &&
        retries < _maxRetries &&
        (isTimeout ||
            isRetryableStatus ||
            err.type == DioExceptionType.connectionError)) {
      final delay = _baseDelay * (1 << retries); // exponential backoff
      await Future<void>.delayed(delay);

      final newOptions = Options(
        method: requestOptions.method,
        headers: requestOptions.headers,
        responseType: requestOptions.responseType,
        followRedirects: requestOptions.followRedirects,
        receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
        extra: {
          ...requestOptions.extra,
          'retries': retries + 1,
        },
      );

      try {
        final response = await _dio.request<dynamic>(
          requestOptions.path,
          data: requestOptions.data,
          queryParameters: requestOptions.queryParameters,
          options: newOptions,
          cancelToken: requestOptions.cancelToken,
          onReceiveProgress: requestOptions.onReceiveProgress,
          onSendProgress: requestOptions.onSendProgress,
        );
        return handler.resolve(response);
      } catch (e) {
        return handler.next(err);
      }
    }

    return handler.next(err);
  }
}
