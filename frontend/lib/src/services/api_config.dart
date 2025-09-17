// API Configuration
class ApiConfig {
  // The API base URL - can be overridden via --dart-define=API_BASE=...
  static const String apiBase = String.fromEnvironment(
    'API_BASE',
    defaultValue: 'http://localhost:8080',
  );
  
  static const String loginEndpoint = '/api/auth/login';
  static const String meEndpoint = '/api/auth/me';
  static const String zgloszeniaEndpoint = '/api/zgloszenia';
  static const String harmonogramyEndpoint = '/api/harmonogramy';
  static const String czesciEndpoint = '/api/czesci';
  static const String raportyEndpoint = '/api/raporty';
  
  // Admin endpoints
  static const String adminDzialyEndpoint = '/api/admin/dzialy';
  static const String adminMaszynyEndpoint = '/api/admin/maszyny';
  static const String adminOsobyEndpoint = '/api/admin/osoby';
  static const String adminUsersEndpoint = '/api/admin/users';
  
  // Default timeout for HTTP requests
  static const Duration requestTimeout = Duration(seconds: 30);
}