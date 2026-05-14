import 'package:flutter/material.dart';
import 'package:cabe/core/theme/app_colors.dart';
import 'package:cabe/core/theme/app_text_styles.dart';
import 'package:cabe/features/auth/screens/login_screen.dart';
import 'package:cabe/features/auth/screens/register_screen.dart';
import 'package:cabe/features/auth/widgets/auth_header.dart';
import 'package:cabe/features/auth/widgets/auth_widgets.dart';
import 'package:cabe/shared_widgets/app_button.dart';

class AuthLandingScreen extends StatelessWidget {
  const AuthLandingScreen({super.key});

  // ── Navigation Logic ──
  void _goToLogin(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  void _goToRegister(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
  }

  // ── Build ──
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
          children: [
            const AuthHeader(),
            const SizedBox(height: 32),

            // Illustration
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Image.asset('assets/login/login1.png', height: 180, fit: BoxFit.contain),
            ),
            const SizedBox(height: 16),

            // Tagline
            Text(
              'Raih Mimpimu,\nTemukan Beasiswamu.',
              textAlign: TextAlign.center,
              style: AppTextStyles.h3.copyWith(color: AppColors.gray700, height: 1.4),
            ),
            const SizedBox(height: 40),

            // Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  AppButton(
                    label: 'Login',
                    variant: AppButtonVariant.primary,
                    isFullWidth: true,
                    onPressed: () => _goToLogin(context),
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: 'Sign Up',
                    variant: AppButtonVariant.outline,
                    isFullWidth: true,
                    onPressed: () => _goToRegister(context),
                  ),
                  const SizedBox(height: 28),
                  const OrDivider(),
                  const SizedBox(height: 20),
                  const SocialLoginRow(),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
        ),
      ),
    );
  }
}
