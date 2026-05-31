import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cabe/core/theme/app_colors.dart';
import '../models/scholarship.dart';
import '../providers/scholarship_provider.dart';
import 'package:cabe/shared_widgets/app_tag.dart';
import 'package:cabe/features/checklist/controllers/checklist_controller.dart';
import 'package:cabe/core/routing/main_navigation.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cabe/core/constants/translation_helper.dart';

class DetailBeasiswaPage extends ConsumerWidget {
  final Scholarship scholarship;

  const DetailBeasiswaPage({super.key, required this.scholarship});

  String _getTranslatedCriteriaLabel(String label, String langCode) {
    final lower = label.toLowerCase().trim();
    if (lower == 'min. nilai rapor') {
      return 'scholarship.min_report_score'.tr();
    } else if (lower == 'min. ipk') {
      return 'scholarship.min_gpa'.tr();
    } else if (lower == 'kelas') {
      return 'scholarship.grade'.tr();
    } else if (lower == 'jurusan') {
      return 'scholarship.major'.tr();
    }

    if (lower.contains('ipk') || lower.contains('nilai')) {
      return 'profile.nilai_ipk'.tr();
    } else if (lower.contains('finansial') || lower.contains('ekonomi')) {
      return 'profile.param_finansial'.tr();
    } else if (lower.contains('prestasi')) {
      return 'profile.param_prestasi'.tr();
    } else if (lower.contains('sertifikat') || lower.contains('rekomendasi')) {
      return 'profile.param_sertifikat'.tr();
    } else if (lower.contains('motivasi') || lower.contains('rencana')) {
      return 'profile.param_motivasi'.tr();
    }
    return label;
  }

  String _getTranslatedCriteriaValue(String value, String langCode) {
    final trimVal = value.trim();
    if (langCode == 'en') {
      switch (trimVal) {
        case 'IPA, IPS, Bahasa': return 'Science, Social, Language';
        case 'IPA, IPS, Bahasa, SMK': return 'Science, Social, Language, Vocational';
        case 'SMK': return 'Vocational';
      }
    }
    switch (trimVal.toLowerCase()) {
      case 'tinggi': return 'scholarship.val_high'.tr();
      case 'rendah': return 'scholarship.val_low'.tr();
      case 'sedang': return 'scholarship.val_medium'.tr();
      case 'sangat siap': return 'scholarship.val_very_ready'.tr();
      case 'siap': return 'scholarship.val_ready'.tr();
      case 'cukup siap': return 'scholarship.val_quite_ready'.tr();
      case 'perlu persiapan': return 'scholarship.val_needs_prep'.tr();
      default: return value;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentScholarship = ref.watch(scholarshipProvider).firstWhere(
          (s) => s.id == scholarship.id,
          orElse: () => scholarship,
        );

    final langCode = context.locale.languageCode;
    final displayTitle = TranslationHelper.translateTitle(currentScholarship.title, langCode);
    final displayDescription = TranslationHelper.translateDescription(currentScholarship.description, langCode);
    final displayRequirements = currentScholarship.requirements.map((req) => TranslationHelper.translateRequirement(req, langCode)).toList();
    final displayDocuments = currentScholarship.documents.map((doc) => TranslationHelper.translateDocument(doc, langCode)).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC), 
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 50, 24, 30),
              decoration: const BoxDecoration(
                color: AppColors.blue900,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      GestureDetector(
                        onTap: () {
                          ref.read(scholarshipProvider.notifier).toggleSave(currentScholarship.id);
                        },
                        child: Icon(
                          currentScholarship.isSaved
                              ? Icons.bookmark
                              : Icons.bookmark_outline,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    displayTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    currentScholarship.provider,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(
                        Icons.school_outlined,
                        color: Colors.white54,
                        size: 18,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "${currentScholarship.matchPercentage}% ${"scholarship.match".tr()}",
                        style: const TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.calendar_today_outlined,
                        color: Colors.white54,
                        size: 18,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "${currentScholarship.daysLeft} ${"scholarship.days_left".tr()}",
                        style: const TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: OutlinedButton(
                      onPressed: () {
                        final acronym = getAcronymForScholarshipId(currentScholarship.id);
                        if (acronym != null) {
                          final appliedList = ref.read(appliedScholarshipsProvider);
                          if (appliedList.contains(acronym)) {
                            _showTopNotification(context, 'scholarship.already_registered'.tr(), true);
                          } else {
                            ref.read(appliedScholarshipsProvider.notifier).add(acronym);
                            _showTopNotification(context, 'scholarship.register_success'.tr(), false);
                          }
                        }
                      },
                      style: ButtonStyle(
                        side: WidgetStateProperty.resolveWith((states) {
                          return const BorderSide(color: Colors.white);
                        }),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        backgroundColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.hovered) ||
                              states.contains(WidgetState.pressed)) {
                            return Colors.white;
                          }
                          return Colors.transparent;
                        }),
                        foregroundColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.hovered) ||
                              states.contains(WidgetState.pressed)) {
                            return AppColors.blue900;
                          }
                          return Colors.white;
                        }),
                      ),
                      child: Text(
                        "scholarship.register_now".tr(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("scholarship.about".tr()),
                  Text(
                    displayDescription,
                    style: const TextStyle(
                      color: Colors.black54, 
                      height: 1.5,
                      fontSize: 14,
                    ),
                  ),

                  if (displayRequirements.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(color: Colors.black12, thickness: 1),
                    ),
                    _buildSectionTitle("scholarship.requirements".tr()),
                    ...displayRequirements.map((req) => _buildListPoint(req)),
                  ],

                  if (currentScholarship.criteria.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(color: Colors.black12, thickness: 1),
                    ),
                    _buildSectionTitle("scholarship.criteria".tr()),
                    ...currentScholarship.criteria.entries.map((entry) =>
                        _buildCriteriaRow(entry.key, entry.value, langCode)),
                  ],

                  if (displayDocuments.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(color: Colors.black12, thickness: 1),
                    ),
                    _buildSectionTitle("scholarship.documents".tr()),
                    ...displayDocuments.map((doc) => _buildDocumentPoint(doc)),
                  ],

                  if (currentScholarship.tags.isNotEmpty) ...[
                    const SizedBox(height: 30),
                    Wrap(
                      spacing: 8,
                      runSpacing: 10,
                      children: currentScholarship.tags
                          .map((tag) => AppTag(
                                label: tag,
                                variant: AppTagVariant.lightBlue,
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 30), 
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTopNotification(BuildContext context, String message, bool isError) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: -100, end: 0),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, value),
                child: child,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isError ? Colors.orange.shade700 : Colors.green.shade600,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    isError ? Icons.info_outline : Icons.check_circle_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black, 
        ),
      ),
    );
  }

  Widget _buildListPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, size: 18, color: Colors.black),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(color: Colors.black54, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.description_outlined, size: 18, color: Colors.black),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(color: Colors.black54, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildCriteriaRow(String label, String value, String langCode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2F6), 
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(_getTranslatedCriteriaLabel(label, langCode), style: const TextStyle(color: Colors.black38, fontSize: 14)),
          Text(
            _getTranslatedCriteriaValue(value, langCode),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
