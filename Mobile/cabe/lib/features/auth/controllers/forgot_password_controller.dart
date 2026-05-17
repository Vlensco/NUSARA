import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordController extends ChangeNotifier {
  final emailController = TextEditingController();
  bool isLoading = false;

  void _showTopSnackBar(BuildContext context, String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 150,
          left: 20,
          right: 20,
        ),
        duration: const Duration(seconds: 3),
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }

  Future<void> sendResetLink(BuildContext context) async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      _showTopSnackBar(context, 'Tolong masukkan email Anda.');
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!context.mounted) return;
      _showTopSnackBar(context, 'Link reset password telah dikirim ke email Anda.', isSuccess: true);
      Navigator.pop(context); // Kembali ke halaman login
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Email tidak terdaftar.';
          break;
        case 'invalid-email':
          message = 'Format email tidak valid.';
          break;
        default:
          message = e.message ?? 'Terjadi kesalahan. Coba lagi nanti.';
      }
      _showTopSnackBar(context, message);
    } catch (e) {
      if (!context.mounted) return;
      _showTopSnackBar(context, 'Terjadi kesalahan. Coba lagi nanti.');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}
