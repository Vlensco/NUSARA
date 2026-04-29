import 'package:flutter/material.dart';
import 'package:cabe/core/theme/app_colors.dart';
import 'package:cabe/core/theme/app_text_styles.dart';

enum AppBadgeVariant { saved, reviewed, accepted, rejected, matched }

class AppBadge extends StatelessWidget {
  final AppBadgeVariant variant;

  final int? percentage;

  const AppBadge({
    super.key,
    required this.variant,
    this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final isMatched = variant == AppBadgeVariant.matched;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isMatched ? Colors.transparent : _backgroundColor,
        borderRadius: BorderRadius.circular(100),
        border: isMatched ? Border.all(color: _textColor, width: 1) : null,
      ),
      child: Text(
        _label,
        style: AppTextStyles.labelSmall.copyWith(
          color: _textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String get _label {
    switch (variant) {
      case AppBadgeVariant.saved:
        return 'Tersimpan';
      case AppBadgeVariant.reviewed:
        return 'Ditinjau';
      case AppBadgeVariant.accepted:
        return 'Diterima';
      case AppBadgeVariant.rejected:
        return 'Ditolak';
      case AppBadgeVariant.matched:
        return '${percentage ?? 0}% Cocok';
    }
  }

  Color get _backgroundColor {
    switch (variant) {
      case AppBadgeVariant.saved:
        return AppColors.infoBg;
      case AppBadgeVariant.reviewed:
        return AppColors.warningBg;
      case AppBadgeVariant.accepted:
        return AppColors.successBg;
      case AppBadgeVariant.rejected:
        return AppColors.dangerBg;
      case AppBadgeVariant.matched:
        return _matchedBgColor;
    }
  }

  Color get _textColor {
    switch (variant) {
      case AppBadgeVariant.saved:
        return AppColors.infoText;
      case AppBadgeVariant.reviewed:
        return AppColors.warningText;
      case AppBadgeVariant.accepted:
        return AppColors.successText;
      case AppBadgeVariant.rejected:
        return AppColors.dangerText;
      case AppBadgeVariant.matched:
        return _matchedTextColor;
    }
  }

  // Warna persentase cocok: merah (<40%), kuning (40-69%), hijau (>=70%)
  Color get _matchedBgColor {
    final pct = percentage ?? 0;
    if (pct >= 70) return AppColors.successBg;
    if (pct >= 40) return AppColors.warningBg;
    return AppColors.dangerBg;
  }

  Color get _matchedTextColor {
    final pct = percentage ?? 0;
    if (pct >= 70) return const Color(0xFF00A36C); // Hijau
    if (pct >= 40) return const Color(0xFFFF9800); // Oranye
    return const Color(0xFFE53935); // Merah
  }
}
