import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  String? _authToken;
  
  String get authToken => _authToken ?? '';
  bool get hasAuthToken => _authToken != null && _authToken!.isNotEmpty;

  // Set authentication token
  void setAuthToken(String token) {
    _authToken = token;
  }

  // Clear authentication token
  void clearAuthToken() {
    _authToken = null;
  }

  // Load token from SharedPreferences
  Future<void> loadTokenFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
  }

  // Save token to SharedPreferences
  Future<void> saveTokenToStorage(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    _authToken = token;
  }

  // Remove token from SharedPreferences
  Future<void> removeTokenFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _authToken = null;
  }

  // Get headers with authentication
  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (hasAuthToken) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    
    return headers;
  }

  // Generic GET request
  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('${ApiConfig.apiBase}$endpoint');
    
    try {
      final response = await http.get(
        url,
        headers: _headers,
      ).timeout(ApiConfig.requestTimeout);
      
      return response;
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  // Generic POST request
  Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('${ApiConfig.apiBase}$endpoint');
    
    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(data),
      ).timeout(ApiConfig.requestTimeout);
      
      return response;
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  // Generic PUT request
  Future<http.Response> put(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('${ApiConfig.apiBase}$endpoint');
    
    try {
      final response = await http.put(
        url,
        headers: _headers,
        body: jsonEncode(data),
      ).timeout(ApiConfig.requestTimeout);
      
      return response;
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  // Generic DELETE request
  Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('${ApiConfig.apiBase}$endpoint');
    
    try {
      final response = await http.delete(
        url,
        headers: _headers,
      ).timeout(ApiConfig.requestTimeout);
      
      return response;
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  // Login method
  Future<String> login(String username, String password) async {
    final response = await post(ApiConfig.loginEndpoint, {
      'username': username,
      'password': password,
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'] as String;
      await saveTokenToStorage(token);
      return token;
    } else {
      throw ApiException('Login failed: ${response.statusCode}');
    }
  }

  // Get current user info
  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await get(ApiConfig.meEndpoint);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      await removeTokenFromStorage();
      throw ApiException('Authentication expired');
    } else {
      throw ApiException('Failed to get user info: ${response.statusCode}');
    }
  }

  // Logout
  Future<void> logout() async {
    await removeTokenFromStorage();
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}