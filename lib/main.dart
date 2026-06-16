import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/signin_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/forgot_password.dart';
import 'screens/role_screen.dart';
import 'screens/splash_screen.dart';

import 'lawyer/lawyer_dashboard.dart';
import 'client/client_dashboard.dart';
import 'admin/admin_dashboard.dart';

import 'admin/analytics.dart';
import 'admin/case_allocation.dart';
import 'admin/lawyer_management.dart';

import 'ai/compliance.dart';
import 'ai/predictions.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("Firebase initialized successfully");
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
    debugPrint("Please ensure google-services.json is present in android/app/");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LexisAI',

      theme: ThemeData(
        scaffoldBackgroundColor:
            const Color(0xFFF4F6FB),
        primaryColor:
            const Color(0xFF001A3A),
        textTheme:
            GoogleFonts.interTextTheme(),
        useMaterial3: true,
      ),

      home: const SplashScreen(),

      routes: {
        '/signin': (context) =>
            const SignInScreen(),
        '/signup': (context) =>
            const SignUpScreen(),
        '/forgot': (context) =>
            const ForgotPasswordScreen(),
        '/role': (context) =>
            const RoleScreen(),

        '/lawyer': (context) =>
            const LawyerDashboard(),
        '/client': (context) =>
            const ClientDashboard(),
        '/admin': (context) =>
            const AdminDashboard(),

        '/analytics': (context) =>
            const AnalyticsScreen(),
        '/allocation': (context) =>
            const CaseAllocationScreen(),
        '/lawyers': (context) =>
            const LawyerManagementScreen(),

        '/compliance': (context) =>
            const ComplianceScreen(),
        '/predictions': (context) =>
            const PredictionsScreen(),
      },
    );
  }
}