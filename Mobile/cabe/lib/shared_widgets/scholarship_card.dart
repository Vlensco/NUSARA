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
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
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
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: providerColor, 
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 15),
                // Title & Provider
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.gray900,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        provider,
                        style: TextStyle(
                          color: providerColor,
                          fontSize: 13,
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
                    size: 26,
                    color: isSaved ? AppColors.blue900 : Colors.black,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: tags
                  .map((tag) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ))
                  .toList(),
            ),

            const SizedBox(height: 15),

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
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
