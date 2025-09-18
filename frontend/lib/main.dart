import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/app.dart';
import 'src/providers/auth_state_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Create auth state notifier and initialize it
  final authStateNotifier = AuthStateNotifier();
  await authStateNotifier.init();
  
  runApp(
    ChangeNotifierProvider.value(
      value: authStateNotifier,
      child: const DriMainApp(),
    ),
  );
}