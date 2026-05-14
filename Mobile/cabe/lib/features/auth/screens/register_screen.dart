import 'package:flutter/material.dart';
import 'package:cabe/core/theme/app_colors.dart';
import 'package:cabe/core/theme/app_text_styles.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cabe/features/auth/widgets/auth_header.dart';
import 'package:cabe/features/auth/widgets/custom_text_field.dart';
import 'package:cabe/features/auth/widgets/auth_widgets.dart';
import 'package:cabe/shared_widgets/app_button.dart';
import 'package:cabe/features/auth/controllers/register_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final RegisterController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RegisterController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
              children: [
                const AuthHeader(),
                const SizedBox(height: 32),

                // Title
                Text('Daftar Akun Baru', style: AppTextStyles.h2),
                const SizedBox(height: 8),
                Text(
                  'Mulai langkah pertamamu menuju masa\ndepan cerah.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray500),
                ),
                const SizedBox(height: 32),

                // Form
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const CustomTextField(
                        hintText: 'Nama Lengkap',
                        keyboardType: TextInputType.name,
                      ),
                      const SizedBox(height: 16),
                      const CustomTextField(
                        hintText: 'Email',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        hintText: 'Password',
                        obscureText: _controller.obscurePassword,
                        keyboardType: TextInputType.visiblePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _controller.obscurePassword ? LucideIcons.eye : LucideIcons.eyeOff,
                            color: AppColors.gray400,
                          ),
                          onPressed: _controller.togglePasswordVisibility,
                        ),
                      ),
                      const SizedBox(height: 32),

                      AppButton(
                        label: 'Sign Up',
                        variant: AppButtonVariant.primary,
                        isFullWidth: true,
                        onPressed: () => _controller.signUp(context),
                      ),
                      const SizedBox(height: 32),
                      const OrDivider(text: 'or Sign Up with'),
                      const SizedBox(height: 24),
                      const SocialLoginRow(),
                      const SizedBox(height: 32),

                      AuthFooterLink(
                        text: 'Already have account? ',
                        actionText: 'Login',
                        onTap: () => _controller.goToLogin(context),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      ),
    );
  }
}
