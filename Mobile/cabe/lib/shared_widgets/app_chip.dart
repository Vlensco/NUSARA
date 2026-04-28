import 'package:flutter/material.dart';
import 'package:cabe/core/theme/app_colors.dart';
import 'package:cabe/core/theme/app_text_styles.dart';

enum AppChipVariant { outline, light, filled, disabled }

class AppChip extends StatelessWidget {
  final String label;
  final AppChipVariant variant;
  final VoidCallback? onTap;
  final bool isSelected;

  const AppChip({
    super.key,
    required this.label,
    this.variant = AppChipVariant.light,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: variant == AppChipVariant.disabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(100),
          border: _border,
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: _textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Color get _backgroundColor {
    switch (variant) {
      case AppChipVariant.outline:
        return Colors.transparent;
      case AppChipVariant.light:
        return AppColors.coolGray100;
      case AppChipVariant.filled:
        return AppColors.blue900;
      case AppChipVariant.disabled:
        return AppColors.coolGray100;
    }
  }

  Border? get _border {
    switch (variant) {
      case AppChipVariant.outline:
        return Border.all(color: AppColors.coolGray300, width: 1);
      case AppChipVariant.disabled:
        return Border.all(color: AppColors.coolGray200, width: 1);
      default:
        return null;
    }
  }

  Color get _textColor {
    switch (variant) {
      case AppChipVariant.outline:
        return AppColors.coolGray400;
      case AppChipVariant.light:
        return AppColors.gray700;
      case AppChipVariant.filled:
        return AppColors.white;
      case AppChipVariant.disabled:
        return AppColors.coolGray300;
    }
  }
}
