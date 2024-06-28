import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_5_google_classroom_clone/service/auth_service.dart';

class SignUpViewModel {
  final AuthService _authService = AuthService();

  Future<User?> signUpWithEmailAndPassword(
      String email, String password, String name, String role) async {
    try {
      User? user =
          await _authService.signUpWithEmail(email, password, name, role);
      return user;
    } catch (e) {
      throw e.toString();
    }
  }
}
