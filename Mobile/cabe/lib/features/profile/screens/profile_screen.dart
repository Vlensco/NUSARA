import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cabe/core/routing/main_navigation.dart';
import 'package:cabe/features/progress/controllers/progress_controller.dart';
import 'package:cabe/core/providers/user_profile_provider.dart';
import 'package:cabe/features/auth/screens/login_screen.dart';
import 'package:easy_localization/easy_localization.dart';
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
                        final jenjang = dbProfile?['jenjang'] as String? ?? '';
                        final displayName = name.isNotEmpty ? name : 'User';

                        bool isKuliah = jenjang.isNotEmpty
                            ? (jenjang.toLowerCase().contains('d3') ||
                               jenjang.toLowerCase().contains('s1') ||
                               jenjang.toLowerCase().contains('s2') ||
                               jenjang.toLowerCase().contains('d4') ||
                               jenjang.toLowerCase().contains('kuliah') ||
                               jenjang.toLowerCase().contains('vokasi'))
                            : false;
                        
                        // Fallback jika jenjang kosong, cek apakah grade ≤ 8 (semester di kuliah)
                        if (jenjang.isEmpty) {
                          final gradeNum = int.tryParse(grade);
                          if (gradeNum != null && gradeNum <= 8) {
                            isKuliah = true;
                          }
                        }

                        final gradeLabel = isKuliah 
                            ? '${"profile.semester".tr()} $grade' 
                            : '${"profile.kelas".tr()} $grade';

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
                                      if (grade.isNotEmpty) ProfileBadge(text: gradeLabel),
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
                      loading: () => Row(
                        children: [
                          const CircleAvatar(radius: 35, backgroundColor: Color(0xFF1E3F66)),
                          const SizedBox(width: 15),
                          Text("profile.memuat".tr(), style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                      error: (error, stackTrace) => Row(
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
                    Text(
                      "profile.skor_kesiapan".tr(),
                      style: const TextStyle(
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
                            Text(
                              "profile.dari_100".tr(),
                              style: const TextStyle(
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
                      title: "profile.param_akademik".tr(),
                      score: "${profile.academicScore.toStringAsFixed(1)} / ${profile.academicMax}",
                      progress: profile.academicProgress.clamp(0.0, 1.0),
                    ),
                    ProgressRow(
                      icon: Icons.monetization_on_outlined,
                      title: "profile.param_finansial".tr(),
                      score: "${profile.financialScore.toStringAsFixed(1)} / ${profile.financialMax}",
                      progress: profile.financialProgress.clamp(0.0, 1.0),
                    ),
                    ProgressRow(
                      icon: Icons.emoji_events_outlined,
                      title: "profile.param_prestasi".tr(),
                      score: "${profile.nonAcademicScore.toStringAsFixed(1)} / ${profile.nonAcademicMax}",
                      progress: profile.nonAcademicProgress.clamp(0.0, 1.0),
                    ),
                    ProgressRow(
                      icon: Icons.card_membership_outlined,
                      title: "profile.param_sertifikat".tr(),
                      score: "${profile.certRecScore.toStringAsFixed(1)} / ${profile.certRecMax}",
                      progress: profile.certRecProgress.clamp(0.0, 1.0),
                    ),
                    ProgressRow(
                      icon: Icons.description_outlined,
                      title: "profile.param_motivasi".tr(),
                      score: "${profile.motivationScore.toStringAsFixed(1)} / ${profile.motivationMax}",
                      progress: profile.motivationProgress.clamp(0.0, 1.0),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.lightbulb_outline, color: Colors.brown, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "profile.tips_ai".tr(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (profile.tips.isEmpty)
                          Text(
                            "profile.lengkapi_profil_tips".tr(),
                            style: const TextStyle(fontSize: 12, color: Colors.brown, height: 1.4),
                          )
                        else
                          _buildFormattedTips(context, profile.tips),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // --- STATISTIK ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "profile.statistik".tr(),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    label: "profile.disimpan".tr(), 
                    iconColor: const Color(0xFF002147),
                    onTap: () {
                      ref.read(progressProvider.notifier).setFilter(ProgressFilter.tersimpan);
                      ref.read(bottomNavIndexProvider.notifier).setIndex(2);
                    },
                  ),
                  StatCard(
                    icon: Icons.assignment_outlined, 
                    count: reviewedCount.toString(), 
                    label: "profile.ditinjau".tr(), 
                    iconColor: Colors.red.shade600,
                    onTap: () {
                      ref.read(progressProvider.notifier).setFilter(ProgressFilter.ditinjau);
                      ref.read(bottomNavIndexProvider.notifier).setIndex(2);
                    },
                  ),
                  StatCard(
                    icon: Icons.check_circle_outline_rounded, 
                    count: acceptedCount.toString(), 
                    label: "profile.diterima".tr(), 
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
                    children: [
                      const Icon(Icons.menu_book_outlined, size: 24, color: Colors.black),
                      const SizedBox(width: 10),
                      Text(
                        "profile.minat_bakat".tr(),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                        return Text("profile.data_belum_lengkap".tr(), style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic));
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
                    children: [
                      const Icon(Icons.star_border, size: 24, color: Colors.black),
                      const SizedBox(width: 10),
                      Text(
                        "profile.prestasi".tr(),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                      // Cek apakah nilai rapor/IPK juga belum diisi
                      final rawScore = dbProfile?['nilai_rata_rata'];
                      final hasScore = rawScore != null && rawScore != 0 && rawScore != 0.0;
                      if (!hasScore) {
                        return Text("profile.data_belum_lengkap".tr(), style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic));
                      }
                      return const SizedBox.shrink();
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
                      final tipeNilai = dbProfile?['tipe_nilai'] as String? ?? 'rapor';
                      
                      final labelText = tipeNilai == 'ipk' ? 'profile.nilai_ipk'.tr() : 'profile.nilai_rapor'.tr();
                      
                      final hasScore = rawScore != null && rawScore != 0 && rawScore != 0.0;
                      final reportScore = hasScore
                          ? rawScore.toString()
                          : 'profile.belum_diisi'.tr();
                      
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(labelText, style: const TextStyle(color: Colors.black54)),
                            Text(
                              reportScore,
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
                    label: "profile.edit_profil".tr(), 
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
                  ActionCard(
                    icon: Icons.language, 
                    label: "profile.bahasa".tr(), 
                    isDestructive: false,
                    onTap: () => _showLanguageDialog(context),
                  ),
                  const SizedBox(height: 10),
                  ActionCard(
                    icon: Icons.logout, 
                    label: "profile.logout".tr(), 
                    isDestructive: true,
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text('profile.logout'.tr()),
                          content: Text('profile.konfirmasi_logout'.tr()),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: Text('profile.batal'.tr()),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: Text('profile.logout'.tr(), style: const TextStyle(color: Colors.red)),
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

  String _translateTipsText(String text, String langCode) {
    if (langCode != 'en') return text;
    
    String translated = text;
    
    // 1. Translate headers
    translated = translated.replaceAll('Ringkasan Evaluasi:', 'Evaluation Summary:');
    translated = translated.replaceAll('Langkah Peningkatan:', 'Improvement Steps:');
    
    // 2. Translate template patterns
    translated = translated.replaceAll(
      'Profilmu menunjukkan beberapa potensi yang bisa ditingkatkan, terutama pada aspek',
      'Your profile shows some potential that can be improved, especially in the aspect of'
    );
    translated = translated.replaceAll(
      'memiliki beberapa kelebihan yang bisa dimanfaatkan, namun masih memerlukan perbaikan dalam beberapa aspek untuk meningkatkan kesiapan beasiswa.',
      'has several advantages that can be utilized, but still requires improvement in several aspects to increase scholarship readiness.'
    );
    translated = translated.replaceAll(
      'memiliki beberapa kelebihan seperti',
      'has several advantages such as'
    );
    translated = translated.replaceAll(
      ', namun masih memerlukan perbaikan dalam',
      ', but still requires improvement in'
    );
    
    // 3. Translate aspects
    translated = translated.replaceAll('**Akademik**', '**Academic**');
    translated = translated.replaceAll('**Finansial**', '**Financial**');
    translated = translated.replaceAll('**Non-Akademik**', '**Non-Academic**');
    translated = translated.replaceAll('**Sertifikat**', '**Certificate**');
    translated = translated.replaceAll('**Motivasi**', '**Motivation**');

    // 4. Translate Indonesian aspect names inside texts
    translated = translated.replaceAll('aspek Akademik', 'Academic aspect');
    translated = translated.replaceAll('aspek Finansial', 'Financial aspect');
    translated = translated.replaceAll('aspek Non-Akademik', 'Non-Academic aspect');
    translated = translated.replaceAll('aspek Sertifikat', 'Certificate aspect');
    translated = translated.replaceAll('aspek Motivasi', 'Motivation aspect');
    translated = translated.replaceAll('kemampuan akademik', 'academic ability');
    translated = translated.replaceAll('prestasi lomba', 'competition achievements');
    translated = translated.replaceAll('keaktifan organisasi', 'organizational activity');
    translated = translated.replaceAll('aktivitas tambahan', 'additional activities');
    translated = translated.replaceAll('dokumen pendukung beasiswa', 'supporting scholarship documents');

    // 5. Translate common sentences / fallback saran
    translated = translated.replaceAll(
      'Tingkatkan nilai akademikmu dengan membuat jadwal belajar teratur dan manfaatkan sumber belajar online.',
      'Improve your academic grades by creating a regular study schedule and utilizing online learning resources.'
    );
    translated = translated.replaceAll(
      'Tingkat nilai akademikmu dengan membuat jadwal belajar teratur dan manfaatkan sumber belajar online.',
      'Improve your academic grades by creating a regular study schedule and utilizing online learning resources.'
    );
    translated = translated.replaceAll(
      'dapat meningkatkan kualitas tugas akhir dan presentasi dengan lebih banyak belajar dan praktik secara teratur.',
      'can improve the quality of final assignments and presentations through more study and regular practice.'
    );
    
    translated = translated.replaceAll(
      'Lengkapi data kondisi finansial dan kumpulkan dokumen pendukung seperti SKTM atau bukti bantuan sosial.',
      'Complete your financial condition details and collect supporting documents such as SKTM or social assistance proof.'
    );
    translated = translated.replaceAll(
      'Lengkapi data kondisi finansial dan kumpulkan dokumen pendukung seperti SKTM atau bukti bantuan sosial untuk memperkuat profil.',
      'Complete your financial condition details and collect supporting documents such as SKTM or social assistance proof to strengthen your profile.'
    );
    
    translated = translated.replaceAll(
      'Aktif ikuti lomba, organisasi, atau kegiatan ekstrakurikuler untuk memperkuat profilmu.',
      'Actively participate in competitions, organizations, or extracurricular activities to strengthen your profile.'
    );
    translated = translated.replaceAll(
      'Berpartisipasi aktif dalam kompetisi lokal atau nasional untuk mengasah kemampuan dan mencari pengalaman baru.',
      'Actively participate in local or national competitions to hone skills and seek new experiences.'
    );
    
    translated = translated.replaceAll(
      'Siapkan surat rekomendasi dari guru/dosen, CV yang rapi, dan sertifikat keahlian khusus.',
      'Prepare recommendation letters from teachers/lecturers, a neat CV, and special skill certificates.'
    );
    translated = translated.replaceAll(
      'Siapkan surat rekomendasi dari guru/dosen, CV yang rapi, dan sertifikat keahlian khusus yang relevan.',
      'Prepare recommendation letters from teachers/lecturers, a neat CV, and relevant special skill certificates.'
    );
    
    translated = translated.replaceAll(
      'Tuliskan dengan jelas tujuan studi dan karir masa depanmu agar lebih meyakinkan penyeleksi.',
      'Clearly write down your study goals and future career plans to convince the selectors.'
    );
    translated = translated.replaceAll(
      'Tuliskan dengan jelas tujuan studi dan karir masa depan agar lebih meyakinkan penyeleksi beasiswa.',
      'Clearly write down your study goals and future career plans to convince the scholarship selectors.'
    );

    translated = translated.replaceAll('kondisi finansial cukup', 'adequate financial condition');
    translated = translated.replaceAll('tujuan studi dan karir jelas', 'clear study and career goals');

    return translated;
  }

  /// Build formatted tips with proper visual hierarchy
  Widget _buildFormattedTips(BuildContext context, String tipsRaw) {
    final langCode = context.locale.languageCode;
    final translatedTips = _translateTipsText(tipsRaw, langCode);
    final lines = translatedTips.split('\n');
    final List<Widget> children = [];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        children.add(const SizedBox(height: 6));
        continue;
      }

      // Section headers
      if (trimmed == 'Ringkasan Evaluasi:' || trimmed == 'Langkah Peningkatan:' ||
          trimmed == 'Evaluation Summary:' || trimmed == 'Improvement Steps:') {
        children.add(Padding(
          padding: EdgeInsets.only(top: children.isEmpty ? 0 : 6, bottom: 2),
          child: Text(
            trimmed,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.brown,
              fontSize: 13,
            ),
          ),
        ));
        continue;
      }

      // Numbered items: "1. **Aspek**: Saran."
      final numberedMatch = RegExp(r'^(\d+)\.\s*\*\*(.+?)\*\*:\s*(.+)$').firstMatch(trimmed);
      if (numberedMatch != null) {
        final number = numberedMatch.group(1)!;
        final aspect = numberedMatch.group(2)!;
        final saran = numberedMatch.group(3)!;

        children.add(Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$number. ',
                style: const TextStyle(fontSize: 12, color: Colors.brown, fontWeight: FontWeight.w700, height: 1.5),
              ),
              Expanded(
                child: Text.rich(
                  TextSpan(children: [
                    TextSpan(
                      text: '$aspect: ',
                      style: const TextStyle(fontSize: 12, color: Colors.brown, fontWeight: FontWeight.w700, height: 1.5),
                    ),
                    TextSpan(
                      text: saran,
                      style: const TextStyle(fontSize: 12, color: Colors.brown, fontWeight: FontWeight.w400, height: 1.5),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ));
        continue;
      }

      // Regular text
      children.add(Text(
        trimmed,
        style: const TextStyle(fontSize: 12, color: Colors.brown, height: 1.5),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final currentLocale = context.locale;
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.white,
              contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "profile.pilih_bahasa".tr(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF002248),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "profile.pilih_bahasa_desc".tr(),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildLanguageOption(
                    context,
                    title: "Bahasa Indonesia",
                    isSelected: currentLocale.languageCode == 'id',
                    onTap: () {
                      context.setLocale(const Locale('id'));
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildLanguageOption(
                    context,
                    title: "English",
                    isSelected: currentLocale.languageCode == 'en',
                    onTap: () {
                      context.setLocale(const Locale('en'));
                      setState(() {});
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, {
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        onTap();
        Future.delayed(const Duration(milliseconds: 150), () {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFECF1FF) : const Color(0xFFFBFBFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF002248) : Colors.black12,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? const Color(0xFF002248) : Colors.black87,
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF002248) : Colors.grey.shade400,
                  width: isSelected ? 6 : 2,
                ),
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
