import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task7_food_savior_app/utils/constants/colors.dart';
import 'package:task7_food_savior_app/utils/constants/icons.dart';
import 'package:task7_food_savior_app/utils/extensions/sized_box.dart';
import 'package:task7_food_savior_app/utils/widgets/custom_buttons.dart';
import 'package:task7_food_savior_app/utils/widgets/custom_textfield.dart';
import 'package:task7_food_savior_app/core/auth/services/login_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final LoginViewModel _viewModel = LoginViewModel();

  void _login() async {
    if (_formKey.currentState!.validate()) {
      await _viewModel.login(context);
    }
  }

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
                  onPressed: _login,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Don\'t have an account?'),
                    TextButton(
                      onPressed: () {
                        context.push('/register');
                      },
                      child: Text(
                        'Register',
                        style: GoogleFonts.inter(
                            color: textColor, fontWeight: FontWeight.bold),
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
