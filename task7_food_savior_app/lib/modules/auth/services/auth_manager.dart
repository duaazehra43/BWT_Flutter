import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task7_food_savior_app/modules/auth/services/auth_service.dart';

class AuthManager extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;

  User? get user => _user;

  Future<void> signIn(String email, String password) async {
    _user = await _authService.signInWithEmailAndPassword(email, password);
    notifyListeners();
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String password,
    required String role,
  }) async {
    _user = await _authService.createUserWithEmailAndPassword(
      name: name,
      email: email,
      phone: phone,
      address: address,
      password: password,
      role: role,
    );
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  bool get isSignedIn => _user != null;
}
