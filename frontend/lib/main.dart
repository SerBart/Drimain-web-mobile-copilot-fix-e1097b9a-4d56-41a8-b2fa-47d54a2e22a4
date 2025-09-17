import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/app.dart';
import 'src/providers/auth_state_notifier.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthStateNotifier(),
      child: const DriMainApp(),
    ),
  );
}