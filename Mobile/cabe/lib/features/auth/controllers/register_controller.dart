import 'package:flutter/material.dart';
import 'package:cabe/features/profile_setup/screens/profile_setup_screen.dart';

class RegisterController extends ChangeNotifier {
  bool obscurePassword = true;

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void signUp(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
      (route) => false,
    );
  }

  void goToLogin(BuildContext context) {
    Navigator.pop(context);
  }
}
