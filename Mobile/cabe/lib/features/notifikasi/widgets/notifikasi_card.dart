import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cabe/core/theme/app_colors.dart';
import 'package:cabe/core/theme/app_text_styles.dart';
import 'package:cabe/features/notifikasi/models/notifikasi_model.dart';

class NotifikasiCard extends StatelessWidget {
  final NotifikasiModel notifikasi;

  const NotifikasiCard({
    super.key,
    required this.notifikasi,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: notifikasi.isRead ? Colors.white : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 2,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon berdasarkan tipe
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _iconData,
                  color: _iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notifikasi.title,
                      style: AppTextStyles.h4.copyWith(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notifikasi.message,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 12,
                        color: AppColors.gray500,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.clock,
                          size: 14,
                          color: AppColors.gray500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          notifikasi.time,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.gray500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Unread/Read indicator
          if (!notifikasi.isRead)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _iconColor,
                  shape: BoxShape.circle,
                ),
              ),
            )
          else
            Positioned(
              top: 0,
              right: 0,
              child: Icon(
                LucideIcons.checkCheck,
                color: AppColors.successText,
                size: 16,
              ),
            ),
        ],
      ),
    );
  }

  IconData get _iconData {
    switch (notifikasi.type) {
      case NotifikasiType.ditinjau:
        return LucideIcons.clock;
      case NotifikasiType.diterima:
        return LucideIcons.checkCircle;
      case NotifikasiType.ditolak:
        return LucideIcons.xCircle;
    }
  }

  Color get _iconColor {
    switch (notifikasi.type) {
      case NotifikasiType.ditinjau:
        return AppColors.warningText;
      case NotifikasiType.diterima:
        return AppColors.successText;
      case NotifikasiType.ditolak:
        return AppColors.dangerText;
    }
  }

  Color get _iconBgColor {
    switch (notifikasi.type) {
      case NotifikasiType.ditinjau:
        return const Color(0xFFFFF8E1);
      case NotifikasiType.diterima:
        return const Color(0xFFE8F5E9);
      case NotifikasiType.ditolak:
        return AppColors.dangerBg;
    }
  }
}
