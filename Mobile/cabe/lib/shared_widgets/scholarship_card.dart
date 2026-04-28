import 'package:flutter/material.dart';
import 'package:cabe/core/theme/app_colors.dart';
import 'package:cabe/core/theme/app_text_styles.dart';
import 'package:cabe/shared_widgets/app_chip.dart';
import 'package:cabe/shared_widgets/app_badge.dart';

class ScholarshipCard extends StatelessWidget {
  final String title;
  final String provider;
  final Color providerColor;
  final List<String> tags;
  final int matchPercentage;
  final int daysLeft;
  final bool isSaved;
  final VoidCallback? onTap;
  final VoidCallback? onSaved;

  const ScholarshipCard({
    super.key,
    required this.title,
    required this.provider,
    this.providerColor = AppColors.blue500,
    required this.tags,
    required this.matchPercentage,
    required this.daysLeft,
    this.isSaved = false,
    this.onTap,
    this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.coolGray200, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row: Logo + Info + Bookmark
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo placeholder
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: providerColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: providerColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Title & Provider
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.labelLarge,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        provider,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: providerColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Bookmark
                GestureDetector(
                  onTap: onSaved,
                  child: Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_border,
                    size: 22,
                    color: isSaved ? AppColors.blue500 : AppColors.coolGray300,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Tags
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: tags
                  .map((tag) => AppChip(label: tag, variant: AppChipVariant.light))
                  .toList(),
            ),

            const SizedBox(height: 12),

            // Footer: Badge cocok + Deadline
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppBadge(
                  variant: AppBadgeVariant.matched,
                  percentage: matchPercentage,
                ),
                Text(
                  '*$daysLeft hari lagi',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
