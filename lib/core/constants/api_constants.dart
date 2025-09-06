class ApiConstants {
  // Backend API base URL - Use your computer's IP address here
  // You can find your IP address by running 'ipconfig' on Windows or 'ifconfig' on Mac/Linux
  static const String baseUrl =
      'http://192.168.0.104:3000'; // Your actual IP address

  // API endpoints
  static const String redirectUrlEndpoint = '/api/url';
  static const String redirectConfigEndpoint = '/api/redirect-config';

  // Full API URLs
  static String get redirectUrlApi => '$baseUrl$redirectUrlEndpoint';
  static String get redirectConfigApi => '$baseUrl$redirectConfigEndpoint';
}
