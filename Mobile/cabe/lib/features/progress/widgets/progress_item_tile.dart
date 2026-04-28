import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cabe/core/theme/app_colors.dart';
import 'package:cabe/core/theme/app_text_styles.dart';
import 'package:cabe/shared_widgets/app_button.dart';
import 'package:cabe/features/progress/controllers/progress_controller.dart';

class ProgressItemTile extends ConsumerWidget {
  final ProgressItem item;

  const ProgressItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showStatusDialog(context, ref),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.coolGray200, width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: AppTextStyles.labelLarge),
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

  Widget _buildTrailingIcon() {
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

  void _showStatusDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Ubah Status Beasiswa', style: AppTextStyles.h4),
        content: Text(
          'Pilihah status beasiswa kamu apabila telah selesai melewati proses peninjauan!',
          style: AppTextStyles.bodySmall,
        ),
        actions: [
          AppButton(
            label: 'Ditolak',
            variant: AppButtonVariant.secondary,
            onPressed: () {
              ref
                  .read(progressProvider.notifier)
                  .updateStatus(item.id, ProgressStatus.ditolak);
              Navigator.pop(ctx);
            },
          ),
          AppButton(
            label: 'Diterima',
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
