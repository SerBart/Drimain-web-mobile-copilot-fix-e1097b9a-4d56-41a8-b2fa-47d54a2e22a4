import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../services/api_client.dart';
import '../../../services/api_config.dart';
import '../models/zgloszenie_model.dart';

/// Service for handling Zgloszenie API operations
class ZgloszenieService {
  final ApiClient _apiClient = ApiClient();

  /// Get all zgloszenia with optional filters
  Future<List<ZgloszenieModel>> getAll({
    String? status,
    String? typ,
    String? query,
  }) async {
    String endpoint = ApiConfig.zgloszeniaEndpoint;
    List<String> queryParams = [];

    if (status != null) queryParams.add('status=${Uri.encodeComponent(status)}');
    if (typ != null) queryParams.add('typ=${Uri.encodeComponent(typ)}');
    if (query != null) queryParams.add('q=${Uri.encodeComponent(query)}');

    if (queryParams.isNotEmpty) {
      endpoint += '?${queryParams.join('&')}';
    }

    final response = await _apiClient.get(endpoint);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => ZgloszenieModel.fromJson(json)).toList();
    } else {
      throw ApiException('Failed to load zgloszenia: ${response.statusCode}');
    }
  }

  /// Get a specific zgloszenie by ID
  Future<ZgloszenieModel> getById(int id) async {
    final response = await _apiClient.get('${ApiConfig.zgloszeniaEndpoint}/$id');

    if (response.statusCode == 200) {
      return ZgloszenieModel.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw ApiException('Zgloszenie not found');
    } else {
      throw ApiException('Failed to load zgloszenie: ${response.statusCode}');
    }
  }

  /// Create a new zgloszenie
  Future<ZgloszenieModel> create(ZgloszenieModel zgloszenie) async {
    final response = await _apiClient.post(
      ApiConfig.zgloszeniaEndpoint,
      zgloszenie.toJson(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return ZgloszenieModel.fromJson(jsonDecode(response.body));
    } else {
      throw ApiException('Failed to create zgloszenie: ${response.statusCode}');
    }
  }

  /// Update an existing zgloszenie
  Future<ZgloszenieModel> update(int id, ZgloszenieModel zgloszenie) async {
    final response = await _apiClient.put(
      '${ApiConfig.zgloszeniaEndpoint}/$id',
      zgloszenie.toJson(),
    );

    if (response.statusCode == 200) {
      return ZgloszenieModel.fromJson(jsonDecode(response.body));
    } else {
      throw ApiException('Failed to update zgloszenie: ${response.statusCode}');
    }
  }

  /// Delete a zgloszenie
  Future<void> delete(int id) async {
    final response = await _apiClient.delete('${ApiConfig.zgloszeniaEndpoint}/$id');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw ApiException('Failed to delete zgloszenie: ${response.statusCode}');
    }
  }
}