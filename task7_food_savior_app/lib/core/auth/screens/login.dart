import 'package:flutter/material.dart';
import 'package:task7_food_savior_app/core/auth/screens/sign_up.dart';
import 'package:task7_food_savior_app/utils/constants/colors.dart';
import 'package:task7_food_savior_app/utils/constants/icons.dart';
import 'package:task7_food_savior_app/utils/constants/text.dart';
import 'package:task7_food_savior_app/utils/extensions/sized_box.dart';
import 'package:task7_food_savior_app/utils/widgets/custom_buttons.dart';
import 'package:task7_food_savior_app/utils/widgets/custom_textfield.dart';
import 'package:task7_food_savior_app/core/auth/services/login_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final LoginViewModel _viewModel = LoginViewModel();
  bool _isLoading = false;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _viewModel.login(context);
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    80.height,
                    Image.asset(logoIcon),
                    20.height,
                    CustomTextField(
                      labelText: 'Email',
                      onChanged: (value) => _viewModel.email = value,
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter your email' : null,
                    ),
                    CustomTextField(
                      labelText: 'Password',
                      obscureText: true,
                      onChanged: (value) => _viewModel.password = value,
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter your password' : null,
                    ),
                    20.height,
                    CustomButton(
                      text: 'Login',
                      onPressed: _isLoading ? null : _login,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Don\'t have an account?'),
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const RegistrationScreen()));
                                },
                          child: Text(
                            'Register',
                            style: textButtonStyle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            ),
        ],
      ),
    );
  }
}
