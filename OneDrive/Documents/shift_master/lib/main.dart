import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shift_master/firebase_options.dart';
import 'package:shift_master/screens/dashboard_screen.dart';
import 'package:shift_master/screens/employee_dashboard.dart';
import 'package:shift_master/screens/employee_management_screen.dart';
import 'package:shift_master/screens/login_screen.dart';
import 'package:shift_master/screens/report_screen.dart';
import 'package:shift_master/screens/shift_management_screen.dart';
import 'package:shift_master/screens/shifts_screen.dart';
import 'package:shift_master/screens/splash_screen.dart';
import 'package:shift_master/services/firestore_service.dart';
import 'package:shift_master/utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Optional: Uncomment only when you want to create the first admin user
    // FirestoreService firestoreService = FirestoreService();
    // await firestoreService.createFirstAdminUser();

    print('Firebase initialized successfully');
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
  runApp(const ShiftMasterApp());
}

class ShiftMasterApp extends StatelessWidget {
  const ShiftMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shift Master',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/shifts': (context) => const ShiftManagementScreen(),
        '/employees': (context) => const EmployeeManagementScreen(),
        '/reports': (context) => const ReportsScreen(),
        '/employee': (context) => const EmployeeDashboardScreen(),
        '/empshifts': (context) => const ShiftsScreen(),
      },
    );
  }
}
