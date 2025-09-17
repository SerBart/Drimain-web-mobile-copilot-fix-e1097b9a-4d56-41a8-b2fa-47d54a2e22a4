import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_state_notifier.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

class DriMainApp extends StatelessWidget {
  const DriMainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthStateNotifier>(
      builder: (context, authState, child) {
        final router = GoRouter(
          initialLocation: authState.isAuthenticated ? '/dashboard' : '/login',
          routes: [
            GoRoute(
              path: '/login',
              builder: (context, state) => const LoginScreen(),
            ),
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
            // TODO: Add more routes for different screens
          ],
          redirect: (context, state) {
            final isAuthenticated = authState.isAuthenticated;
            final isLoggingIn = state.location == '/login';

            if (!isAuthenticated && !isLoggingIn) {
              return '/login';
            }
            if (isAuthenticated && isLoggingIn) {
              return '/dashboard';
            }
            return null;
          },
        );

        return MaterialApp.router(
          title: 'DriMain',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
          ),
          routerConfig: router,
        );
      },
    );
  }
}