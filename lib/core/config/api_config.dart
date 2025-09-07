class ApiConfig {
  // Backend server configuration
  // Change this IP address if your computer's IP address changes
  static const String baseUrl = 'http://192.168.0.102:3000';

  // API endpoints
  static const String urlsEndpoint = '/api/urls';
  static const String healthEndpoint = '/health';

  // Full URLs
  static String get urlsUrl => '$baseUrl$urlsEndpoint';
  static String get healthUrl => '$baseUrl$healthEndpoint';

  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
  };
}
