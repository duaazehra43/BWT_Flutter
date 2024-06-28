import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_5_google_classroom_clone/views/home_screen_student.dart';
import 'package:task_5_google_classroom_clone/views/home_screen_teacher_screen.dart';
import 'package:task_5_google_classroom_clone/views/reg_screen.dart';
import 'package:task_5_google_classroom_clone/views/reset_pass.dart';
import 'package:task_5_google_classroom_clone/view_model/signIn_view_model.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isObscure = true;
  String? _errorMessage;

  final SignInViewModel _viewModel = SignInViewModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(
                  height: 40,
                ),
                Image.asset(
                  "assets/login.jpg",
                  height: 300,
                  width: double.infinity,
                ),
                Text("WELCOME BACK!",
                    style: GoogleFonts.lato(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple)),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: GoogleFonts.lato(),
                      prefixIcon: const Icon(Icons.email),
                      border: const OutlineInputBorder()),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: GoogleFonts.lato(),
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                      child: Icon(
                        _isObscure ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),
                  ),
                  obscureText: _isObscure,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        User? user =
                            await _viewModel.signInWithEmailAndPassword(
                                emailController.text, passwordController.text);

                        if (user != null) {
                          if (user.emailVerified) {
                            String role =
                                await _viewModel.getUserRole(user.uid);

                            if (role == 'Student') {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HomeScreenStudent(user),
                                ),
                              );
                            } else if (role == 'Teacher') {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HomeScreenTeacher(user),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Unknown user role'),
                                  duration: Duration(seconds: 5),
                                ),
                              );
                            }
                          } else {
                            await _viewModel.signOut();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.purple,
                                content: Text(
                                  'Please verify your email before logging in.',
                                  style: GoogleFonts.lato(color: Colors.white),
                                ),
                                duration: Duration(seconds: 5),
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Invalid email or password'),
                              duration: Duration(seconds: 5),
                            ),
                          );
                        }
                      } catch (e) {}
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white),
                  child: Text(
                    "Login",
                    style: GoogleFonts.lato(fontSize: 16),
                  ),
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ResetPasswordScreen()));
                  },
                  child: Text(
                    "Forgot Password?",
                    style: GoogleFonts.lato(fontSize: 16, color: Colors.purple),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SignUpScreen()));
                  },
                  child: Text(
                    "Don't have an account? Sign Up",
                    style: GoogleFonts.lato(fontSize: 16, color: Colors.purple),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
