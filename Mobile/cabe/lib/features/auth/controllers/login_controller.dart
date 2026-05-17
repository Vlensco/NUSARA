import 'package:flutter/material.dart';
import 'package:cabe/core/routing/main_navigation.dart';
import 'package:cabe/features/auth/screens/register_screen.dart';
import 'package:cabe/features/auth/screens/forgot_password_screen.dart';
import 'package:cabe/features/profile_setup/screens/profile_setup_screen.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginController extends ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool rememberMe = false;
  bool isLoading = false;
  bool isGoogleLoading = false;

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void toggleRememberMe(bool? value) {
    rememberMe = value ?? false;
    notifyListeners();
  }

  void _showSnackBar(BuildContext context, String message, {bool isSuccess = false}) {
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

  // Email/Password Login 
  Future<void> login(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar(context, 'Email dan password tidak boleh kosong');
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        if (!context.mounted) return;
        _showSnackBar(context, 'Login berhasil!', isSuccess: true);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainNavigation()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Email tidak terdaftar.';
          break;
        case 'wrong-password':
          message = 'Password salah.';
          break;
        case 'invalid-credential':
          message = 'Email atau password salah.';
          break;
        case 'user-disabled':
          message = 'Akun ini telah dinonaktifkan.';
          break;
        case 'too-many-requests':
          message = 'Terlalu banyak percobaan. Coba lagi nanti.';
          break;
        default:
          message = e.message ?? 'Terjadi kesalahan autentikasi.';
      }
      _showSnackBar(context, message);
    } catch (e) {
      if (!context.mounted) return;
      _showSnackBar(context, 'Terjadi kesalahan yang tidak terduga.');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Google Sign-In
  Future<void> signInWithGoogle(BuildContext context) async {
    isGoogleLoading = true;
    notifyListeners();

    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // User membatalkan
        isGoogleLoading = false;
        notifyListeners();
        return;
      }

      // Ambil auth details dari Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Buat credential Firebase dari Google
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Login ke Firebase dengan credential Google
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        // Cek apakah user baru belum punya profil di Firestore
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        final isNewUser = !doc.exists;

        if (isNewUser) {
          // Buat dokumen profil user baru
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'nama_lengkap': user.displayName ?? '',
            'email': user.email ?? '',
            'created_at': FieldValue.serverTimestamp(),
            'updated_at': FieldValue.serverTimestamp(),
          });
        }

        if (!context.mounted) return;
        _showSnackBar(context, 'Login dengan Google berhasil!', isSuccess: true);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => isNewUser ? const ProfileSetupScreen() : const MainNavigation(),
          ),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      _showSnackBar(context, e.message ?? 'Gagal login dengan Google.');
    } catch (e) {
      if (!context.mounted) return;
      _showSnackBar(context, 'Terjadi kesalahan: $e');
    } finally {
      isGoogleLoading = false;
      notifyListeners();
    }
  }

  void goToRegister(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
  }

  void goToForgotPassword(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()));
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
