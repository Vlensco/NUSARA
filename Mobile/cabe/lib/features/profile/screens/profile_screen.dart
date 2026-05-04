import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cabe/core/routing/main_navigation.dart';
import 'package:cabe/features/progress/controllers/progress_controller.dart';
import '../controllers/profile_controller.dart';
import '../widgets/action_card.dart';
import '../widgets/profile_badge.dart';
import '../widgets/progress_row.dart';
import '../widgets/stat_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileControllerProvider);
    final progressState = ref.watch(progressProvider);
    
    int savedCount = 0;
    int reviewedCount = 0;
    int acceptedCount = 0;
    
    for (final item in progressState.items) {
      if (item.status == ProgressStatus.tersimpan) savedCount++;
      else if (item.status == ProgressStatus.ditinjau) reviewedCount++;
      else if (item.status == ProgressStatus.diterima) acceptedCount++;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER SECTION ---
            Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  top: 70,
                  left: 20,
                  right: 20,
                  bottom: 70,
                ),
                decoration: const BoxDecoration(color: Color(0xFF002147)),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 35,
                      backgroundColor: Color(0xFF1E3F66),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.domain, color: Colors.white70, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              profile.school,
                              style: const TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            ProfileBadge(text: profile.grade),
                            const SizedBox(width: 8),
                            ProfileBadge(text: profile.major),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                  ],
                ),
              ),

            // --- SCORE CARD SECTION ---
            Transform.translate(
              offset: const Offset(0, -40),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 10),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "Skor Kesiapan Beasiswa",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 140,
                          height: 140,
                          child: CircularProgressIndicator(
                            value: profile.progress,
                            strokeWidth: 14,
                            strokeCap: StrokeCap.round,
                            backgroundColor: const Color(0xFFFEF1D2),
                            color: const Color(0xFFFF6200),
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              "${profile.score}",
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF6200),
                              ),
                            ),
                            const Text(
                              "dari 100",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      profile.status,
                      style: const TextStyle(
                        color: Color(0xFFFF6200),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ProgressRow(
                      icon: Icons.person_outline,
                      title: "Kelengkapan Profil",
                      score: "${profile.profileCompletionScore} / ${profile.profileCompletionMax}",
                      progress: profile.profileCompletionProgress,
                    ),
                    ProgressRow(
                      icon: Icons.description_outlined,
                      title: "Kesiapan Dokumen",
                      score: "${profile.documentReadinessScore} / ${profile.documentReadinessMax}",
                      progress: profile.documentReadinessProgress,
                    ),
                    ProgressRow(
                      icon: Icons.school_outlined,
                      title: "Kekuatan Akademik",
                      score: "${profile.academicStrengthScore} / ${profile.academicStrengthMax}",
                      progress: profile.academicStrengthProgress,
                    ),
                    ProgressRow(
                      icon: Icons.star_outline,
                      title: "Aktivitas & Prestasi",
                      score: "${profile.activityAchievementScore} / ${profile.activityAchievementMax}",
                      progress: profile.activityAchievementProgress,
                    ),
                  ],
                ),
              ),
            ),

            // --- TIPS SECTION ---
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9E7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade100),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, color: Colors.brown),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Tips Peningkatan",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                        Text(
                          "Simpan beasiswa dan mulai centang dokumen yang sudah kamu siapkan",
                          style: TextStyle(fontSize: 11, color: Colors.brown),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // --- STATISTIK ---
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Statistik",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatCard(
                    icon: Icons.bookmark_outline_rounded, 
                    count: savedCount.toString(), 
                    label: "Disimpan", 
                    iconColor: const Color(0xFF002147),
                    onTap: () {
                      ref.read(progressProvider.notifier).setFilter(ProgressFilter.tersimpan);
                      ref.read(bottomNavIndexProvider.notifier).setIndex(2);
                    },
                  ),
                  StatCard(
                    icon: Icons.assignment_outlined, 
                    count: reviewedCount.toString(), 
                    label: "Ditinjau", 
                    iconColor: Colors.red.shade600,
                    onTap: () {
                      ref.read(progressProvider.notifier).setFilter(ProgressFilter.ditinjau);
                      ref.read(bottomNavIndexProvider.notifier).setIndex(2);
                    },
                  ),
                  StatCard(
                    icon: Icons.check_circle_outline_rounded, 
                    count: acceptedCount.toString(), 
                    label: "Diterima", 
                    iconColor: const Color(0xFF1F7A54),
                    onTap: () {
                      ref.read(progressProvider.notifier).setFilter(ProgressFilter.diterima);
                      ref.read(bottomNavIndexProvider.notifier).setIndex(2);
                    },
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Divider(color: Colors.black12, thickness: 1),
            ),

            // --- MINAT DAN BAKAT ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.menu_book_outlined, size: 24, color: Colors.black),
                      SizedBox(width: 10),
                      Text(
                        "Minat dan Bakat",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: profile.interests.map((interest) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          interest,
                          style: TextStyle(
                            color: Colors.blue.shade900,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Divider(color: Colors.black12, thickness: 1),
            ),

            // --- PRESTASI ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.star_border, size: 24, color: Colors.black),
                      SizedBox(width: 10),
                      Text(
                        "Prestasi",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: profile.achievements.map((achievement) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          achievement,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Nilai Rapor", style: TextStyle(color: Colors.black54)),
                        Text(
                          profile.reportScore.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Skor TOEIC", style: TextStyle(color: Colors.black54)),
                        Text(
                          profile.toeicScore.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Divider(color: Colors.black12, thickness: 1),
            ),

            // --- ACTIONS ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  ActionCard(icon: Icons.person_outline, label: "Edit Profil", isDestructive: false),
                  const SizedBox(height: 10),
                  ActionCard(icon: Icons.language, label: "Bahasa", isDestructive: false),
                  const SizedBox(height: 10),
                  ActionCard(icon: Icons.logout, label: "Log Out", isDestructive: true),
                ],
              ),
            ),

            const SizedBox(height: 20),
            
            // --- FOOTER ---
            const Padding(
              padding: EdgeInsets.only(bottom: 30),
              child: Text(
                "CaBe v1.0 - Cari Beasiswa",
                style: TextStyle(
                  color: Colors.black38,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
