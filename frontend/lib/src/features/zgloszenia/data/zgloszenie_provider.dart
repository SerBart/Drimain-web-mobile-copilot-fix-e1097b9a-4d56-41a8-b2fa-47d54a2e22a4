import 'package:flutter/foundation.dart';
import '../data/models/zgloszenie_model.dart';
import '../data/services/zgloszenie_service.dart';

/// Provider for managing Zgloszenie state
class ZgloszenieProvider extends ChangeNotifier {
  final ZgloszenieService _service = ZgloszenieService();

  List<ZgloszenieModel> _zgloszenia = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _statusFilter;
  String? _typFilter;
  String? _searchQuery;

  // Getters
  List<ZgloszenieModel> get zgloszenia => _zgloszenia;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get statusFilter => _statusFilter;
  String? get typFilter => _typFilter;
  String? get searchQuery => _searchQuery;

  /// Load all zgloszenia with current filters
  Future<void> loadZgloszenia() async {
    _setLoading(true);
    _clearError();

    try {
      _zgloszenia = await _service.getAll(
        status: _statusFilter,
        typ: _typFilter,
        query: _searchQuery,
      );
    } catch (e) {
      _setError('Failed to load zgloszenia: $e');
      if (kDebugMode) {
        print('Error loading zgloszenia: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Load a specific zgloszenie by ID
  Future<ZgloszenieModel?> loadZgloszenieById(int id) async {
    try {
      return await _service.getById(id);
    } catch (e) {
      _setError('Failed to load zgloszenie: $e');
      if (kDebugMode) {
        print('Error loading zgloszenie $id: $e');
      }
      return null;
    }
  }

  /// Create a new zgloszenie
  Future<bool> createZgloszenie(ZgloszenieModel zgloszenie) async {
    _setLoading(true);
    _clearError();

    try {
      final created = await _service.create(zgloszenie);
      _zgloszenia.insert(0, created); // Add to the beginning
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to create zgloszenie: $e');
      _setLoading(false);
      if (kDebugMode) {
        print('Error creating zgloszenie: $e');
      }
      return false;
    }
  }

  /// Update an existing zgloszenie
  Future<bool> updateZgloszenie(int id, ZgloszenieModel zgloszenie) async {
    _setLoading(true);
    _clearError();

    try {
      final updated = await _service.update(id, zgloszenie);
      final index = _zgloszenia.indexWhere((z) => z.id == id);
      if (index != -1) {
        _zgloszenia[index] = updated;
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to update zgloszenie: $e');
      _setLoading(false);
      if (kDebugMode) {
        print('Error updating zgloszenie $id: $e');
      }
      return false;
    }
  }

  /// Delete a zgloszenie
  Future<bool> deleteZgloszenie(int id) async {
    _setLoading(true);
    _clearError();

    try {
      await _service.delete(id);
      _zgloszenia.removeWhere((z) => z.id == id);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to delete zgloszenie: $e');
      _setLoading(false);
      if (kDebugMode) {
        print('Error deleting zgloszenie $id: $e');
      }
      return false;
    }
  }

  /// Set status filter and reload data
  Future<void> setStatusFilter(String? status) async {
    _statusFilter = status;
    await loadZgloszenia();
  }

  /// Set type filter and reload data
  Future<void> setTypFilter(String? typ) async {
    _typFilter = typ;
    await loadZgloszenia();
  }

  /// Set search query and reload data
  Future<void> setSearchQuery(String? query) async {
    _searchQuery = query?.isEmpty == true ? null : query;
    await loadZgloszenia();
  }

  /// Clear all filters and reload data
  Future<void> clearFilters() async {
    _statusFilter = null;
    _typFilter = null;
    _searchQuery = null;
    await loadZgloszenia();
  }

  /// Clear error message
  void clearError() {
    _clearError();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}