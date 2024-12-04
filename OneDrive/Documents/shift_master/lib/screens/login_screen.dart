import 'package:flutter/material.dart';
import 'package:shift_master/screens/loading_screen_dart.dart';
import 'package:shift_master/services/firebase_service.dart';
import 'package:shift_master/utils/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();

  bool _isLoading = false;
  String _selectedUserType = 'employee'; // Default user type

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Attempt to login and get user details
      final userDetails = await _firebaseService.login(
          _emailController.text, _passwordController.text);

      // Check if the selected user type matches the user's role
      if (userDetails['role'] != _selectedUserType) {
        throw Exception('Invalid user type selected');
      }

      // Navigate based on user type
      if (_selectedUserType == 'admin') {
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/employee');
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Attempt to login with Google and get user details
      final userDetails = await _firebaseService.signInWithGoogle();

      // Check if the selected user type matches the user's role
      if (userDetails['role'] != _selectedUserType) {
        throw Exception('Invalid user type selected');
      }

      // Navigate based on user type
      if (_selectedUserType == 'admin') {
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/employee');
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      loadingMessage: 'Logging in...',
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Shift Master',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Login to your account',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person,
                        size: 60, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(height: 24),

                  // User Type Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedUserType,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person_outline,
                          color: AppTheme.primaryColor),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'employee',
                        child: Text('Employee'),
                      ),
                      DropdownMenuItem(
                        value: 'admin',
                        child: Text('Admin'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedUserType = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      hintText: "Email",
                      prefixIcon:
                          Icon(Icons.email, color: AppTheme.primaryColor),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      hintText: "Password",
                      prefixIcon:
                          Icon(Icons.lock, color: AppTheme.primaryColor),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 8),
                  // Align(
                  //   alignment: Alignment.centerRight,
                  //   child: TextButton(
                  //     onPressed: () {
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //             builder: (context) =>
                  //                 const ForgotPasswordScreen()),
                  //       );
                  //     },
                  //     child: const Text(
                  //       "Forgot Password?",
                  //       style: TextStyle(color: AppTheme.accentColor),
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                            "LOGIN",
                            style: TextStyle(color: AppTheme.textColor2),
                          ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Sign in with:",
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: Image.asset('assets/images/google.png',
                        width: 24, height: 24),
                    label: const Text('Sign in with Google'),
                    onPressed: _signInWithGoogle,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
