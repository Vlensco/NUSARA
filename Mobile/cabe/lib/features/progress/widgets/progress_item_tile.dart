import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cabe/core/theme/app_colors.dart';
import 'package:cabe/core/theme/app_text_styles.dart';
import 'package:cabe/shared_widgets/app_button.dart';
import 'package:cabe/features/progress/controllers/progress_controller.dart';
import 'package:cabe/features/scholarships/providers/scholarship_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cabe/core/constants/translation_helper.dart';

class ProgressItemTile extends ConsumerWidget {
  final ProgressItem item;

  const ProgressItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isClickable = item.status == ProgressStatus.ditinjau ||
        item.status == ProgressStatus.diterima ||
        item.status == ProgressStatus.ditolak;

    return GestureDetector(
      onTap: isClickable
          ? () {
              if (item.status == ProgressStatus.ditinjau) {
                _showStatusDialog(context, ref);
              } else {
                // diterima atau ditolak → tampilkan popup detail
                _showResultPopup(context, ref);
              }
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _borderColor,
            width: item.status == ProgressStatus.diterima || item.status == ProgressStatus.ditolak ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Status indicator dot
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: _dotColor,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    TranslationHelper.translateTitle(item.title, context.locale.languageCode),
                    style: AppTextStyles.labelLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: item.subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _buildTrailingIcon(),
          ],
        ),
      ),
    );
  }

  Color get _borderColor {
    switch (item.status) {
      case ProgressStatus.diterima:
        return AppColors.successText.withValues(alpha: 0.4);
      case ProgressStatus.ditolak:
        return AppColors.dangerText.withValues(alpha: 0.3);
      case ProgressStatus.ditinjau:
        return AppColors.warningText.withValues(alpha: 0.3);
      default:
        return AppColors.coolGray200;
    }
  }

  Color get _dotColor {
    switch (item.status) {
      case ProgressStatus.diterima:
        return AppColors.successText;
      case ProgressStatus.ditolak:
        return AppColors.dangerText;
      case ProgressStatus.ditinjau:
        return AppColors.warningText;
      default:
        return AppColors.coolGray300;
    }
  }

  Widget _buildTrailingIcon() {
    if (item.status == ProgressStatus.diterima) {
      return const Icon(
        Icons.chevron_right,
        color: AppColors.successText,
        size: 24,
      );
    }
    if (item.status == ProgressStatus.ditolak) {
      return const Icon(
        Icons.chevron_right,
        color: AppColors.dangerText,
        size: 24,
      );
    }
    if (item.showChevron) {
      return const Icon(
        Icons.chevron_right,
        color: AppColors.gray500,
        size: 24,
      );
    }
    if (item.showAlert) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.dangerText, width: 2),
        ),
        child: Center(
          child: Text(
            '!',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.dangerText,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
    }
    if (item.showReject) {
      return Icon(
        Icons.cancel_outlined,
        color: AppColors.dangerText,
        size: 32,
      );
    }
    return const SizedBox.shrink();
  }

  // ─── Popup hasil: Diterima / Ditolak ───
  void _showResultPopup(BuildContext context, WidgetRef ref) {
    final isDiterima = item.status == ProgressStatus.diterima;

    // Cari data beasiswa lengkap dari provider
    final allScholarships = ref.read(scholarshipProvider);
    final scholarship = allScholarships.firstWhere(
      (s) => s.title == item.title,
      orElse: () => allScholarships.first,
    );

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Banner Header ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDiterima
                        ? [const Color(0xFF00875A), const Color(0xFF00C07A)]
                        : [const Color(0xFFDC2626), const Color(0xFFEF4444)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    // Icon status
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isDiterima ? LucideIcons.checkCircle : LucideIcons.xCircle,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isDiterima ? 'Selamat!' : 'Ditolak',
                      style: AppTextStyles.h3.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isDiterima
                          ? 'Pendaftaranmu berhasil diterima!'
                          : 'Pendaftaranmu belum berhasil kali ini',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // ── Body ──
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo + Nama beasiswa
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            scholarship.logoPath,
                            width: 44,
                            height: 44,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Container(
                              width: 44,
                              height: 44,
                              color: AppColors.coolGray100,
                              child: const Icon(LucideIcons.graduationCap,
                                  color: AppColors.coolGray400, size: 22),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                scholarship.provider,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: scholarship.providerColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Divider(height: 1, color: AppColors.coolGray200),
                    const SizedBox(height: 16),

                    // Info rows
                    _infoRow(LucideIcons.tag, 'Status',
                        isDiterima ? 'Diterima' : 'Ditolak',
                        valueColor: isDiterima ? AppColors.successText : AppColors.dangerText),
                    const SizedBox(height: 10),
                    _infoRow(LucideIcons.calendar, 'Batas Waktu',
                        '${scholarship.daysLeft} hari lagi'),
                    const SizedBox(height: 10),
                    _infoRow(LucideIcons.percent, 'Tingkat Kecocokan',
                        '${scholarship.matchPercentage}%'),

                    if (isDiterima) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.info, size: 16, color: Color(0xFF16A34A)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Segera lakukan pendaftaran ulang sesuai instruksi penyelenggara.',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: const Color(0xFF166534),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFECACA)),
                        ),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.lightbulb, size: 16, color: Color(0xFFDC2626)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Jangan menyerah! Cari beasiswa lain yang sesuai profilmu.',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: const Color(0xFF991B1B),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDiterima ? const Color(0xFF00875A) : AppColors.blue900,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Tutup',
                          style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.coolGray400),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.coolGray500),
        ),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.coolGray700,
          ),
        ),
      ],
    );
  }

  // ─── Dialog update status (untuk "Ditinjau") ───
  void _showStatusDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('progress.dialog_title'.tr(), style: AppTextStyles.h4),
        content: Text(
          'progress.dialog_desc'.tr(),
          style: AppTextStyles.bodySmall,
        ),
        actions: [
          AppButton(
            label: 'progress.status_rejected'.tr(),
            variant: AppButtonVariant.secondary,
            onPressed: () {
              ref
                  .read(progressProvider.notifier)
                  .updateStatus(item.id, ProgressStatus.ditolak);
              Navigator.pop(ctx);
            },
          ),
          AppButton(
            label: 'progress.status_accepted'.tr(),
            variant: AppButtonVariant.primary,
            onPressed: () {
              ref
                  .read(progressProvider.notifier)
                  .updateStatus(item.id, ProgressStatus.diterima);
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }
}
