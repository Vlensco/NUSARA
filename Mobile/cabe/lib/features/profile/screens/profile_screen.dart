import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cabe/core/routing/main_navigation.dart';
import 'package:cabe/features/progress/controllers/progress_controller.dart';
import 'package:cabe/core/providers/user_profile_provider.dart';
import 'package:cabe/features/auth/screens/login_screen.dart';
import '../controllers/profile_controller.dart';
import '../widgets/action_card.dart';
import '../widgets/profile_badge.dart';
import '../widgets/progress_row.dart';
import '../widgets/stat_card.dart';
import '../widgets/edit_profile_dialog.dart';

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
                child: Consumer(
                  builder: (context, ref, child) {
                    final profileAsync = ref.watch(userProfileProvider);
                    return profileAsync.when(
                      data: (dbProfile) {
                        final name = dbProfile?['nama_lengkap'] ?? '';
                        final school = dbProfile?['nama_sekolah'] ?? '';
                        final grade = dbProfile?['kelas'] ?? '';
                        final major = dbProfile?['jurusan'] ?? '';
                        final displayName = name.isNotEmpty ? name : 'User';
                        return Row(
                          children: [
                            CircleAvatar(
                              radius: 35,
                              backgroundColor: const Color(0xFF1E3F66),
                              backgroundImage: NetworkImage(
                                'https://ui-avatars.com/api/?name=$displayName&background=E5E7EB&color=1F2937',
                              ),
                            ),
                            const SizedBox(width: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (school.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.domain, color: Colors.white70, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        school,
                                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ],
                                if (grade.isNotEmpty || major.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      if (grade.isNotEmpty) ProfileBadge(text: 'Kelas $grade'),
                                      if (grade.isNotEmpty && major.isNotEmpty) const SizedBox(width: 8),
                                      if (major.isNotEmpty) ProfileBadge(text: major),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                            const Spacer(),
                          ],
                        );
                      },
                      loading: () => const Row(
                        children: [
                          CircleAvatar(radius: 35, backgroundColor: Color(0xFF1E3F66)),
                          SizedBox(width: 15),
                          Text("Memuat...", style: TextStyle(color: Colors.white)),
                        ],
                      ),
                      error: (_, __) => Row(
                        children: [
                          const CircleAvatar(radius: 35, backgroundColor: Color(0xFF1E3F66)),
                          const SizedBox(width: 15),
                          Text(profile.name, style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                    );
                  },
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
                      icon: Icons.school_outlined,
                      title: "Nilai akademik (IPK/Nilai)",
                      score: "${profile.academicScore} / ${profile.academicMax}",
                      progress: profile.academicProgress,
                    ),
                    ProgressRow(
                      icon: Icons.monetization_on_outlined,
                      title: "Kebutuhan Finansial",
                      score: "${profile.financialScore} / ${profile.financialMax}",
                      progress: profile.financialProgress,
                    ),
                    ProgressRow(
                      icon: Icons.emoji_events_outlined,
                      title: "Prestasi Non-Akademik",
                      score: "${profile.nonAcademicScore} / ${profile.nonAcademicMax}",
                      progress: profile.nonAcademicProgress,
                    ),
                    ProgressRow(
                      icon: Icons.card_membership_outlined,
                      title: "Sertifikat & Rekomendasi",
                      score: "${profile.certRecScore} / ${profile.certRecMax}",
                      progress: profile.certRecProgress,
                    ),
                    ProgressRow(
                      icon: Icons.description_outlined,
                      title: "Motivasi & Rencana Karir",
                      score: "${profile.motivationScore} / ${profile.motivationMax}",
                      progress: profile.motivationProgress,
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
                  Consumer(
                    builder: (context, ref, child) {
                      final dbProfile = ref.watch(userProfileProvider).value;
                      List<String> interests = [];
                      if (dbProfile?['minat_bakat'] != null) {
                        final mb = dbProfile!['minat_bakat'];
                        if (mb is List) {
                          interests = List<String>.from(mb);
                        } else if (mb is String && mb.isNotEmpty) {
                          interests = mb.split(',').map((e) => e.trim()).toList();
                        }
                      }
                      
                      if (interests.isEmpty) {
                        return const Text("Data belum dilengkapi", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic));
                      }
                      
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: interests.map((interest) {
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
                      );
                    },
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
                  Consumer(
                    builder: (context, ref, child) {
                      final dbProfile = ref.watch(userProfileProvider).value;
                      List<String> achievements = [];
                      if (dbProfile?['prestasi'] != null) {
                        final pr = dbProfile!['prestasi'];
                        if (pr is List) {
                          achievements = pr
                              .map((e) => e.toString().trim())
                              .where((e) => e.isNotEmpty && e != '[]' && e != '{}')
                              .toList();
                        } else if (pr is String && pr.isNotEmpty && pr != '[]' && pr != '{}') {
                          achievements = pr
                              .split(',')
                              .map((e) => e.trim())
                              .where((e) => e.isNotEmpty)
                              .toList();
                        }
                      }
                      
                      if (achievements.isEmpty) {
                        return const Text("Data belum dilengkapi", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic));
                      }
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: achievements.map((achievement) {
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
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  Consumer(
                    builder: (context, ref, child) {
                      final dbProfile = ref.watch(userProfileProvider).value;
                      final rawScore = dbProfile?['nilai_rata_rata'];
                      final reportScore = (rawScore != null && rawScore != 0 && rawScore != 0.0)
                          ? rawScore.toString()
                          : 'Belum diisi';
                      
                      return Container(
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
                              reportScore,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Consumer(
                    builder: (context, ref, child) {
                      final dbProfile = ref.watch(userProfileProvider).value;
                      final toeicScore = dbProfile?['skor_toeic']?.toString() ?? 'Belum diisi';
                      
                      return Container(
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
                              toeicScore,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    },
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
                  ActionCard(
                    icon: Icons.person_outline, 
                    label: "Edit Profil", 
                    isDestructive: false,
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (context) => const EditProfileDialog(),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  ActionCard(icon: Icons.language, label: "Bahasa", isDestructive: false),
                  const SizedBox(height: 10),
                  ActionCard(
                    icon: Icons.logout, 
                    label: "Log Out", 
                    isDestructive: true,
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Log Out'),
                          content: const Text('Apakah kamu yakin ingin keluar?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text('Log Out', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await FirebaseAuth.instance.signOut();
                        ref.invalidate(userProfileProvider);
                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (route) => false,
                          );
                        }
                      }
                    },
                  ),
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
