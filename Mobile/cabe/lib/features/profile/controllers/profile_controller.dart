import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cabe/core/providers/user_profile_provider.dart';
import 'package:cabe/features/progress/controllers/progress_controller.dart';
import '../models/profile_model.dart';

class ProfileController extends Notifier<ProfileModel> {
  @override
  ProfileModel build() {
    final profileAsync = ref.watch(userProfileProvider);
    final progressState = ref.watch(progressProvider);

    // Extract database profile values
    final dbProfile = profileAsync.value;
    final name = dbProfile?['nama_lengkap'] as String? ?? '';
    final school = dbProfile?['nama_sekolah'] as String? ?? '';
    final grade = dbProfile?['kelas'] as String? ?? '';
    final major = dbProfile?['jurusan'] as String? ?? '';

    // ─── Readiness scores from Firestore (saved by ReadinessScoreScreen) ───
    final double totalScore = _toDouble(dbProfile?['readiness_total']);
    final double akademik = _toDouble(dbProfile?['readiness_akademik']);
    final double finansial = _toDouble(dbProfile?['readiness_finansial']);
    final double nonAkademik = _toDouble(dbProfile?['readiness_non_akademik']);
    final double sertifikat = _toDouble(dbProfile?['readiness_sertifikat']);
    final double motivasi = _toDouble(dbProfile?['readiness_motivasi']);
    final String label = dbProfile?['readiness_label'] as String? ?? '';
    final String tips = dbProfile?['readiness_tips'] as String? ?? '';

    // Status from Firestore label, or derive from score
    String status;
    if (label.isNotEmpty) {
      status = label;
    } else if (totalScore == 0) {
      status = 'Belum Dinilai';
    } else if (totalScore >= 80) {
      status = 'Sangat Siap!';
    } else if (totalScore >= 60) {
      status = 'Siap';
    } else if (totalScore >= 40) {
      status = 'Cukup Siap';
    } else {
      status = 'Perlu Persiapan';
    }

    // ─── Minat & Bakat ───
    List<String> interests = [];
    if (dbProfile?['minat_bakat'] != null) {
      final mb = dbProfile!['minat_bakat'];
      if (mb is List) {
        interests = List<String>.from(mb);
      } else if (mb is String && mb.isNotEmpty) {
        interests = mb.split(',').map((e) => e.trim()).toList();
      }
    }

    // ─── Prestasi ───
    List<String> achievements = [];
    if (dbProfile?['prestasi'] != null) {
      final pr = dbProfile!['prestasi'];
      if (pr is List) {
        achievements = pr.map((e) => e.toString()).toList();
      } else if (pr is String && pr.isNotEmpty) {
        achievements = pr.split(',').map((e) => e.trim()).toList();
      }
    }

    // ─── Nilai Rapor ───
    final rawNilai = dbProfile?['nilai_rata_rata'];
    final double nilaiRataRata = (rawNilai is num) ? rawNilai.toDouble() : 0.0;

    final rawToeic = dbProfile?['skor_toeic'];
    final int toeicScoreVal = (rawToeic is num) ? rawToeic.toInt() : 0;

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
      score: totalScore.round(),
      progress: totalScore / 100.0,
      status: status,
      tips: tips,
      academicScore: akademik,
      academicMax: 40,
      academicProgress: akademik / 40.0,
      financialScore: finansial,
      financialMax: 25,
      financialProgress: finansial / 25.0,
      nonAcademicScore: nonAkademik,
      nonAcademicMax: 25,
      nonAcademicProgress: nonAkademik / 25.0,
      certRecScore: sertifikat,
      certRecMax: 5,
      certRecProgress: sertifikat / 5.0,
      motivationScore: motivasi,
      motivationMax: 5,
      motivationProgress: motivasi / 5.0,
      savedCount: savedCount,
      reviewedCount: reviewedCount,
      acceptedCount: acceptedCount,
      interests: interests,
      achievements: achievements,
      reportScore: nilaiRataRata.round(),
      toeicScore: toeicScoreVal,
    );
  }

  /// Safely convert Firestore value to double
  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

final profileControllerProvider = NotifierProvider<ProfileController, ProfileModel>(() {
  return ProfileController();
});
