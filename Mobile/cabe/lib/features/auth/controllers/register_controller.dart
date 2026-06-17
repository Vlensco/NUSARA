import 'package:flutter/material.dart';
import 'package:cabe/features/profile_setup/screens/profile_setup_screen.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterController extends ChangeNotifier {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

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

  Future<void> signUp(BuildContext context) async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showTopSnackBar(context, 'Tolong isi semua bidang');
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      // Daftarkan ke Firebase Auth
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        // Update display name
        await user.updateDisplayName(name);

        // Buat dokumen profil awal
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'nama_lengkap': name,
          'email': email,
          'setup_completed': false,  // Tandai belum setup profil
          'setup_step': 0,
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        });

        if (!context.mounted) return;
        _showTopSnackBar(context, 'Pendaftaran berhasil!', isSuccess: true);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'Email sudah terdaftar.';
          break;
        case 'weak-password':
          message = 'Password terlalu lemah (minimal 6 karakter).';
          break;
        case 'invalid-email':
          message = 'Format email tidak valid.';
          break;
        default:
          message = e.message ?? 'Terjadi kesalahan pendaftaran.';
      }
      _showTopSnackBar(context, message);
    } catch (e) {
      if (!context.mounted) return;
      _showTopSnackBar(context, 'Terjadi kesalahan yang tidak terduga.');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void goToLogin(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
