import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cabe/core/theme/app_colors.dart';
import '../models/scholarship.dart';
import '../providers/scholarship_provider.dart';

class DetailBeasiswaPage extends ConsumerWidget {
  final Scholarship scholarship;

  const DetailBeasiswaPage({super.key, required this.scholarship});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentScholarship = ref.watch(scholarshipProvider).firstWhere(
          (s) => s.id == scholarship.id,
          orElse: () => scholarship,
        );

    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC), 
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
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
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
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
                    currentScholarship.title,
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
                        "${currentScholarship.matchPercentage}% Kecocokan",
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
                        "${currentScholarship.daysLeft} Hari Lagi !",
                        style: const TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: OutlinedButton(
                      onPressed: () {},
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
                      child: const Text(
                        "Daftar Sekarang",
                        style: TextStyle(
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
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Tentang Beasiswa"),
                  Text(
                    currentScholarship.description,
                    style: const TextStyle(
                      color: Colors.black54, 
                      height: 1.5,
                      fontSize: 14,
                    ),
                  ),

                  if (currentScholarship.requirements.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(color: Colors.black12, thickness: 1),
                    ),
                    _buildSectionTitle("Persyaratan"),
                    ...currentScholarship.requirements.map((req) => _buildListPoint(req)),
                  ],

                  if (currentScholarship.criteria.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(color: Colors.black12, thickness: 1),
                    ),
                    _buildSectionTitle("Kriteria Kelayakan"),
                    ...currentScholarship.criteria.entries.map((entry) =>
                        _buildCriteriaRow(entry.key, entry.value)),
                  ],

                  if (currentScholarship.documents.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(color: Colors.black12, thickness: 1),
                    ),
                    _buildSectionTitle("Dokumen Diperlukan"),
                    ...currentScholarship.documents.map((doc) => _buildDocumentPoint(doc)),
                  ],

                  if (currentScholarship.tags.isNotEmpty) ...[
                    const SizedBox(height: 30),
                    Wrap(
                      spacing: 8,
                      runSpacing: 10,
                      children: currentScholarship.tags
                          .map((tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE6F0FA),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  tag,
                                  style: const TextStyle(
                                    color: AppColors.blue900,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
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

  Widget _buildCriteriaRow(String label, String value) {
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
          Text(label, style: const TextStyle(color: Colors.black38, fontSize: 14)),
          Text(
            value,
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
