import 'package:flutter/material.dart';
import 'package:cabe/core/theme/app_colors.dart';
import 'package:cabe/core/theme/app_text_styles.dart';
import 'package:cabe/features/auth/widgets/auth_header.dart';
import 'package:cabe/features/auth/widgets/custom_text_field.dart';
import 'package:cabe/shared_widgets/app_button.dart';
import 'package:cabe/features/auth/controllers/forgot_password_controller.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final ForgotPasswordController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ForgotPasswordController();
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gray900),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const AuthHeader(),
                  const SizedBox(height: 32),

                  // Title
                  Text('Lupa Password?', style: AppTextStyles.h2),
                  const SizedBox(height: 8),
                  Text(
                    'Masukkan email yang terdaftar, kami akan\nmengirimkan link untuk mereset password Anda.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray500),
                  ),
                  const SizedBox(height: 32),

                  // Form
                  CustomTextField(
                    controller: _controller.emailController,
                    hintText: 'Email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 32),

                  _controller.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : AppButton(
                          label: 'Kirim Link Reset',
                          variant: AppButtonVariant.primary,
                          isFullWidth: true,
                          onPressed: () => _controller.sendResetLink(context),
                        ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
