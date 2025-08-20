class AppConfig {
  const AppConfig();

  // Public dev base (bypass auth): Quran.com API v4
  final String qfBase = 'https://api.quran.com/api/v4';

  // Token proxy endpoint (edge worker)
  final String tokenProxy = const String.fromEnvironment(
    'TOKEN_PROXY',
    defaultValue: 'https://auth.deenmate.app/token',
  );

  // Pagination size
  final int perPage = 50;
}
