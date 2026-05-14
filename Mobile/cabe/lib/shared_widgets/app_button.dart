import 'package:flutter/material.dart';
import 'package:cabe/core/theme/app_colors.dart';
import 'package:cabe/core/theme/app_text_styles.dart';

enum AppButtonVariant { primary, secondary, outline, text, disabled }

class AppButton extends StatelessWidget {
  final String label;
  final AppButtonVariant variant;
  final VoidCallback? onPressed;
  final bool isFullWidth;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const AppButton({
    super.key,
    required this.label,
    this.variant = AppButtonVariant.primary,
    this.onPressed,
    this.isFullWidth = false,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case AppButtonVariant.primary:
        return _buildPrimary();
      case AppButtonVariant.secondary:
        return _buildSecondary();
      case AppButtonVariant.outline:
        return _buildOutline();
      case AppButtonVariant.text:
        return _buildText();
      case AppButtonVariant.disabled:
        return _buildDisabled();
    }
  }

  Widget _buildDisabled() {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: onPressed, // Keep it clickable so we can show validation message!
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.coolGray200,
          foregroundColor: AppColors.coolGray400,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _buildLabel(color: AppColors.coolGray400),
      ),
    );
  }

  Widget _buildPrimary() {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blue900,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _buildLabel(color: AppColors.white),
      ),
    );
  }

  Widget _buildSecondary() {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.coolGray200,
          foregroundColor: AppColors.blue900,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _buildLabel(color: AppColors.blue900),
      ),
    );
  }

  Widget _buildOutline() {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.blue900,
          side: const BorderSide(color: AppColors.blue900, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _buildLabel(color: AppColors.blue900),
      ),
    );
  }

  Widget _buildText() {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.blue500,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      child: _buildLabel(color: AppColors.blue500),
    );
  }

  Widget _buildLabel({required Color color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (prefixIcon != null) ...[
          prefixIcon!,
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: AppTextStyles.labelLarge.copyWith(color: color),
        ),
        if (suffixIcon != null) ...[
          const SizedBox(width: 8),
          suffixIcon!,
        ],
      ],
    );
  }
}
