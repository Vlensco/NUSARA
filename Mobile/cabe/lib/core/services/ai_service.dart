import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;

class AiMatchResult {
  final String scholarshipId;
  final int matchPercentage;

  AiMatchResult({required this.scholarshipId, required this.matchPercentage});
}

class AiService {
  // URL AI backend yang sudah di-deploy di HuggingFace Spaces
  static const String _baseUrl = 'https://andika121-cabe-api.hf.space';

  /// Mengecek apakah server AI sedang aktif
  static Future<bool> checkServerHealth() async {
    try {
      final rootResponse = await http
          .get(Uri.parse('$_baseUrl/'))
          .timeout(const Duration(seconds: 15));

      if (rootResponse.statusCode == 200) {
        final data = jsonDecode(rootResponse.body);
        debugPrint('AI Server is ONLINE: $data');
        return data['status'] == 'ok';
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

      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/match'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 60));

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
  // API Docs: POST /readiness-score
  // ═══════════════════════════════════════════

  /// Normalisasi nilai string agar sesuai dengan format API (lowercase, tanpa spasi berlebih di sekitar tanda)
  static String _norm(String v) {
    return v
        .toLowerCase()
        .replaceAll(' - ', '-')
        .replaceAll('> ', '>')
        .replaceAll('< ', '<')
        .trim();
  }

  /// Kirim profil ke AI backend dan dapatkan skor kesiapan + tips dari AI
  /// Endpoint: POST /readiness-score
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
      // Bangun body sesuai API docs: nested objects, nilai harus lowercase (case-sensitive)
      final Map<String, dynamic> body = {
        'nama': userName,
        // Kirim ipk ATAU rapor, tidak perlu keduanya
        if (tipeNilai == 'ipk') 'ipk': nilaiRapor else 'rapor': nilaiRapor,
        'finansial': {
          'penghasilan': _norm(penghasilanOrtu),
          'bantuan_sosial': _norm(bantuanSosial),
          'tanggungan': _norm(tanggungan),
          'pekerjaan_ortu': _norm(pekerjaanOrtu),
        },
        'non_akademik': {
          'level_prestasi': _norm(levelPrestasi),
          'jumlah_prestasi': _norm(jumlahPrestasi),
          'organisasi': _norm(organisasi),
          'aktivitas_tambahan': _norm(aktivitasTambahan),
        },
        // dokumen adalah array — semua value dilowercase
        'dokumen': dokumenPendukung.map((d) => _norm(d)).toList(),
        'motivasi': {
          'tujuan_studi': _norm(kejelasanTujuan),
          'tujuan_karir': _norm(tujuanKarir),
          'keterkaitan': _norm(keterkaitan),
        },
      };

      final response = await http
          .post(
            Uri.parse('$_baseUrl/readiness-score'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final detailSkor = data['detail_skor'] as Map<String, dynamic>? ?? {};
        final kelebihan = (data['kelebihan'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [];
        final gap = (data['gap'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [];

        return ReadinessResult(
          totalScore: (data['skor'] as num).toDouble(),
          skorAkademik: (detailSkor['akademik'] as num? ?? 0).toDouble(),
          skorFinansial: (detailSkor['finansial'] as num? ?? 0).toDouble(),
          skorNonAkademik: (detailSkor['non_akademik'] as num? ?? 0).toDouble(),
          skorSertifikat: (detailSkor['dokumen'] as num? ?? 0).toDouble(),
          skorMotivasi: (detailSkor['motivasi'] as num? ?? 0).toDouble(),
          label: data['kategori'] as String? ?? '',
          tips: data['saran_peningkatan'] as String? ?? '',
          kelebihan: kelebihan,
          gap: gap,
        );
      } else {
        debugPrint('Readiness API error: ${response.statusCode} — ${response.body}');
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
    final pengNorm = _norm(penghasilanOrtu);
    if (pengNorm == '<1 juta' || pengNorm == '< 1 juta') skorFin += 40;
    else if (pengNorm == '1-3 juta' || pengNorm == '1 - 3 juta') skorFin += 30;
    else if (pengNorm == '3-5 juta' || pengNorm == '3 - 5 juta') skorFin += 20;
    else skorFin += 10;
    if (_norm(bantuanSosial) == 'ada') skorFin += 25;
    final tangNorm = _norm(tanggungan);
    if (tangNorm == '>4' || tangNorm == '> 4') skorFin += 20;
    else if (tangNorm == '3-4' || tangNorm == '3 - 4') skorFin += 15;
    else if (tangNorm == '1-2' || tangNorm == '1 - 2') skorFin += 10;
    final pkjNorm = _norm(pekerjaanOrtu);
    if (pkjNorm == 'tidak tetap') skorFin += 15;
    else if (pkjNorm == 'informal') skorFin += 10;
    else if (pkjNorm == 'tetap') skorFin += 5;
    final finalFinansial = (skorFin / 100) * 25;

    // 3. Non-Akademik (25%)
    double skorNA = 0;
    final lvlNorm = _norm(levelPrestasi);
    if (lvlNorm == 'internasional') skorNA += 50;
    else if (lvlNorm == 'nasional') skorNA += 45;
    else if (lvlNorm == 'provinsi') skorNA += 35;
    else if (lvlNorm == 'sekolah') skorNA += 25;
    final jmlNorm = _norm(jumlahPrestasi);
    if (jmlNorm == '>3' || jmlNorm == '> 3') skorNA += 10;
    else if (jmlNorm == '2-3' || jmlNorm == '2 - 3') skorNA += 7;
    else if (jmlNorm == '1') skorNA += 5;
    final orgNorm = _norm(organisasi);
    if (orgNorm == 'ketua / leader' || orgNorm == 'ketua/leader') skorNA += 30;
    else if (orgNorm == 'pengurus aktif') skorNA += 20;
    else if (orgNorm == 'anggota') skorNA += 10;
    final aktNorm = _norm(aktivitasTambahan);
    if (aktNorm.startsWith('aktif')) skorNA += 10;
    else if (aktNorm == 'pernah ikut') skorNA += 5;
    final finalNA = (skorNA / 100) * 25;

    // 4. Sertifikat/Dokumen (5%)
    double skorSert = 0;
    final dokNorm = dokumenPendukung.map((d) => _norm(d)).toList();
    if (dokNorm.contains('rekomendasi')) skorSert += 80;
    if (dokNorm.contains('cv')) skorSert += 10;
    if (dokNorm.contains('sertifikat khusus')) skorSert += 10;
    final finalSert = (skorSert / 100) * 5;

    // 5. Motivasi (5%)
    double skorMot = 0;
    final tujNorm = _norm(kejelasanTujuan);
    if (tujNorm == 'sudah jelas dan spesifik') skorMot += 40;
    else if (tujNorm.contains('sudah ada gambaran') || tujNorm.contains('gambaran')) skorMot += 25;
    else if (tujNorm.contains('belum yakin')) skorMot += 10;
    final karNorm = _norm(tujuanKarir);
    if (karNorm == 'sudah jelas') skorMot += 40;
    else if (karNorm == 'masih umum') skorMot += 25;
    else if (karNorm.contains('belum')) skorMot += 10;
    final ketNorm = _norm(keterkaitan);
    if (ketNorm == 'sangat sesuai') skorMot += 20;
    else if (ketNorm == 'cukup sesuai') skorMot += 10;
    final finalMot = (skorMot / 100) * 5;

    final total = finalAkademik + finalFinansial + finalNA + finalSert + finalMot;

    // Kategori sesuai API: "Siap" (>=80), "Perlu sedikit persiapan" (60-79), "Perlu persiapan lebih" (<60)
    String label;
    if (total >= 80) {
      label = 'Siap';
    } else if (total >= 60) {
      label = 'Perlu sedikit persiapan';
    } else {
      label = 'Perlu persiapan lebih';
    }

    // Tips berdasarkan area terlemah
    final areas = {
      'Akademik': rawAkademik,
      'Finansial': skorFin,
      'Non-Akademik': skorNA,
      'Sertifikat': skorSert,
      'Motivasi': skorMot,
    };
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
      kelebihan: [],
      gap: [],
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
  /// Aspek yang sudah baik (dari API)
  final List<String> kelebihan;
  /// Aspek yang perlu ditingkatkan (dari API)
  final List<String> gap;

  ReadinessResult({
    required this.totalScore,
    required this.skorAkademik,
    required this.skorFinansial,
    required this.skorNonAkademik,
    required this.skorSertifikat,
    required this.skorMotivasi,
    required this.label,
    required this.tips,
    this.kelebihan = const [],
    this.gap = const [],
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
