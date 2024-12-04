import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shift_master/services/firestore_service.dart';
import 'package:shift_master/widgets/custom_sidebar.dart';
import 'package:shift_master/utils/theme.dart';
import 'package:shift_master/widgets/custom_app_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  late Stream<List<Map<String, dynamic>>> _employeesStream;
  late Stream<List<Map<String, dynamic>>> _shiftsStream;
  late Stream<List<Map<String, dynamic>>> _activeShiftsStream;
  int _totalEmployees = 0;
  int _activeShifts = 0;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() {
    // Fetch employees
    _employeesStream = FirebaseFirestore.instance
        .collection('employees')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());

    // Fetch current week's shifts
    _shiftsStream = _getCurrentWeekShifts();

    // Fetch active shifts
    _activeShiftsStream = _firestoreService
        .getActiveShifts()
        .map((shifts) => shifts.map((shift) => shift.toMap()).toList());

    _employeesStream.listen((employees) {
      setState(() {
        _totalEmployees = employees.length;
      });
    });

    _activeShiftsStream.listen((activeShifts) {
      setState(() {
        _activeShifts = activeShifts.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Dashboard"),
      drawer: const CustomSidebar(),
      body: SingleChildScrollView(
        child: Container(
          color: AppTheme.backgroundColor2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeCard(context),
                const SizedBox(height: 24),
                _buildSummaryCards(context),
                const SizedBox(height: 24),
                _buildShiftDistribution(context),
                const SizedBox(height: 24),
                _buildWeeklyShiftChart(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, Admin!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Here\'s an overview of your Shift Master dashboard.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSummaryCard(
            context, 'Total Employees', '$_totalEmployees', Icons.people),
        _buildSummaryCard(
            context, 'Active Shifts', '$_activeShifts', Icons.access_time),
      ],
    );
  }

  Widget _buildSummaryCard(
      BuildContext context, String title, String value, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: AppTheme.primaryColor),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.secondaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Stream<List<Map<String, dynamic>>> _getCurrentWeekShifts() {
    // Get the current week's start and end dates
    DateTime now = DateTime.now();
    DateTime weekStart = now.subtract(Duration(days: now.weekday - 1));
    DateTime weekEnd = weekStart.add(const Duration(days: 7));

    // Convert to Timestamps for Firestore query
    Timestamp startTimestamp = Timestamp.fromDate(weekStart);
    Timestamp endTimestamp = Timestamp.fromDate(weekEnd);

    return FirebaseFirestore.instance
        .collection('shifts')
        .where('startTime', isGreaterThanOrEqualTo: startTimestamp)
        .where('startTime', isLessThan: endTimestamp)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
  }

  Widget _buildShiftDistribution(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _shiftsStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final shifts = snapshot.data!;

          // Categorize shifts into Morning, Afternoon, Night
          final morningShifts = shifts.where((shift) {
            final startTime = DateTime.fromMillisecondsSinceEpoch(
                (shift['startTime'] as Timestamp).millisecondsSinceEpoch);
            return startTime.hour >= 6 && startTime.hour < 12;
          }).toList();

          final afternoonShifts = shifts.where((shift) {
            final startTime = DateTime.fromMillisecondsSinceEpoch(
                (shift['startTime'] as Timestamp).millisecondsSinceEpoch);
            return startTime.hour >= 12 && startTime.hour < 18;
          }).toList();

          final nightShifts = shifts.where((shift) {
            final startTime = DateTime.fromMillisecondsSinceEpoch(
                (shift['startTime'] as Timestamp).millisecondsSinceEpoch);
            return startTime.hour >= 18 || startTime.hour < 6;
          }).toList();

          return Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This Week\'s Shift Distribution',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.secondaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildShiftTypeDetails(
                          'Morning', morningShifts, AppTheme.primaryColor),
                      _buildShiftTypeDetails('Afternoon', afternoonShifts,
                          AppTheme.secondaryColor),
                      _buildShiftTypeDetails(
                          'Night', nightShifts, AppTheme.accentColor),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          _createPieChartSectionData(
                              morningShifts.length.toDouble(),
                              'Morning',
                              AppTheme.primaryColor),
                          _createPieChartSectionData(
                              afternoonShifts.length.toDouble(),
                              'Afternoon',
                              AppTheme.secondaryColor),
                          _createPieChartSectionData(
                              nightShifts.length.toDouble(),
                              'Night',
                              AppTheme.accentColor),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  Widget _buildShiftTypeDetails(
      String type, List<Map<String, dynamic>> shifts, Color color) {
    return Column(
      children: [
        Text(
          type,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '${shifts.length} Shifts',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  PieChartSectionData _createPieChartSectionData(
      double value, String title, Color color) {
    return PieChartSectionData(
      color: color,
      value: value,
      title: title,
      radius: 50,
      titleStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildWeeklyShiftChart(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _shiftsStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final shifts = snapshot.data!;

          // Create a map to store shifts for each day of the week
          final weeklyShifts = {
            'Mon': shifts
                .where((shift) =>
                    _getDayOfWeek(DateTime.fromMillisecondsSinceEpoch(
                        (shift['startTime'] as Timestamp)
                            .millisecondsSinceEpoch)) ==
                    'Mon')
                .length,
            'Tue': shifts
                .where((shift) =>
                    _getDayOfWeek(DateTime.fromMillisecondsSinceEpoch(
                        (shift['startTime'] as Timestamp)
                            .millisecondsSinceEpoch)) ==
                    'Tue')
                .length,
            'Wed': shifts
                .where((shift) =>
                    _getDayOfWeek(DateTime.fromMillisecondsSinceEpoch(
                        (shift['startTime'] as Timestamp)
                            .millisecondsSinceEpoch)) ==
                    'Wed')
                .length,
            'Thu': shifts
                .where((shift) =>
                    _getDayOfWeek(DateTime.fromMillisecondsSinceEpoch(
                        (shift['startTime'] as Timestamp)
                            .millisecondsSinceEpoch)) ==
                    'Thu')
                .length,
            'Fri': shifts
                .where((shift) =>
                    _getDayOfWeek(DateTime.fromMillisecondsSinceEpoch(
                        (shift['startTime'] as Timestamp)
                            .millisecondsSinceEpoch)) ==
                    'Fri')
                .length,
            'Sat': shifts
                .where((shift) =>
                    _getDayOfWeek(DateTime.fromMillisecondsSinceEpoch(
                        (shift['startTime'] as Timestamp)
                            .millisecondsSinceEpoch)) ==
                    'Sat')
                .length,
            'Sun': shifts
                .where((shift) =>
                    _getDayOfWeek(DateTime.fromMillisecondsSinceEpoch(
                        (shift['startTime'] as Timestamp)
                            .millisecondsSinceEpoch)) ==
                    'Sun')
                .length,
          };

          return Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weekly Shift Overview',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.secondaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: weeklyShifts.entries.map((entry) {
                        return Column(
                          children: [
                            Text(
                              entry.key,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textColor,
                              ),
                            ),
                            Text(
                              '${entry.value} Shifts',
                              style: const TextStyle(
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: weeklyShifts.values.reduce(max).toDouble(),
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) => Text(
                                weeklyShifts.keys.elementAt(value.toInt()),
                                style:
                                    const TextStyle(color: AppTheme.textColor),
                              ),
                            ),
                          ),
                          leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(
                          weeklyShifts.length,
                          (index) => BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: weeklyShifts.values
                                    .elementAt(index)
                                    .toDouble(),
                                color: AppTheme.primaryColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  // Existing method
  String _getDayOfWeek(DateTime dateTime) {
    return DateFormat('EEE').format(dateTime);
  }
}
