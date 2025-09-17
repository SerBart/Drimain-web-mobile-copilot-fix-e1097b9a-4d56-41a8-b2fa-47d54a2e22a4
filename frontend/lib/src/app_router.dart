import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/zgloszenia/presentation/zgloszenia_list_screen.dart';
import '../features/zgloszenia/presentation/zgloszenie_detail_screen.dart';
import '../features/zgloszenia/presentation/zgloszenie_form_screen.dart';
import '../screens/login_screen.dart';
import '../screens/dashboard_screen.dart';
import '../features/harmonogramy/presentation/harmonogramy_screen.dart';
import '../features/raporty/presentation/raporty_screen.dart';
import '../features/czesci/presentation/czesci_screen.dart';
import 'core/auth/auth_state.dart';

// Route names
abstract class AppRoutes {
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const zgloszenia = '/zgloszenia';
  static const zgloszenieDetail = '/zgloszenia/:id';
  static const zgloszenieEdit = '/zgloszenia/:id/edit';
  static const zgloszenieNew = '/zgloszenia/new';
  static const harmonogramy = '/harmonogramy';
  static const raporty = '/raporty';
  static const czesci = '/czesci';
}

// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoading = authState.isLoading;
      final currentPath = state.location;
      
      // If still loading, don't redirect yet
      if (isLoading) return null;
      
      // If not authenticated and not on login page, redirect to login
      if (!isAuthenticated && currentPath != AppRoutes.login) {
        return AppRoutes.login;
      }
      
      // If authenticated and on login page, redirect to dashboard
      if (isAuthenticated && currentPath == AppRoutes.login) {
        return AppRoutes.dashboard;
      }
      
      return null; // No redirect needed
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.zgloszenia,
        name: 'zgloszenia',
        builder: (context, state) => const ZgloszeniaListScreen(),
        routes: [
          GoRoute(
            path: 'new',
            name: 'zgloszenieNew',
            builder: (context, state) => const ZgloszenieFormScreen(),
          ),
          GoRoute(
            path: ':id',
            name: 'zgloszenieDetail',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return ZgloszenieDetailScreen(id: int.parse(id));
            },
            routes: [
              GoRoute(
                path: 'edit',
                name: 'zgloszenieEdit',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return ZgloszenieFormScreen(id: int.parse(id));
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.harmonogramy,
        name: 'harmonogramy',
        builder: (context, state) => const HarmonogramyScreen(),
      ),
      GoRoute(
        path: AppRoutes.raporty,
        name: 'raporty',
        builder: (context, state) => const RaportyScreen(),
      ),
      GoRoute(
        path: AppRoutes.czesci,
        name: 'czesci',
        builder: (context, state) => const CzesciScreen(),
      ),
    ],
  );
});