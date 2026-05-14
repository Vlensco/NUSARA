import 'package:flutter/material.dart';
import 'package:cabe/features/profile_setup/screens/profile_setup_screen.dart';
import 'package:cabe/features/auth/screens/register_screen.dart';

class LoginController extends ChangeNotifier {
  bool obscurePassword = true;
  bool rememberMe = false;

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void toggleRememberMe(bool? value) {
    rememberMe = value ?? false;
    notifyListeners();
  }

  void login(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
      (route) => false,
    );
  }

  void goToRegister(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
  }
}
