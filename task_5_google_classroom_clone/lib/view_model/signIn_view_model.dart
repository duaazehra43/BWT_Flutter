import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_5_google_classroom_clone/service/auth_service.dart';

class SignInViewModel {
  final AuthService _authService = AuthService();

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      User? user = await _authService.signInWithEmail(email, password);
      return user;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<String> getUserRole(String uid) async {
    try {
      String role = await _authService.getUserRole(uid);
      return role;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      throw e.toString();
    }
  }
}
