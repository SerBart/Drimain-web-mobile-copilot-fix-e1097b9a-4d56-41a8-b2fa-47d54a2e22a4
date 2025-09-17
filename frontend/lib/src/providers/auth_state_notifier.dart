import 'package:flutter/foundation.dart';
import '../services/api_client.dart';

class AuthStateNotifier extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _currentUser;
  String? _errorMessage;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;

  AuthStateNotifier() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    _setLoading(true);
    
    try {
      await _apiClient.loadTokenFromStorage();
      
      if (_apiClient.hasAuthToken) {
        // Verify token is still valid
        final userInfo = await _apiClient.getCurrentUser();
        _currentUser = userInfo['username'] ?? userInfo.toString();
        _isAuthenticated = true;
        _errorMessage = null;
      }
    } catch (e) {
      // Token is invalid or expired
      _isAuthenticated = false;
      _currentUser = null;
      await _apiClient.removeTokenFromStorage();
      
      if (e is ApiException && e.message.contains('Authentication expired')) {
        _errorMessage = 'Session expired. Please log in again.';
      } else {
        _errorMessage = null; // Don't show error on startup
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> login(String username, String password) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _apiClient.login(username, password);
      
      // Get user info after successful login
      final userInfo = await _apiClient.getCurrentUser();
      _currentUser = userInfo['username'] ?? userInfo.toString();
      _isAuthenticated = true;
      
    } catch (e) {
      _isAuthenticated = false;
      _currentUser = null;
      
      if (e is ApiException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = 'Login failed. Please try again.';
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    
    try {
      await _apiClient.logout();
    } catch (e) {
      // Even if logout fails, we still want to clear local state
      if (kDebugMode) {
        print('Logout error: $e');
      }
    } finally {
      _isAuthenticated = false;
      _currentUser = null;
      _errorMessage = null;
      _setLoading(false);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}