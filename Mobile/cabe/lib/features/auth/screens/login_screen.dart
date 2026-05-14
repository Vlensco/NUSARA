import 'package:flutter/material.dart';
import 'package:cabe/core/theme/app_colors.dart';
import 'package:cabe/core/theme/app_text_styles.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cabe/features/auth/widgets/auth_header.dart';
import 'package:cabe/features/auth/widgets/custom_text_field.dart';
import 'package:cabe/features/auth/widgets/auth_widgets.dart';
import 'package:cabe/shared_widgets/app_button.dart';
import 'package:cabe/features/auth/controllers/login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final LoginController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LoginController();
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
                Text('Selamat Datang Kembali', style: AppTextStyles.h2),
                const SizedBox(height: 8),
                Text(
                  'Masuk untuk melanjutkan pencarian\nbeasiswa impianmu.',
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
                      const SizedBox(height: 12),

                      // Remember me & Forgot Password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _controller.rememberMe,
                                  onChanged: _controller.toggleRememberMe,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  side: const BorderSide(color: AppColors.gray400),
                                  activeColor: AppColors.blue900,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text('Remember me', style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray500)),
                            ],
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              'Forgot Password?',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.blue900,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      AppButton(
                        label: 'Login',
                        variant: AppButtonVariant.primary,
                        isFullWidth: true,
                        onPressed: () => _controller.login(context),
                      ),
                      const SizedBox(height: 32),
                      const OrDivider(),
                      const SizedBox(height: 24),
                      const SocialLoginRow(),
                      const SizedBox(height: 32),

                      AuthFooterLink(
                        text: "Don't have account? ",
                        actionText: 'Sign Up',
                        onTap: () => _controller.goToRegister(context),
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
