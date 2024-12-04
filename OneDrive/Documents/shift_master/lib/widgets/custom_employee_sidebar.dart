import 'package:flutter/material.dart';
import 'package:shift_master/screens/loading_screen_dart.dart';
import 'package:shift_master/services/firebase_service.dart';
import 'package:shift_master/services/firestore_service.dart';
import 'package:shift_master/utils/theme.dart';
import 'package:shift_master/models/employee_model.dart';

class CustomEmployeeSidebar extends StatefulWidget {
  const CustomEmployeeSidebar({super.key});

  @override
  State<CustomEmployeeSidebar> createState() => _CustomEmployeeSidebarState();
}

class _CustomEmployeeSidebarState extends State<CustomEmployeeSidebar> {
  final FirebaseService _firebaseService = FirebaseService();
  final FirestoreService _firestoreService = FirestoreService();
  Employee? _employee;

  @override
  void initState() {
    super.initState();
    _loadEmployeeData();
  }

  Future<void> _loadEmployeeData() async {
    final user = _firestoreService.auth.currentUser;
    if (user != null) {
      final data = await _firestoreService.getUser(user.uid);
      setState(() {
        // Null check to ensure data is not null
        if (data != null) {
          _employee = data;
        }
      });
    }
  }

  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const LoadingScreen(message: 'Logging out...');
      },
    );

    try {
      await _firebaseService.logout();
      Navigator.of(context).pop(); // Dismiss the loading screen
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      Navigator.of(context).pop(); // Dismiss the loading screen
      // Handle logout error, maybe show an error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Logout Error'),
            content: Text('An error occurred while logging out: $e'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    }
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? route,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppTheme.secondaryColor,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppTheme.secondaryColor,
          fontSize: 16,
        ),
      ),
      onTap: onTap ??
          (route != null ? () => Navigator.pushNamed(context, route) : null),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              _employee != null ? _employee!.name : "Loading...",
              style: const TextStyle(
                color: AppTheme.textColor2,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(
              _employee != null ? _employee!.email : "Loading...",
              style: const TextStyle(
                color: AppTheme.textColor2,
                fontSize: 14,
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: AppTheme.accentColor,
              child: Text(
                _employee != null ? _employee!.name[0] : "?",
                style: const TextStyle(
                  fontSize: 32,
                  color: AppTheme.textColor2,
                ),
              ),
            ),
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildListTile(
                  icon: Icons.dashboard,
                  title: "Dashboard",
                  route: '/employee',
                ),
                _buildListTile(
                  icon: Icons.schedule,
                  title: "Shifts",
                  route: '/empshifts',
                ),
                _buildListTile(
                  icon: Icons.exit_to_app,
                  title: "Logout",
                  onTap: _handleLogout,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
