import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_6_e_commerce_app/SignupScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_6_e_commerce_app/module/seller/view/home_screen_dashboard.dart';
import 'package:task_6_e_commerce_app/module/buyer/homeScreen.dart';
import 'package:task_6_e_commerce_app/service/authService.dart';
import 'package:task_6_e_commerce_app/module/admin/view/adminScreen.dart'; // Import the AdminScreen

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        User? user = await _authService.signInWithEmail(
          _emailController.text,
          _passwordController.text,
        );
        if (user != null) {
          if (_emailController.text == 'dua@gmail.com') {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => AdminScreen()),
              (Route<dynamic> route) => false,
            );
            return; // Exit the function to avoid further checks
          }

          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
          String role = userDoc['role'];

          if (role == 'Buyer') {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => HomeScreen(user)),
              (Route<dynamic> route) => false,
            );
          } else if (role == 'Seller') {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) => HomeScreenDashboard(user)),
              (Route<dynamic> route) => false,
            );
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Logged in successfully',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.black,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to log in',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.black,
            ),
          );
        }
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 60),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    "Login to your account",
                    style: GoogleFonts.inter(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Text(
                    "Welcome back, please login to your account.",
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  "Email",
                  style: GoogleFonts.inter(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 5),
                Card(
                  color: Colors.white,
                  elevation: 3.0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter your email address",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email address';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Password",
                  style: GoogleFonts.inter(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 5),
                Card(
                  color: Colors.white,
                  elevation: 3.0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter your password",
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(200, 50),
                    ),
                    child: Text(
                      "Login",
                      style: GoogleFonts.inter(fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 20), // Adjust the height if needed
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: GoogleFonts.inter(color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignUpScreen()));
                      },
                      child: Text(
                        "Sign Up",
                        style: GoogleFonts.inter(
                          decoration: TextDecoration.underline,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
