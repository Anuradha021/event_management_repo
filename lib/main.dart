import 'package:event_management_app1/features/admin/screens/admin_setup.dart';
import 'package:event_management_app1/features/auth/screens/login_screen.dart';
import 'package:event_management_app1/features/auth/screens/sign_up_screen.dart';
import 'package:event_management_app1/features/auth/screens/welcome_screen.dart';
import 'package:event_management_app1/features/user/screens/unified_dashboard.dart';
import 'package:event_management_app1/core/config/firebase_options.dart';
import 'package:event_management_app1/core/config/app_theme.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unite',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: AppInitializer(),
      routes: {
        '/admin-setup': (context) => AdminSetupScreen(),
        '/welcome': (context) => WelcomeScreen(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
        '/dashboard': (context) => const UnifiedDashboard(),
      },
    );
  }
}

class AppInitializer extends StatelessWidget {
  Future<bool> checkIsFirstTime() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    return snapshot.docs.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkIsFirstTime(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Something went wrong')),
          );
        }

        final isFirstTime = snapshot.data ?? false;
        return isFirstTime ? AdminSetupScreen() : WelcomeScreen();
      },
    );
  }
}
