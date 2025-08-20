import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../env/app_config.dart';

class AuthToken {
  const AuthToken(this.accessToken, this.clientId, this.expiresAt);
  final String accessToken;
  final String clientId;
  final DateTime expiresAt;
}

class AuthTokenNotifier extends AsyncNotifier<AuthToken> {
  @override
  Future<AuthToken> build() => refresh();

  Future<AuthToken> refresh() async {
    final cfg = const AppConfig();
    final res = await Dio().get(cfg.tokenProxy);
    final data = res.data is String
        ? jsonDecode(res.data as String)
        : res.data as Map<String, dynamic>;
    final exp = DateTime.now()
        .add(Duration(seconds: (data['expires_in'] as int?) ?? 3600));
    final token = AuthToken(
      (data['access_token'] as String?) ?? '',
      (data['client_id'] as String?) ?? 'deenmate',
      exp,
    );
    state = AsyncData(token);
    return token;
  }
}

final authTokenProvider = AsyncNotifierProvider<AuthTokenNotifier, AuthToken>(
    () => AuthTokenNotifier());
