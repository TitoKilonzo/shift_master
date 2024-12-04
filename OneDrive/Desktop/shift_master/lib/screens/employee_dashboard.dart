import 'package:flutter/material.dart';
import 'package:shift_master/widgets/custom_employee_sidebar.dart';
import 'package:shift_master/utils/theme.dart';
import 'package:shift_master/widgets/custom_app_bar.dart';
import 'package:shift_master/models/employee_model.dart';
import 'package:shift_master/services/firestore_service.dart';

class EmployeeDashboardScreen extends StatefulWidget {
  const EmployeeDashboardScreen({super.key});

  @override
  EmployeeDashboardScreenState createState() => EmployeeDashboardScreenState();
}

class EmployeeDashboardScreenState extends State<EmployeeDashboardScreen> {
  late Employee? _employee;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _loadEmployeeData();
  }

  Future<void> _loadEmployeeData() async {
    final user = _firestoreService.auth.currentUser;
    if (user != null) {
      final data = await _firestoreService.getUser(user.uid);
      if (data != null) {
        setState(() {
          _employee = data;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Employee Dashboard"),
      drawer: const CustomEmployeeSidebar(),
      body: SingleChildScrollView(
        child: Container(
          color: AppTheme.backgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_employee != null) _buildWelcomeCard(context),
                const SizedBox(height: 32),
                if (_employee != null) _buildEmployeeDetails(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${_employee!.name}!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Here\'s an overview of your employee dashboard.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeDetails(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Employee Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.secondaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailItem('Name', _employee!.name),
                      const SizedBox(height: 12),
                      _buildDetailItem('Email', _employee!.email),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailItem('Department', _employee!.department),
                      const SizedBox(height: 12),
                      _buildDetailItem('Position', _employee!.position),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.secondaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textColor,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}
