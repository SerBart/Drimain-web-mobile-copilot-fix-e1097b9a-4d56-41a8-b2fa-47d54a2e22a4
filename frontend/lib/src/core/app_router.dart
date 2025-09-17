import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'providers/auth_state_notifier.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'features/zgloszenia/presentation/screens/zgloszenia_screen.dart';

/// Application router configuration using GoRouter
class AppRouter {
  static GoRouter createRouter(AuthStateNotifier authStateNotifier) {
    return GoRouter(
      initialLocation: '/dashboard',
      refreshListenable: authStateNotifier,
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        // TODO: Add more routes for different features
        GoRoute(
          path: '/zgloszenia',
          builder: (context, state) => const ZgloszeniaScreen(),
        ),
        GoRoute(
          path: '/harmonogramy',
          builder: (context, state) => const Scaffold(
            appBar: AppBar(title: Text('Harmonogramy')),
            body: Center(child: Text('Harmonogramy - Coming Soon')),
          ),
        ),
        GoRoute(
          path: '/czesci',
          builder: (context, state) => const Scaffold(
            appBar: AppBar(title: Text('Części')),
            body: Center(child: Text('Części - Coming Soon')),
          ),
        ),
        GoRoute(
          path: '/raporty',
          builder: (context, state) => const Scaffold(
            appBar: AppBar(title: Text('Raporty')),
            body: Center(child: Text('Raporty - Coming Soon')),
          ),
        ),
        GoRoute(
          path: '/admin',
          builder: (context, state) => const Scaffold(
            appBar: AppBar(title: Text('Admin Panel')),
            body: Center(child: Text('Admin Panel - Coming Soon')),
          ),
        ),
      ],
      redirect: (context, state) {
        final isAuthenticated = authStateNotifier.isAuthenticated;
        final isLoggingIn = state.location == '/login';

        // If not authenticated and not on login page, redirect to login
        if (!isAuthenticated && !isLoggingIn) {
          return '/login';
        }

        // If authenticated and on login page, redirect to dashboard
        if (isAuthenticated && isLoggingIn) {
          return '/dashboard';
        }

        return null; // No redirect needed
      },
    );
  }
}