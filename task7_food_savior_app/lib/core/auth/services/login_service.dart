import 'package:flutter/material.dart';
import 'package:task7_food_savior_app/core/donor/screens/home_screen.dart';
import 'package:task7_food_savior_app/core/receiver/screens/home_screen.dart';
import 'package:task7_food_savior_app/utils/extensions/scaffold.dart';
import 'package:task7_food_savior_app/core/auth/services/auth_service.dart';

class LoginViewModel {
  final AuthService _authService = AuthService();
  String email = '';
  String password = '';

  Future<bool> login(BuildContext context) async {
    try {
      final user =
          await _authService.signInWithEmailAndPassword(email, password);
      if (user != null) {
        final role = await _authService.getUserRole(user.uid);
        if (role == 'Donor') {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => HomeScreen(user: user)));
        } else if (role == 'Receiver') {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => RHomeScreen(user: user)));
        }
        context.showSnackBar('Login Successful');
        return true;
      }
    } catch (e) {
      context.showSnackBar('Login failed: ${e.toString()}');
    }
    return false;
  }
}
