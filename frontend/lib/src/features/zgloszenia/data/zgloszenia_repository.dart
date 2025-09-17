import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import 'zgloszenie_model.dart';

class ZgloszeniaRepository {
  final ApiClient _apiClient;

  ZgloszeniaRepository(this._apiClient);

  Future<List<Zgloszenie>> fetchAll({
    String? status,
    String? typ,
    String? query,
  }) async {
    final queryParams = <String, String>{};
    if (status != null) queryParams['status'] = status;
    if (typ != null) queryParams['typ'] = typ;
    if (query != null) queryParams['q'] = query;

    final queryString = queryParams.isNotEmpty
        ? '?' + queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')
        : '';

    final response = await _apiClient.get('/api/zgloszenia$queryString');

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Zgloszenie.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      throw UnauthorizedException('Authentication required');
    } else {
      throw ApiException('Failed to fetch zgloszenia: ${response.statusCode}');
    }
  }

  Future<Zgloszenie> fetch(int id) async {
    final response = await _apiClient.get('/api/zgloszenia/$id');

    if (response.statusCode == 200) {
      return Zgloszenie.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw NotFoundException('Zgloszenie not found');
    } else if (response.statusCode == 401) {
      throw UnauthorizedException('Authentication required');
    } else {
      throw ApiException('Failed to fetch zgloszenie: ${response.statusCode}');
    }
  }

  Future<Zgloszenie> create(ZgloszenieCreateRequest request) async {
    final response = await _apiClient.post(
      '/api/zgloszenia',
      body: request.toJson(),
    );

    if (response.statusCode == 201) {
      return Zgloszenie.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      throw UnauthorizedException('Authentication required');
    } else if (response.statusCode == 400) {
      final error = jsonDecode(response.body);
      throw ValidationException(error['message'] ?? 'Validation failed');
    } else {
      throw ApiException('Failed to create zgloszenie: ${response.statusCode}');
    }
  }

  Future<Zgloszenie> update(int id, ZgloszenieUpdateRequest request) async {
    final response = await _apiClient.put(
      '/api/zgloszenia/$id',
      body: request.toJson(),
    );

    if (response.statusCode == 200) {
      return Zgloszenie.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw NotFoundException('Zgloszenie not found');
    } else if (response.statusCode == 401) {
      throw UnauthorizedException('Authentication required');
    } else if (response.statusCode == 403) {
      throw ForbiddenException('Insufficient permissions');
    } else if (response.statusCode == 400) {
      final error = jsonDecode(response.body);
      throw ValidationException(error['message'] ?? 'Validation failed');
    } else {
      throw ApiException('Failed to update zgloszenie: ${response.statusCode}');
    }
  }

  Future<void> delete(int id) async {
    final response = await _apiClient.delete('/api/zgloszenia/$id');

    if (response.statusCode == 204) {
      return; // Success
    } else if (response.statusCode == 404) {
      throw NotFoundException('Zgloszenie not found');
    } else if (response.statusCode == 401) {
      throw UnauthorizedException('Authentication required');
    } else if (response.statusCode == 403) {
      throw ForbiddenException('Insufficient permissions');
    } else {
      throw ApiException('Failed to delete zgloszenie: ${response.statusCode}');
    }
  }
}

// Exception classes
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  
  @override
  String toString() => 'ApiException: $message';
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(String message) : super(message);
}

class NotFoundException extends ApiException {
  NotFoundException(String message) : super(message);
}

class ForbiddenException extends ApiException {
  ForbiddenException(String message) : super(message);
}

class ValidationException extends ApiException {
  ValidationException(String message) : super(message);
}

// Riverpod provider
final zgloszeniaRepositoryProvider = Provider<ZgloszeniaRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return ZgloszeniaRepository(apiClient);
});