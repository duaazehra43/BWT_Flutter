import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task7_food_savior_app/core/auth/screens/login.dart';
import 'package:task7_food_savior_app/utils/extensions/scaffold.dart';
import 'package:task7_food_savior_app/core/auth/services/auth_manager.dart';

class RegistrationViewModel {
  String name = '';
  String email = '';
  String phone = '';
  String address = '';
  String password = '';
  String role = 'Donor';

  Future<bool> register(BuildContext context) async {
    final authManager = Provider.of<AuthManager>(context, listen: false);
    try {
      await authManager.signUp(
        name: name,
        email: email,
        phone: phone,
        address: address,
        password: password,
        role: role,
      );
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const LoginScreen()));
      context.showSnackBar('Registration Successful');
      return true;
    } catch (e) {
      context.showSnackBar('Registration failed: ${e.toString()}');
      return false;
    }
  }
}
