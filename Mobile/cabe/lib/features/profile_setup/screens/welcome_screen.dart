import 'package:flutter/material.dart';
import 'package:cabe/core/theme/app_colors.dart';
import 'package:cabe/core/theme/app_text_styles.dart';
import 'package:cabe/features/profile_setup/controllers/welcome_controller.dart';

class WelcomeScreen extends StatefulWidget {
  final String userName;

  const WelcomeScreen({super.key, this.userName = 'User'});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final WelcomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WelcomeController();
    _controller.init(this, () {
      if (mounted) {
        _controller.goToHome(context);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blue900,
      body: Center(
        child: FadeTransition(
          opacity: _controller.fadeAnimation,
          child: ScaleTransition(
            scale: _controller.scaleAnimation,
            child: SafeArea(
              child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                Image.asset('assets/logo/logo_cabe_1.png', height: 120),
                const SizedBox(height: 24),

                // Welcome text
                Text(
                  'Welcome ${widget.userName}!',
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 40),

                // Loading indicator
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF5722)),
                    strokeWidth: 3,
                  ),
                ),
              ],
            ),
            ),
          ),
        ),
      ),
    );
  }
}
