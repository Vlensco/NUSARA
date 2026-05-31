import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AiMatchResult {
  final String scholarshipId;
  final int matchPercentage;

  AiMatchResult({required this.scholarshipId, required this.matchPercentage});
}

class AiService {
  // Android emulator -> 10.0.2.2, iOS simulator/real device/Mac/Web -> localhost
  static String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://localhost:8000';
  }

  /// Mengecek apakah server AI sedang aktif (memanggil endpoint / dan /health)
  static Future<bool> checkServerHealth() async {
    try {
      // 1. Memanggil endpoint Root (/)
      final rootResponse = await http.get(Uri.parse('$_baseUrl/')).timeout(const Duration(seconds: 5));
      
      // 2. Memanggil endpoint Health (/health)
      final healthResponse = await http.get(Uri.parse('$_baseUrl/health')).timeout(const Duration(seconds: 5));
      
      if (rootResponse.statusCode == 200 && healthResponse.statusCode == 200) {
        debugPrint('AI Server is ONLINE: ${rootResponse.body}');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('AI Server is OFFLINE: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════
  // LIGHTWEIGHT MATCHING (Pencocokan Beasiswa)
  // ═══════════════════════════════════════════

  /// Kirim profil user + syarat beasiswa ke backend untuk pencocokan.
  /// Backend menghitung match secara deterministik, AI hanya buat pesan motivasi.
  static Future<MatchResult> getMatch({
    required String userJenjang,
    required int userUsia,
    required String userBidangStudi,
    required double userIpk,
    required String scholarshipTitle,
    required List<String> reqJenjang,
    required int reqBatasUsia,
    required List<String> reqBidangStudi,
    required double reqMinIpk,
  }) async {
    try {
      final body = {
        'user_jenjang': userJenjang,
        'user_usia': userUsia,
        'user_bidang_studi': userBidangStudi,
        'user_ipk': userIpk,
        'scholarship_title': scholarshipTitle,
        'req_jenjang': reqJenjang,
        'req_batas_usia': reqBatasUsia,
        'req_bidang_studi': reqBidangStudi,
        'req_min_ipk': reqMinIpk,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/api/match'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return MatchResult(
          matchPercentage: data['match_percentage'] as int? ?? 0,
          matchedParams: data['matched_params'] as int? ?? 0,
          totalParams: data['total_params'] as int? ?? 4,
          aiMessage: data['ai_message'] as String? ?? '',
        );
      } else {
        debugPrint('Match API error: ${response.statusCode}');
        return _fallbackLightweightMatch(
          userJenjang, userUsia, userBidangStudi, userIpk,
          scholarshipTitle, reqJenjang, reqBatasUsia, reqBidangStudi, reqMinIpk,
        );
      }
    } catch (e) {
      debugPrint('Match Service Error (fallback): $e');
      return _fallbackLightweightMatch(
        userJenjang, userUsia, userBidangStudi, userIpk,
        scholarshipTitle, reqJenjang, reqBatasUsia, reqBidangStudi, reqMinIpk,
      );
    }
  }

  /// Fallback client-side lightweight matching jika AI backend offline
  static MatchResult _fallbackLightweightMatch(
    String userJenjang,
    int userUsia,
    String userBidangStudi,
    double userIpk,
    String scholarshipTitle,
    List<String> reqJenjang,
    int reqBatasUsia,
    List<String> reqBidangStudi,
    double reqMinIpk,
  ) {
    int totalParams = 4;
    int fulfilled = 0;

    // 1. Jenjang Pendidikan
    if (reqJenjang.contains(userJenjang) || reqJenjang.contains('Semua Jenjang')) {
      fulfilled++;
    }
    // 2. Batas Usia
    if (userUsia <= reqBatasUsia) {
      fulfilled++;
    }
    // 3. Bidang Studi
    if (reqBidangStudi.contains(userBidangStudi) || reqBidangStudi.contains('Semua Jurusan')) {
      fulfilled++;
    }
    // 4. Nilai Akademik
    if (userIpk >= reqMinIpk) {
      fulfilled++;
    }

    final percentage = ((fulfilled / totalParams) * 100).toInt();

    // Generate fallback message
    String aiMessage;
    if (percentage >= 70) {
      aiMessage = 'Selamat! Profilmu sangat cocok dengan $scholarshipTitle. Yuk segera siapkan dokumen pendaftarannya!';
    } else {
      aiMessage = 'Jangan menyerah! Kamu masih bisa meningkatkan profilmu. Yuk cari beasiswa lain yang lebih pas untukmu!';
    }

    return MatchResult(
      matchPercentage: percentage,
      matchedParams: fulfilled,
      totalParams: totalParams,
      aiMessage: aiMessage,
    );
  }

  /// Public fallback untuk instant UI loading (tanpa menunggu backend)
  static MatchResult fallbackMatch({
    required String userJenjang,
    required int userUsia,
    required String userBidangStudi,
    required double userIpk,
    required String scholarshipTitle,
    required List<String> reqJenjang,
    required int reqBatasUsia,
    required List<String> reqBidangStudi,
    required double reqMinIpk,
  }) {
    return _fallbackLightweightMatch(
      userJenjang, userUsia, userBidangStudi, userIpk,
      scholarshipTitle, reqJenjang, reqBatasUsia, reqBidangStudi, reqMinIpk,
    );
  }

  // ═══════════════════════════════════════════
  // READINESS SCORE (Skor Kesiapan Beasiswa)
  // ═══════════════════════════════════════════

  /// Kirim profil ke AI backend dan dapatkan skor kesiapan + tips dari AI
  static Future<ReadinessResult> getReadinessScore({
    required double nilaiRapor,
    required String tipeNilai,
    required String penghasilanOrtu,
    required String bantuanSosial,
    required String tanggungan,
    required String pekerjaanOrtu,
    required String levelPrestasi,
    required String jumlahPrestasi,
    required String organisasi,
    required String aktivitasTambahan,
    required List<String> dokumenPendukung,
    required String kejelasanTujuan,
    required String tujuanKarir,
    required String keterkaitan,
    String userName = 'Pengguna',
  }) async {
    try {
      final body = {
        'user_name': userName,
        'nilai_rapor': nilaiRapor,
        'tipe_nilai': tipeNilai,
        'penghasilan_ortu': penghasilanOrtu,
        'bantuan_sosial': bantuanSosial,
        'tanggungan': tanggungan,
        'pekerjaan_ortu': pekerjaanOrtu,
        'level_prestasi': levelPrestasi,
        'jumlah_prestasi': jumlahPrestasi,
        'organisasi': organisasi,
        'aktivitas_tambahan': aktivitasTambahan,
        'dokumen_pendukung': dokumenPendukung,
        'kejelasan_tujuan': kejelasanTujuan,
        'tujuan_karir': tujuanKarir,
        'keterkaitan': keterkaitan,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/api/readiness'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 45));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ReadinessResult(
          totalScore: (data['total_score'] as num).toDouble(),
          skorAkademik: (data['skor_akademik'] as num).toDouble(),
          skorFinansial: (data['skor_finansial'] as num).toDouble(),
          skorNonAkademik: (data['skor_non_akademik'] as num).toDouble(),
          skorSertifikat: (data['skor_sertifikat'] as num).toDouble(),
          skorMotivasi: (data['skor_motivasi'] as num).toDouble(),
          label: data['label'] as String,
          tips: data['tips'] as String,
        );
      } else {
        debugPrint('Readiness API error: ${response.statusCode}');
        return _fallbackReadiness(
          nilaiRapor, tipeNilai, penghasilanOrtu, bantuanSosial, tanggungan, pekerjaanOrtu,
          levelPrestasi, jumlahPrestasi, organisasi, aktivitasTambahan,
          dokumenPendukung, kejelasanTujuan, tujuanKarir, keterkaitan,
        );
      }
    } catch (e) {
      debugPrint('Readiness Service Error (fallback): $e');
      return _fallbackReadiness(
        nilaiRapor, tipeNilai, penghasilanOrtu, bantuanSosial, tanggungan, pekerjaanOrtu,
        levelPrestasi, jumlahPrestasi, organisasi, aktivitasTambahan,
        dokumenPendukung, kejelasanTujuan, tujuanKarir, keterkaitan,
      );
    }
  }

  /// Fallback client-side scoring jika AI backend tidak tersedia
  static ReadinessResult _fallbackReadiness(
    double nilaiRapor,
    String tipeNilai,
    String penghasilanOrtu,
    String bantuanSosial,
    String tanggungan,
    String pekerjaanOrtu,
    String levelPrestasi,
    String jumlahPrestasi,
    String organisasi,
    String aktivitasTambahan,
    List<String> dokumenPendukung,
    String kejelasanTujuan,
    String tujuanKarir,
    String keterkaitan,
  ) {
    // 1. Akademik (40%) — normalisasi berdasarkan tipe
    double rawAkademik;
    if (tipeNilai == 'ipk') {
      rawAkademik = (nilaiRapor * 25).clamp(0, 100);
    } else {
      rawAkademik = nilaiRapor.clamp(0, 100);
    }
    final finalAkademik = (rawAkademik / 100) * 40;

    // 2. Finansial (25%)
    double skorFin = 0;
    if (penghasilanOrtu == '< 1 juta') skorFin += 40;
    else if (penghasilanOrtu == '1 - 3 Juta') skorFin += 30;
    else if (penghasilanOrtu == '3 - 5 Juta') skorFin += 20;
    else skorFin += 10;
    if (bantuanSosial == 'Ada') skorFin += 25;
    if (tanggungan == '> 4') skorFin += 20;
    else if (tanggungan == '3 - 4') skorFin += 15;
    else if (tanggungan == '1 - 2') skorFin += 10;
    if (pekerjaanOrtu == 'Tidak Tetap') skorFin += 15;
    else if (pekerjaanOrtu == 'Informal') skorFin += 10;
    else if (pekerjaanOrtu == 'Tetap') skorFin += 5;
    final finalFinansial = (skorFin / 100) * 25;

    // 3. Non-Akademik (25%)
    double skorNA = 0;
    if (levelPrestasi == 'Internasional') skorNA += 50;
    else if (levelPrestasi == 'Nasional') skorNA += 45;
    else if (levelPrestasi == 'Provinsi') skorNA += 35;
    else if (levelPrestasi == 'Sekolah') skorNA += 25;
    if (jumlahPrestasi == '> 3') skorNA += 10;
    else if (jumlahPrestasi == '2 - 3') skorNA += 7;
    else if (jumlahPrestasi == '1') skorNA += 5;
    if (organisasi == 'Ketua / Leader') skorNA += 30;
    else if (organisasi == 'Pengurus Aktif') skorNA += 20;
    else if (organisasi == 'Anggota') skorNA += 10;
    if (aktivitasTambahan == 'Aktif (>2 kegiatan)') skorNA += 10;
    else if (aktivitasTambahan == 'Pernah ikut') skorNA += 5;
    final finalNA = (skorNA / 100) * 25;

    // 4. Sertifikat (5%)
    double skorSert = 0;
    if (dokumenPendukung.contains('Rekomendasi')) skorSert += 80;
    if (dokumenPendukung.contains('CV')) skorSert += 10;
    if (dokumenPendukung.contains('Sertifikat Khusus')) skorSert += 10;
    final finalSert = (skorSert / 100) * 5;

    // 5. Motivasi (5%)
    double skorMot = 0;
    if (kejelasanTujuan == 'Sudah jelas dan spesifik') skorMot += 40;
    else if (kejelasanTujuan == 'Sudah ada gambaran') skorMot += 25;
    else if (kejelasanTujuan == 'Belum yakin') skorMot += 10;
    if (tujuanKarir == 'Sudah jelas') skorMot += 40;
    else if (tujuanKarir == 'Masih umum') skorMot += 25;
    else if (tujuanKarir == 'Belum ada') skorMot += 10;
    if (keterkaitan == 'Sangat sesuai') skorMot += 20;
    else if (keterkaitan == 'Cukup sesuai') skorMot += 10;
    final finalMot = (skorMot / 100) * 5;

    final total = finalAkademik + finalFinansial + finalNA + finalSert + finalMot;

    String label;
    if (total >= 80) {
      label = 'Sangat Siap!';
    } else if (total >= 60) {
      label = 'Siap';
    } else if (total >= 40) {
      label = 'Cukup Siap';
    } else {
      label = 'Perlu Persiapan';
    }

    // Tips berdasarkan area terlemah — format terstruktur
    final areas = {
      'Akademik': rawAkademik,
      'Finansial': skorFin,
      'Non-Akademik': skorNA,
      'Sertifikat': skorSert,
      'Motivasi': skorMot,
    };
    // Sort by score ascending (weakest first)
    final sortedAreas = areas.entries.toList()..sort((a, b) => a.value.compareTo(b.value));
    final top3 = sortedAreas.take(3).toList();

    final fallbackSaran = {
      'Akademik': 'Tingkatkan nilai akademikmu dengan membuat jadwal belajar teratur dan manfaatkan sumber belajar online.',
      'Finansial': 'Lengkapi data kondisi finansial dan kumpulkan dokumen pendukung seperti SKTM atau bukti bantuan sosial.',
      'Non-Akademik': 'Aktif ikuti lomba, organisasi, atau kegiatan ekstrakurikuler untuk memperkuat profilmu.',
      'Sertifikat': 'Siapkan surat rekomendasi dari guru/dosen, CV yang rapi, dan sertifikat keahlian khusus.',
      'Motivasi': 'Tuliskan dengan jelas tujuan studi dan karir masa depanmu agar lebih meyakinkan penyeleksi.',
    };

    final weakest = sortedAreas.first.key;
    final ringkasan = 'Profilmu menunjukkan beberapa potensi yang bisa ditingkatkan, terutama pada aspek $weakest.';

    final langkah = top3.asMap().entries.map((e) {
      final aspect = e.value.key;
      final saran = fallbackSaran[aspect] ?? 'Perkuat aspek ini untuk meningkatkan skor kesiapanmu.';
      return '${e.key + 1}. **$aspect**: $saran';
    }).join('\n');

    final formattedTips = 'Ringkasan Evaluasi:\n$ringkasan\n\nLangkah Peningkatan:\n$langkah';

    return ReadinessResult(
      totalScore: double.parse(total.toStringAsFixed(2)),
      skorAkademik: double.parse(finalAkademik.toStringAsFixed(2)),
      skorFinansial: double.parse(finalFinansial.toStringAsFixed(2)),
      skorNonAkademik: double.parse(finalNA.toStringAsFixed(2)),
      skorSertifikat: double.parse(finalSert.toStringAsFixed(2)),
      skorMotivasi: double.parse(finalMot.toStringAsFixed(2)),
      label: label,
      tips: formattedTips,
    );
  }
}

/// Model untuk hasil skor kesiapan beasiswa
class ReadinessResult {
  final double totalScore;
  final double skorAkademik;
  final double skorFinansial;
  final double skorNonAkademik;
  final double skorSertifikat;
  final double skorMotivasi;
  final String label;
  final String tips;

  ReadinessResult({
    required this.totalScore,
    required this.skorAkademik,
    required this.skorFinansial,
    required this.skorNonAkademik,
    required this.skorSertifikat,
    required this.skorMotivasi,
    required this.label,
    required this.tips,
  });
}

/// Model untuk hasil pencocokan beasiswa (Lightweight Matching)
class MatchResult {
  final int matchPercentage;
  final int matchedParams;
  final int totalParams;
  final String aiMessage;

  MatchResult({
    required this.matchPercentage,
    required this.matchedParams,
    required this.totalParams,
    required this.aiMessage,
  });
}
