import 'package:flutter/material.dart';
import 'package:cabe/core/theme/app_colors.dart';
import 'package:cabe/core/theme/app_text_styles.dart';
import 'package:cabe/features/auth/widgets/social_button.dart';

/// Reusable social login 
class SocialLoginRow extends StatelessWidget {
  const SocialLoginRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SocialButton(
          icon: Image.asset('assets/login/facebook.png', width: 28, height: 28),
          backgroundColor: AppColors.white,
          borderColor: AppColors.gray200,
          onTap: () {},
        ),
        const SizedBox(width: 20),
        SocialButton(
          icon: Image.asset('assets/login/google.png', width: 28, height: 28),
          backgroundColor: AppColors.white,
          borderColor: AppColors.gray200,
          onTap: () {},
        ),
      ],
    );
  }
}

/// Reusable divider row.
class OrDivider extends StatelessWidget {
  final String text;
  const OrDivider({super.key, this.text = 'or login with'});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.gray200)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray400),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.gray200)),
      ],
    );
  }
}

/// Reusable auth footer link (e.g. "Don't have account? Sign Up").
class AuthFooterLink extends StatelessWidget {
  final String text;
  final String actionText;
  final VoidCallback onTap;

  const AuthFooterLink({
    super.key,
    required this.text,
    required this.actionText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray500),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            actionText,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.blue900,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
