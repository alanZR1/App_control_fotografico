enum AppEnvironment { development, testing, production }

abstract final class AppConfig {
  static const environment = AppEnvironment.development;
  static const useMockServices = bool.fromEnvironment(
    'USE_MOCK_SERVICES',
    defaultValue: false,
  );

  static String get apiBaseUrl =>
      const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: '',
      ).trim().isNotEmpty
      ? const String.fromEnvironment('API_BASE_URL')
      : switch (environment) {
          AppEnvironment.development => 'http://10.0.2.2:8080',
          AppEnvironment.testing => 'https://api-test.example.com',
          AppEnvironment.production => 'https://api.example.com',
        };
}
