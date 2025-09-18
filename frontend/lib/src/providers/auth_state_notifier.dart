import 'package:flutter/foundation.dart';
import '../services/api_client.dart';
import '../core/auth/user_session.dart';

class AuthStateNotifier extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  
  bool _isAuthenticated = false;
  bool _isLoading = false;
  UserSession? _userSession;
  String? _errorMessage;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  UserSession? get userSession => _userSession;
  String? get currentUser => _userSession?.username;
  String? get errorMessage => _errorMessage;

  // Convenience methods for role checking
  bool hasRole(String role) => _userSession?.hasRole(role) ?? false;
  bool isAdmin() => _userSession?.isAdmin() ?? false;
  bool isUser() => _userSession?.isUser() ?? false;

  AuthStateNotifier() {
    _initializeAuth();
  }

  /// Initialize authentication state on app startup
  Future<void> init() async {
    await _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    _setLoading(true);
    
    try {
      await _apiClient.loadTokenFromStorage();
      
      if (_apiClient.hasAuthToken) {
        // Verify token is still valid
        final userSession = await _apiClient.getCurrentUserSession();
        _userSession = userSession;
        _isAuthenticated = true;
        _errorMessage = null;
      }
    } catch (e) {
      // Token is invalid or expired
      _isAuthenticated = false;
      _userSession = null;
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
      
      // Get user session after successful login
      final userSession = await _apiClient.getCurrentUserSession();
      _userSession = userSession;
      _isAuthenticated = true;
      
    } catch (e) {
      _isAuthenticated = false;
      _userSession = null;
      
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
      _userSession = null;
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