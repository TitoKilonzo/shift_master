import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shift_master/models/employee_model.dart';
import 'package:shift_master/models/report_model.dart';
import 'package:shift_master/models/shift_model.dart';
import 'package:shift_master/utils/password_generator.dart';

class FirestoreService {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Add this method to your FirestoreService class
  Future<void> createFirstAdminUser() async {
    try {
      // First, create the authentication account
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: 'opiyodon9@gmail.com',
        password: 'donartkins',
      );

      // Create the employee document for the admin
      Employee adminEmployee = Employee(
        id: userCredential.user!.uid,
        name: 'Don Artkins',
        email: 'opiyodon9@gmail.com',
        department: 'Management',
        position: 'Developer',
        role: 'admin',
        createdAt: Timestamp.now(),
      );

      // Save employee data to Firestore
      await db.collection('employees').doc(userCredential.user!.uid).set(
        adminEmployee.toMap(),
        SetOptions(merge: true),
      );
    } catch (e) {
      print('Error creating first admin user: $e');
      rethrow;
    }
  }

  // Add this method to the FirestoreService class
  Future<Map<String, dynamic>?> getUserDetailsByEmail(String email) async {
    try {
      final querySnapshot = await db
          .collection('employees')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      final userData = querySnapshot.docs.first.data();
      userData['id'] = querySnapshot.docs.first.id;
      return userData;
    } catch (e) {
      print('Error fetching user details: $e');
      return null;
    }
  }

  // Add this method to your FirestoreService class in firestore_service.dart
  Future<Employee?> getUser(String uid) async {
    try {
      final docSnapshot = await db.collection('employees').doc(uid).get();

      if (!docSnapshot.exists) {
        return null;
      }

      // Use null-aware spread operator and provide an empty map as fallback
      final data = docSnapshot.data() ?? {};

      // Convert the document data to an Employee object
      return Employee.fromMap({...data, 'id': docSnapshot.id});
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final docSnapshot = await db.collection('employees').doc(uid).get();

      if (!docSnapshot.exists) {
        return null;
      }

      // Return the document data with the ID included
      return {...docSnapshot.data() ?? {}, 'id': docSnapshot.id};
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  Future<String> addEmployeeWithAuth(Employee employee) async {
    String? authUserId;
    try {
      // Generate password
      String password =
      PasswordGenerator.generatePassword(employee.name, employee.email);

      // Create authentication account
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: employee.email,
        password: password,
      );

      authUserId = userCredential.user!.uid;

      // Create employee document with the auth UID
      Employee employeeWithId = Employee(
        id: authUserId,
        name: employee.name,
        email: employee.email,
        department: employee.department,
        position: employee.position,
        role: employee.role,
        createdAt: Timestamp.now(),
      );

      // Save employee data to Firestore
      await db.collection('employees').doc(authUserId).set(
        employeeWithId.toMap(),
        SetOptions(merge: true),
      );

      return password;
    } catch (e) {
      // Cleanup any partial creation
      if (authUserId != null) {
        await rollbackEmployeeCreation(authUserId, authUserId);
      }
      rethrow;
    }
  }

  Future<bool> isUserAdmin() async {
    try {
      final currentUser = auth.currentUser;
      if (currentUser == null) return false;

      final userDoc =
      await db.collection('employees').doc(currentUser.uid).get();

      return userDoc.exists && userDoc.data()?['role'] == 'admin';
    } catch (e) {
      return false;
    }
  }

  Future<String?> getUserIdByEmail(String email) async {
    try {
      final querySnapshot = await db
          .collection('employees')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;
      return querySnapshot.docs.first.id;
    } catch (e) {
      return null;
    }
  }

  Future<void> rollbackEmployeeCreation(
      String? authUserId, String? employeeDocId) async {
    try {
      if (authUserId != null) {
        final user = auth.currentUser;
        if (user != null && user.uid == authUserId) {
          await user.delete();
        }
      }

      if (employeeDocId != null) {
        await db.collection('employees').doc(employeeDocId).delete();
      }
    } catch (e) {
      print('Error during rollback: $e');
    }
  }

  Future<void> deleteEmployee(String id) async {
    try {
      final currentUser = auth.currentUser;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      final isAdmin = await isUserAdmin();
      if (!isAdmin && currentUser.uid != id) {
        throw Exception(
            'Unauthorized: Only admins or the account owner can delete this account');
      }

      final employeeDoc = await db.collection('employees').doc(id).get();
      if (!employeeDoc.exists) {
        throw Exception('Employee not found');
      }

      final employeeEmail = employeeDoc.data()?['email'];
      if (employeeEmail == null) {
        throw Exception('Invalid employee data');
      }

      // Delete from Firestore first
      await db.collection('employees').doc(id).delete();

      // Delete from Authentication
      if (!isAdmin && currentUser.uid == id) {
        await currentUser.delete();
      } else {
        // For free tier, we can't delete other users' auth accounts
        print(
            'Warning: Unable to delete authentication account for other users in free tier');
      }
    } catch (e) {
      print('Error in deleteEmployee: $e');
      rethrow;
    }
  }

  Future<void> rollbackDeletion(String id, Map<String, dynamic>? data) async {
    try {
      if (data != null) {
        await db.collection('employees').doc(id).set(data);
      }
    } catch (e) {
      print('Error during deletion rollback: $e');
    }
  }

  Stream<List<Employee>> getEmployees() {
    return db.collection('employees').snapshots().map((snapshot) => snapshot
        .docs
        .map((doc) => Employee.fromMap({...doc.data(), 'id': doc.id}))
        .toList());
  }

  Future<List<Map<String, dynamic>>> fetchEmployeesList() async {
    QuerySnapshot snapshot = await db.collection('employees').get();
    return snapshot.docs
        .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
        .toList();
  }

  Future<List<Employee>> fetchInitialEmployees() async {
    final snapshot = await db.collection('employees').get();
    return snapshot.docs
        .map((doc) => Employee.fromMap({...doc.data(), 'id': doc.id}))
        .toList();
  }

  Future<void> createShift(ShiftData shift) async {
    try {
      await db.collection('shifts').add(shift.toMap());
    } catch (e) {
      print('Error creating shift: $e');
      rethrow;
    }
  }

  Future<void> deleteShift(String id) async {
    try {
      await db.collection('shifts').doc(id).delete();
    } catch (e) {
      print('Error deleting shift: $e');
      rethrow;
    }
  }

  Future<void> clearAllShifts() async {
    WriteBatch batch = db.batch();

    // Get all shifts
    QuerySnapshot shiftsSnapshot = await db.collection('shifts').get();

    // Add delete operations to batch
    for (var doc in shiftsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // Commit the batch
    await batch.commit();
  }

  Stream<List<ShiftData>> getShifts() {
    return db.collection('shifts').snapshots().map((snapshot) => snapshot.docs
        .map((doc) => ShiftData.fromMap(doc.id, doc.data()))
        .toList());
  }

  // New method to fetch only active shifts
  Stream<List<ShiftData>> getActiveShifts() {
    final now = Timestamp.now();
    return db
        .collection('shifts')
        .where('startTime', isLessThanOrEqualTo: now)
        .where('endTime', isGreaterThanOrEqualTo: now)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ShiftData.fromMap(doc.id, doc.data()))
        .toList());
  }

  Future<String> saveReport({
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    required bool fileUrl,
    required int totalRecords,
  }) async {
    try {
      final reportRef = await db.collection('reports').add({
        'type': type,
        'startDate': startDate,
        'endDate': endDate,
        'generatedAt': FieldValue.serverTimestamp(),
        'fileUrl': fileUrl,
        'totalRecords': totalRecords,
      });
      return reportRef.id;
    } catch (e) {
      print('Error saving report: $e');
      rethrow;
    }
  }

  Stream<List<Report>> getReports() {
    return db
        .collection('reports')
        .orderBy('generatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Report.fromMap(doc.id, doc.data()))
        .toList());
  }

  Future<void> deleteReport(String reportId) async {
    try {
      await db.collection('reports').doc(reportId).delete();
    } catch (e) {
      print('Error deleting report: $e');
      rethrow;
    }
  }
}