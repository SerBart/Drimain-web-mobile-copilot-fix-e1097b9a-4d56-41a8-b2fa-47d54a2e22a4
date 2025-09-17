import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? username;
  final List<String> roles;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.username,
    this.roles = const [],
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? username,
    List<String>? roles,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      username: username ?? this.username,
      roles: roles ?? this.roles,
      error: error,
    );
  }

  bool hasRole(String role) {
    return roles.contains(role);
  }

  bool get isAdmin => hasRole('ROLE_ADMIN');
  bool get isUser => hasRole('ROLE_USER');
}

// Provider for the current auth state
final authStateProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref);
});

class AuthController extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthController(this._ref) : super(const AuthState()) {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // Try to restore token and get user info
      await _restoreTokenAndUserInfo();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        error: 'Failed to restore session: $e',
      );
    }
  }

  Future<void> _restoreTokenAndUserInfo() async {
    final tokenStorage = _ref.read(tokenStorageProvider);
    final apiClient = _ref.read(apiClientProvider);
    
    final token = await tokenStorage.getToken();
    if (token == null) {
      state = state.copyWith(isLoading: false, isAuthenticated: false);
      return;
    }

    // Set token in API client
    apiClient.setAuthToken(token);

    try {
      // Validate token by calling /api/auth/me
      final response = await apiClient.get('/api/auth/me');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          username: data['username'],
          roles: List<String>.from(data['roles'] ?? []),
          error: null,
        );
      } else {
        // Token is invalid, clear it
        await logout();
      }
    } catch (e) {
      await logout();
    }
  }

  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final apiClient = _ref.read(apiClientProvider);
      final tokenStorage = _ref.read(tokenStorageProvider);
      
      final response = await apiClient.post('/api/auth/login', body: {
        'username': username,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token'];
        
        // Save token
        await tokenStorage.saveToken(token);
        apiClient.setAuthToken(token);
        
        // Get user info
        await _getUserInfo();
        return true;
      } else {
        final errorData = json.decode(response.body);
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          error: errorData['error'] ?? 'Login failed',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        error: 'Network error: $e',
      );
      return false;
    }
  }

  Future<void> _getUserInfo() async {
    try {
      final apiClient = _ref.read(apiClientProvider);
      final response = await apiClient.get('/api/auth/me');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          username: data['username'],
          roles: List<String>.from(data['roles'] ?? []),
          error: null,
        );
      } else {
        throw Exception('Failed to get user info');
      }
    } catch (e) {
      await logout();
    }
  }

  Future<void> logout() async {
    final tokenStorage = _ref.read(tokenStorageProvider);
    final apiClient = _ref.read(apiClientProvider);
    
    await tokenStorage.clearToken();
    apiClient.setAuthToken(null);
    
    state = const AuthState(
      isAuthenticated: false,
      isLoading: false,
      username: null,
      roles: [],
      error: null,
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider imports
import '../api/api_client.dart';
import 'token_storage.dart';
import 'dart:convert';

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());