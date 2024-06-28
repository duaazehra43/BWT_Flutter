import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_5_google_classroom_clone/view_model/reset_pass_view_model.dart';
import 'package:task_5_google_classroom_clone/views/login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final ResetPasswordViewModel _viewModel =
      ResetPasswordViewModel(); // ViewModel instance
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        title: Text(
          "Reset Password",
          style: GoogleFonts.lato(
            fontSize: 24,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 40),
                        TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: "Email",
                            labelStyle: GoogleFonts.lato(),
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                .hasMatch(value)) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                _isLoading = true;
                                _errorMessage = null;
                              });
                              try {
                                await _viewModel
                                    .resetPassword(emailController.text);
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignInScreen(),
                                  ),
                                );
                              } catch (e) {
                                setState(() {
                                  _errorMessage = e.toString();
                                  _isLoading = false;
                                });
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                            "Reset Password",
                            style: GoogleFonts.lato(fontSize: 16),
                          ),
                        ),
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: Colors.red),
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
