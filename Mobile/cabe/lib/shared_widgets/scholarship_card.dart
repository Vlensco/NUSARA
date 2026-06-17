import 'package:flutter/material.dart';
import 'package:cabe/core/theme/app_colors.dart';
import 'package:cabe/core/theme/app_text_styles.dart';
import 'package:cabe/shared_widgets/app_chip.dart';
import 'package:cabe/shared_widgets/app_badge.dart';
import 'package:cabe/shared_widgets/app_tag.dart';
import 'package:easy_localization/easy_localization.dart';

class ScholarshipCard extends StatelessWidget {
  final String title;
  final String provider;
  final Color providerColor;
  final String logoPath;
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
    this.logoPath = '',
    required this.tags,
    required this.matchPercentage,
    required this.daysLeft,
    this.isSaved = false,
    this.onTap,
    this.onSaved,
  });

  String _getTranslatedTitle(String rawTitle, String langCode) {
    if (langCode != 'en') return rawTitle;
    switch (rawTitle) {
      case 'Beasiswa Unggulan Kemendikbud': return 'Kemendikbud Outstanding Scholarship';
      case 'Beasiswa Atlet Berprestasi KONI': return 'KONI Outstanding Athlete Scholarship';
      case 'Beasiswa Seni Budaya Nusantara': return 'Nusantara Arts and Culture Scholarship';
      case 'Paragon for Future Leaders': return 'Paragon for Future Leaders';
      case 'LPDP Beasiswa Reguler': return 'LPDP Regular Scholarship';
      case 'Beasiswa Astra 1st': return 'Astra 1st Scholarship';
      case 'TELADAN - Tanoto Foundation': return 'TELADAN - Tanoto Foundation';
      default: return rawTitle;
    }
  }

  String _getTranslatedTag(String rawTag, String langCode) {
    if (langCode != 'en') return rawTag;
    switch (rawTag.trim().toLowerCase()) {
      case 'matematika': return 'Mathematics';
      case 'pemerintah': return 'Government';
      case 'prestasi': return 'Achievement';
      case 'parsial': return 'Partial';
      case 'olahraga': return 'Sports';
      case 'khusus': return 'Special';
      case 'penuh': return 'Full';
      case 'seni & desain': return 'Arts & Design';
      case 'wirausahawan': return 'Entrepreneur';
      case 'swasta': return 'Private';
      case 'kurang mampu': return 'Underprivileged';
      case 'kesehatan': return 'Health';
      case 'kampus': return 'University';
      case 'ikatan dinas': return 'Service Bond';
      default: return rawTag;
    }
  }

  @override
  Widget build(BuildContext context) {
    final langCode = context.locale.languageCode;
    final displayTitle = _getTranslatedTitle(title, langCode);
    final displayTags = tags.map((tag) => _getTranslatedTag(tag, langCode)).toList();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 2,
              spreadRadius: 0,
              offset: const Offset(0, 2),
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
                // Logo beasiswa
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: logoPath.isNotEmpty ? Colors.white : providerColor,
                    borderRadius: BorderRadius.circular(10),
                    border: logoPath.isNotEmpty
                        ? Border.all(color: Colors.grey.shade200)
                        : null,
                  ),
                  child: logoPath.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            logoPath,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: providerColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              );
                            },
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 15),
                // Title & Provider
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayTitle,
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
              children: displayTags
                  .map((tag) => AppTag(
                        label: tag,
                        variant: AppTagVariant.dark,
                      ))
                  .toList(),
            ),

            const SizedBox(height: 15),

            // Footer: Badge + Deadline
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppBadge(
                  variant: AppBadgeVariant.matched,
                  percentage: matchPercentage,
                ),
                Text(
                  '*$daysLeft ${"scholarship.days_left_card".tr()}',
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
