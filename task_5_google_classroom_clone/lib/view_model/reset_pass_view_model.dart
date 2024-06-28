import 'package:task_5_google_classroom_clone/service/auth_service.dart';

class ResetPasswordViewModel {
  final AuthService _authService = AuthService();

  Future<void> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
    } catch (e) {
      throw e.toString();
    }
  }
}
