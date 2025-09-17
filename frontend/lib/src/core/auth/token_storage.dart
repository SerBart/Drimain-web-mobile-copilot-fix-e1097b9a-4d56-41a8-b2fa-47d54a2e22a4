import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing JWT tokens in local storage
class TokenStorage {
  static const String _tokenKey = 'auth_token';
  
  /// Save the authentication token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }
  
  /// Read the authentication token
  static Future<String?> readToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
  
  /// Clear the authentication token
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
  
  /// Check if a token exists
  static Future<bool> hasToken() async {
    final token = await readToken();
    return token != null && token.isNotEmpty;
  }
}