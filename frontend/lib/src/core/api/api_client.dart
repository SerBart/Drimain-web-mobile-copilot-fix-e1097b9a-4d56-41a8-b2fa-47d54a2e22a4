import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiClient {
  final String baseUrl;
  final http.Client _client;
  String? _authToken;

  ApiClient({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  void setAuthToken(String? token) {
    _authToken = token;
  }

  Map<String, String> get _defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  Future<http.Response> get(String path, {Map<String, String>? headers}) {
    final uri = Uri.parse('$baseUrl$path');
    return _client.get(
      uri,
      headers: {..._defaultHeaders, ...?headers},
    );
  }

  Future<http.Response> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) {
    final uri = Uri.parse('$baseUrl$path');
    return _client.post(
      uri,
      headers: {..._defaultHeaders, ...?headers},
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Future<http.Response> put(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) {
    final uri = Uri.parse('$baseUrl$path');
    return _client.put(
      uri,
      headers: {..._defaultHeaders, ...?headers},
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Future<http.Response> delete(String path, {Map<String, String>? headers}) {
    final uri = Uri.parse('$baseUrl$path');
    return _client.delete(
      uri,
      headers: {..._defaultHeaders, ...?headers},
    );
  }

  void dispose() {
    _client.close();
  }
}

// Riverpod provider for the API client
final apiClientProvider = Provider<ApiClient>((ref) {
  const baseUrl = String.fromEnvironment(
    'API_BASE',
    defaultValue: 'http://localhost:8080',
  );
  
  return ApiClient(baseUrl: baseUrl);
});