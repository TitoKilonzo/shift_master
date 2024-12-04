import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shift_master/widgets/custom_employee_sidebar.dart';
import 'package:shift_master/utils/theme.dart';
import 'package:shift_master/widgets/custom_app_bar.dart';
import 'package:shift_master/models/shift_model.dart';
import 'package:shift_master/services/firestore_service.dart';

class ShiftsScreen extends StatefulWidget {
  const ShiftsScreen({super.key});

  @override
  ShiftsScreenState createState() => ShiftsScreenState();
}

class ShiftsScreenState extends State<ShiftsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late Stream<List<ShiftData>> _shiftsStream;
  List<ShiftData> _shifts = [];

  @override
  void initState() {
    super.initState();
    _loadShifts();
  }

  void _loadShifts() {
    final user = _firestoreService.auth.currentUser;
    if (user != null) {
      _shiftsStream = _firestoreService.getShifts().map((shifts) {
        // Filter shifts for the current user and sort by start time in descending order
        return shifts.where((shift) => shift.employeeId == user.uid).toList()
          ..sort((a, b) => b.startTime.compareTo(a.startTime));
      });
      _shiftsStream.listen((shifts) {
        setState(() {
          _shifts = shifts;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Your Shifts"),
      drawer: const CustomEmployeeSidebar(),
      body: SingleChildScrollView(
        child: Container(
          color: AppTheme.backgroundColor2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShiftsList(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShiftsList(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Shifts',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.secondaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (_shifts.isEmpty)
              Center(
                child: Text(
                  'No shifts found.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textColor,
                      ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemCount: _shifts.length,
                itemBuilder: (context, index) {
                  final shift = _shifts[index];
                  return _buildShiftCard(context, shift);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildShiftCard(BuildContext context, ShiftData shift) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shift on ${_formatDate(shift.startTime)}',
              style: const TextStyle(
                color: AppTheme.secondaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start: ${_formatTime(shift.startTime)}',
              style: const TextStyle(
                color: AppTheme.textColor,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'End: ${_formatTime(shift.endTime)}',
              style: const TextStyle(
                color: AppTheme.textColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('MMM d, yyyy').format(dateTime);
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }
}
