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

  /// Kirim profil user ke AI backend dan dapatkan persentase kecocokan
  /// [scholarshipContext] adalah deskripsi singkat syarat beasiswanya
  static Future<int> getMatchPercentage({
    required double nilaiRataRata,
    required String kelas,
    required String jurusan,
    required List<String> minatBakat,
    required List<String> prestasi,
    required String scholarshipTitle,
    required Map<String, String> scholarshipCriteria,
  }) async {
    try {
      // Normalisasi nilai (jika skala 0-100, bagi 10)
      final nilaiNormalized = nilaiRataRata > 10 ? nilaiRataRata / 10 : nilaiRataRata;
      final minNilaiStr = scholarshipCriteria['Min. Nilai Rapor'];
      final minNilai = minNilaiStr != null ? (double.tryParse(minNilaiStr) ?? 70.0) : 70.0;

      final body = {
        'ipk': nilaiNormalized,
        'semester': _kelasToSemester(kelas),
        'jurusan': jurusan.isNotEmpty ? jurusan : 'Umum',
        'provinsi': 'Indonesia',
        'pendapatan_ortu': 3000000,
        'prestasi_count': prestasi.length,
        'scholarship_title': scholarshipTitle,
        'min_nilai': minNilai,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/api/match'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Backend sekarang mengembalikan field match_percentage langsung
        final pct = data['match_percentage'] as int? ?? 0;
        if (pct > 0) return pct;
        // Fallback: coba ekstrak dari teks jika field 0
        final resultText = data['result'] as String? ?? '';
        return _extractPercentage(resultText, scholarshipTitle, nilaiRataRata, kelas, jurusan, minatBakat, prestasi, scholarshipCriteria);
      } else {
        debugPrint('AI API error: ${response.statusCode}');
        return _fallbackMatch(nilaiRataRata, kelas, jurusan, minatBakat, prestasi, scholarshipCriteria);
      }
    } catch (e) {
      debugPrint('AI Service Error (fallback aktif): $e');
      return _fallbackMatch(nilaiRataRata, kelas, jurusan, minatBakat, prestasi, scholarshipCriteria);
    }
  }

  /// Ekstrak angka persentase dari teks respons AI
  static int _extractPercentage(
    String text,
    String scholarshipTitle,
    double nilai,
    String kelas,
    String jurusan,
    List<String> minat,
    List<String> prestasi,
    Map<String, String> criteria,
  ) {
    // Cari pola angka persentase di dalam teks (misal: "85%", "70%", "85 persen")
    final regexPercent = RegExp(r'(\d{1,3})\s*%');
    final regexPersen = RegExp(r'(\d{1,3})\s*persen', caseSensitive: false);

    Iterable<RegExpMatch> matches = regexPercent.allMatches(text);
    if (matches.isEmpty) {
      matches = regexPersen.allMatches(text);
    }

    if (matches.isNotEmpty) {
      final values = matches
          .map((m) => int.tryParse(m.group(1) ?? '0') ?? 0)
          .where((v) => v > 0 && v <= 100)
          .toList();

      if (values.isNotEmpty) {
        // Ambil rata-rata semua angka persentase yang ditemukan
        final avg = values.reduce((a, b) => a + b) ~/ values.length;
        return avg.clamp(0, 100);
      }
    }

    // Jika AI tidak bisa ekstrak, fallback ke rule-based
    return _fallbackMatch(nilai, kelas, jurusan, minat, prestasi, criteria);
  }

  /// Rule-based fallback jika AI backend tidak tersedia (Publik untuk Instant UI loading)
  static int fallbackMatch({
    required double nilaiRataRata,
    required String kelas,
    required String jurusan,
    required List<String> minatBakat,
    required List<String> prestasi,
    required Map<String, String> scholarshipCriteria,
  }) {
    return _fallbackMatch(nilaiRataRata, kelas, jurusan, minatBakat, prestasi, scholarshipCriteria);
  }

  /// Rule-based fallback jika AI backend tidak tersedia
  static int _fallbackMatch(
    double nilai,
    String kelas,
    String jurusan,
    List<String> minat,
    List<String> prestasi,
    Map<String, String> criteria,
  ) {
    int score = 0;

    // Cek nilai minimum
    final minNilaiStr = criteria['Min. Nilai Rapor'];
    if (minNilaiStr != null) {
      final minNilai = double.tryParse(minNilaiStr) ?? 0;
      final nilaiScaled = nilai > 10 ? nilai : nilai * 10; // normalisasi 0-10 ke 0-100
      if (nilaiScaled >= minNilai) {
        score += 40;
      } else if (nilaiScaled >= minNilai - 5) {
        score += 20;
      }
    } else {
      score += 40;
    }

    // Cek kelas
    final kelasCriteria = criteria['Kelas'] ?? '';
    if (kelasCriteria.contains(kelas.replaceAll('Kelas ', '').replaceAll(' ', ''))) {
      score += 30;
    } else if (kelasCriteria.isEmpty) {
      score += 30;
    }

    // Cek jurusan
    final jurusanCriteria = criteria['Jurusan'] ?? '';
    if (jurusanCriteria.contains(jurusan) || jurusanCriteria.contains('Semua')) {
      score += 20;
    } else if (jurusanCriteria.isEmpty) {
      score += 20;
    }

    // Bonus prestasi
    if (prestasi.isNotEmpty) score += 10;

    return score.clamp(0, 100);
  }

  static int _kelasToSemester(String kelas) {
    final k = kelas.replaceAll(RegExp(r'[^0-9]'), '');
    final num = int.tryParse(k) ?? 10;
    // Kelas 10 = semester 1, Kelas 11 = semester 3, Kelas 12 = semester 5
    return ((num - 9) * 2) - 1;
  }
}
