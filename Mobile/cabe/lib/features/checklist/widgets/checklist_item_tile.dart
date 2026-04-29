import 'package:flutter/material.dart';
import 'package:cabe/core/theme/app_colors.dart';
import 'package:cabe/core/theme/app_text_styles.dart';
import 'package:cabe/features/checklist/controllers/checklist_controller.dart';

class ChecklistItemTile extends StatelessWidget {
  final ChecklistItem item;
  final VoidCallback onToggle;

  const ChecklistItemTile({
    super.key,
    required this.item,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: item.cardBorder,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      // ✅ Logika warna & weight dari model
                      color: item.titleColor,
                      fontWeight: item.titleWeight,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      // ✅ Logika warna tag dari model ScholarshipTag
                      ...item.tags.map((tag) => _buildTag(tag)),
                      const Spacer(),
                      Text(
                        item.deadline,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.coolGray400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _buildCheckCircle(),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(ScholarshipTag tag) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        // ✅ Panggil tagColor() dari model, kirim konteks isChecked
        color: tag.tagColor(isItemChecked: item.isChecked),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        tag.label,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildCheckCircle() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: item.isChecked
          ? const Icon(
              Icons.check_circle,
              key: ValueKey('checked'),
              color: Color(0xFF2E7D32),
              size: 26,
            )
          : Container(
              key: const ValueKey('unchecked'),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.coolGray300, width: 2),
              ),
            ),
    );
  }
}

