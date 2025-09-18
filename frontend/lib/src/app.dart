import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_state_notifier.dart';
import 'core/app_router.dart';

class DriMainApp extends StatelessWidget {
  const DriMainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthStateNotifier>(
      builder: (context, authState, child) {
        final router = AppRouter.createRouter(authState);

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