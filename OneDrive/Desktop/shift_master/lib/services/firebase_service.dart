import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shift_master/services/firestore_service.dart';

class FirebaseService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirestoreService _firestoreService = FirestoreService();

  // Login user with user type check
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch user details from Firestore
      final userDetails = await _firestoreService.getUserDetailsByEmail(email);

      if (userDetails == null) {
        throw Exception('User not found in the system');
      }

      return userDetails;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Google Sign In
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return {};

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await auth.signInWithCredential(credential);

      // Check if user exists in employees collection with the specific email
      final userDetails = await _firestoreService
          .getUserDetailsByEmail(userCredential.user!.email!);

      if (userDetails == null) {
        // If not found in employees, throw an exception
        throw Exception('User not registered in the system');
      }

      return userDetails;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Logout user
  Future<void> logout() async {
    await auth.signOut();
    await _googleSignIn.signOut();
  }

  // Check if user is logged in
  bool isUserLoggedIn() {
    return auth.currentUser != null;
  }
}
