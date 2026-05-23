import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cabe/core/providers/user_profile_provider.dart';
import 'package:cabe/features/checklist/controllers/checklist_controller.dart';
import 'package:cabe/features/progress/controllers/progress_controller.dart';
import '../models/profile_model.dart';

class ProfileController extends Notifier<ProfileModel> {
  @override
  ProfileModel build() {
    final profileAsync = ref.watch(userProfileProvider);
    final checklistView = ref.watch(checklistViewProvider);
    final progressState = ref.watch(progressProvider);

    // Extract database profile values
    final dbProfile = profileAsync.value;
    final name = dbProfile?['nama_lengkap'] as String? ?? '';
    final school = dbProfile?['nama_sekolah'] as String? ?? '';
    final grade = dbProfile?['kelas'] as String? ?? '';
    final major = dbProfile?['jurusan'] as String? ?? '';
    
    // 1. Nilai akademik (IPK/Nilai) (Max 40)
    final rawNilai = dbProfile?['nilai_rata_rata'];
    final double nilaiRataRata = (rawNilai is num) ? rawNilai.toDouble() : 0.0;
    // Scale 0-4 GPA to 0-100 scale, keep if already 0-100 scale
    final nilaiScaled = nilaiRataRata > 10 ? nilaiRataRata : nilaiRataRata * 25.0;
    final int gradePoints = ((nilaiScaled / 100) * 30).clamp(0, 30).round();

    final rawToeic = dbProfile?['skor_toeic'];
    final int toeicScoreVal = (rawToeic is num) ? rawToeic.toInt() : 0;
    int toeicPoints = 0;
    if (toeicScoreVal > 0) {
      if (toeicScoreVal >= 800) toeicPoints = 10;
      else if (toeicScoreVal >= 600) toeicPoints = 7;
      else if (toeicScoreVal >= 400) toeicPoints = 4;
      else toeicPoints = 2;
    }
    final int academicScore = gradePoints + toeicPoints;

    // 2. Kebutuhan Finansial (Max 25)
    final List<String> sumberPendanaan = dbProfile?['sumber_pendanaan'] is List
        ? List<String>.from(dbProfile!['sumber_pendanaan'])
        : [];
    final List<String> jenisBeasiswa = dbProfile?['jenis_beasiswa'] is List
        ? List<String>.from(dbProfile!['jenis_beasiswa'])
        : [];
    final List<String> cakupanBiaya = dbProfile?['cakupan_biaya'] is List
        ? List<String>.from(dbProfile!['cakupan_biaya'])
        : [];

    int financialScore = 0;
    if (jenisBeasiswa.contains('Beasiswa Kurang Mampu')) {
      financialScore += 15;
    } else if (jenisBeasiswa.isNotEmpty) {
      financialScore += 5;
    }
    if (cakupanBiaya.isNotEmpty) {
      financialScore += 5;
    }
    if (sumberPendanaan.isNotEmpty) {
      financialScore += 5;
    }

    // 3. Prestasi Non-Akademik (Max 25)
    List<String> interests = [];
    if (dbProfile?['minat_bakat'] != null) {
      final mb = dbProfile!['minat_bakat'];
      if (mb is List) {
        interests = List<String>.from(mb);
      } else if (mb is String && mb.isNotEmpty) {
        interests = mb.split(',').map((e) => e.trim()).toList();
      }
    }
    final double interestPoints = (interests.length * 2.5).clamp(0.0, 10.0);

    List<String> achievements = [];
    if (dbProfile?['prestasi'] != null) {
      final pr = dbProfile!['prestasi'];
      if (pr is List) {
        achievements = pr.map((e) => e.toString()).toList();
      } else if (pr is String && pr.isNotEmpty) {
        achievements = pr.split(',').map((e) => e.trim()).toList();
      }
    }
    final double achievementPoints = (achievements.length * 5.0).clamp(0.0, 15.0);
    final int nonAcademicScore = (interestPoints + achievementPoints).round();

    // 4. Sertifikat / Kualifikasi Khusus / Surat Rekomendasi (Max 5)
    int certRecScore = 0;
    if (achievements.isNotEmpty) {
      certRecScore += 3;
    }
    bool hasCheckedRecOrCert = false;
    for (final section in checklistView.sections) {
      for (final item in section.items) {
        final titleLower = item.title.toLowerCase();
        if (item.isChecked &&
            (titleLower.contains('rekomendasi') ||
             titleLower.contains('sertifikat') ||
             titleLower.contains('portofolio') ||
             titleLower.contains('cv') ||
             titleLower.contains('riwayat'))) {
          hasCheckedRecOrCert = true;
          break;
        }
      }
    }
    if (hasCheckedRecOrCert) {
      certRecScore += 2;
    }

    // 5. Motivasi / Rencana Karir (Max 5)
    int motivationScore = 0;
    int essayChecked = 0;
    int essayTotal = 0;
    for (final section in checklistView.sections) {
      for (final item in section.items) {
        final titleLower = item.title.toLowerCase();
        if (section.title.toLowerCase() == 'esai' ||
            titleLower.contains('proposal') ||
            titleLower.contains('rencana')) {
          essayTotal++;
          if (item.isChecked) essayChecked++;
        }
      }
    }
    if (essayTotal > 0) {
      motivationScore = ((essayChecked / essayTotal) * 5).round();
    } else {
      if (interests.isNotEmpty) {
        motivationScore = 3;
      }
    }

    // Total Score (Max 100)
    final totalScore = academicScore +
        financialScore +
        nonAcademicScore +
        certRecScore +
        motivationScore;
    
    // Status Text
    String status = 'Belum Siap';
    if (totalScore == 0) {
      status = 'Belum Dinilai';
    } else if (totalScore >= 80) {
      status = 'Sangat Siap';
    } else if (totalScore >= 50) {
      status = 'Cukup Siap';
    } else if (totalScore >= 25) {
      status = 'Kurang Siap';
    }

    // Counts from progressState
    int savedCount = 0;
    int reviewedCount = 0;
    int acceptedCount = 0;
    for (final item in progressState.items) {
      if (item.status == ProgressStatus.tersimpan) savedCount++;
      else if (item.status == ProgressStatus.ditinjau) reviewedCount++;
      else if (item.status == ProgressStatus.diterima) acceptedCount++;
    }

    return ProfileModel(
      name: name,
      school: school,
      grade: grade,
      major: major,
      score: totalScore,
      progress: totalScore / 100.0,
      status: status,
      academicScore: academicScore,
      academicMax: 40,
      academicProgress: academicScore / 40.0,
      financialScore: financialScore,
      financialMax: 25,
      financialProgress: financialScore / 25.0,
      nonAcademicScore: nonAcademicScore,
      nonAcademicMax: 25,
      nonAcademicProgress: nonAcademicScore / 25.0,
      certRecScore: certRecScore,
      certRecMax: 5,
      certRecProgress: certRecScore / 5.0,
      motivationScore: motivationScore,
      motivationMax: 5,
      motivationProgress: motivationScore / 5.0,
      savedCount: savedCount,
      reviewedCount: reviewedCount,
      acceptedCount: acceptedCount,
      interests: interests,
      achievements: achievements,
      reportScore: nilaiRataRata.round(),
      toeicScore: toeicScoreVal,
    );
  }
}

final profileControllerProvider = NotifierProvider<ProfileController, ProfileModel>(() {
  return ProfileController();
});
