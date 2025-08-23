import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';

class ApiService {
  /// Fetches the redirect URL from the backend
  static Future<String> getRedirectUrl() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.redirectUrlApi),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['url'] as String;
      } else {
        throw Exception('Failed to load redirect URL: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  /// Fetches redirect configuration from the backend
  static Future<Map<String, dynamic>> getRedirectConfig() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.redirectConfigApi),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to load redirect config: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }
}
