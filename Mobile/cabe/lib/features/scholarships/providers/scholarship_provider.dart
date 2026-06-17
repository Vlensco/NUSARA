import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cabe/core/constants/scholarship_ids.dart';
import 'package:cabe/core/services/ai_service.dart';
import 'package:cabe/core/providers/user_profile_provider.dart';
import '../models/scholarship.dart';

class ScholarshipNotifier extends Notifier<List<Scholarship>> {
  int _activeLoadId = 0;

  @override
  List<Scholarship> build() {
    _initData();

    // 🔄 Auto-recalculate setiap kali profil user berubah (edit profil)
    ref.listen(userProfileProvider, (previous, next) {
      final prevData = previous?.value;
      final nextData = next.value;
      if (nextData == null) return;
      // Hanya recalculate jika data profil yang relevan berubah
      final fieldsChanged =
          prevData?['nilai_rata_rata'] != nextData['nilai_rata_rata'] ||
          prevData?['kelas'] != nextData['kelas'] ||
          prevData?['jurusan'] != nextData['jurusan'] ||
          prevData?['prestasi'] != nextData['prestasi'];
      if (fieldsChanged) {
        debugPrint('🔄 Profil berubah, recalculate AI match...');
        _loadAiMatchPercentages();
      }
    });

    return _initialData;
  }

  Future<void> _initData() async {
    await _loadSavedState();
    await _loadAiMatchPercentages();
  }

  /// Load saved state dari Firestore
  Future<void> _loadSavedState() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('saved_scholarships')
          .get();

      final savedIds = snapshot.docs.map((doc) => doc.id).toSet();

      state = state.map((s) {
        return s.copyWith(isSaved: savedIds.contains(s.id));
      }).toList();
    } catch (e) {
      debugPrint('Error loading saved scholarships: $e');
    }
  }

  /// Ambil profil user dari Firebase lalu hitung match % via Lightweight Matching
  Future<void> _loadAiMatchPercentages() async {
    final loadId = ++_activeLoadId;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) return;
      if (loadId != _activeLoadId) return;
      final data = doc.data()!;

      // Ambil data profil user
      final rawNilai = data['nilai_rata_rata'];
      final nilaiRataRata = (rawNilai is num) ? rawNilai.toDouble() : 0.0;
      final tipeNilai = (data['tipe_nilai'] as String?) ?? 'rapor';
      final kelas = (data['kelas'] as String?) ?? '';
      final jurusan = (data['jurusan'] as String?) ?? '';
      final jenjangRaw = (data['jenjang'] as String?) ?? '';

      // Tentukan nilai rata-rata yang terstandarisasi untuk dicocokkan (skala 100)
      double userIpkForMatching = nilaiRataRata;
      if (tipeNilai == 'ipk') {
        userIpkForMatching = (nilaiRataRata * 25.0).clamp(0.0, 100.0);
      }

      // Tentukan jenjang dari field Firestore atau fallback dari kelas
      String userJenjang;
      if (jenjangRaw.isNotEmpty) {
        if (jenjangRaw.contains('SMA') || jenjangRaw.contains('SMK') || jenjangRaw.contains('MA')) {
          userJenjang = 'SMA';
        } else if (jenjangRaw.contains('D3')) {
          userJenjang = 'D3';
        } else if (jenjangRaw.contains('S2')) {
          userJenjang = 'S2';
        } else {
          userJenjang = 'S1';
        }
      } else {
        final kelasNum = int.tryParse(kelas.replaceAll(RegExp(r'[^0-9]'), ''));
        if (kelasNum != null && kelasNum >= 10 && kelasNum <= 12) {
          userJenjang = 'SMA';
        } else if (kelasNum != null && kelasNum >= 1 && kelasNum <= 9) {
          userJenjang = 'SMP';
        } else {
          userJenjang = 'S1';
        }
      }

      // Estimasi usia dari kelas
      int userUsia = 18;
      final kelasNum = int.tryParse(kelas.replaceAll(RegExp(r'[^0-9]'), ''));
      if (kelasNum != null) {
        userUsia = kelasNum + 6; // Kelas 10 ≈ 16 tahun, 12 ≈ 18 tahun
      }

      // Helper: Parse criteria map ke format req_ fields
      List<String> parseJenjang(Map<String, String> criteria) {
        final k = criteria['Kelas'] ?? '';
        if (k.isEmpty) return ['Semua Jenjang'];
        // Jika ada kelas SMA (10-12), otomatis cocok untuk SMA
        return ['SMA', 'SMK', 'S1'];
      }

      int parseBatasUsia(Map<String, String> criteria) {
        return 25; // Default batas usia untuk semua beasiswa
      }

      List<String> parseBidangStudi(Map<String, String> criteria) {
        final j = criteria['Jurusan'] ?? '';
        if (j.isEmpty || j.contains('Semua')) return ['Semua Jurusan'];
        return j.split(',').map((e) => e.trim()).toList();
      }

      double parseMinIpk(Map<String, String> criteria) {
        final str = criteria['Min. Nilai Rapor'];
        return str != null ? (double.tryParse(str) ?? 70.0) : 70.0;
      }

      // 1. Tampilkan persentase fallback secara INSTAN terlebih dahulu
      final fallbackList = state.map((scholarship) {
        final fallback = AiService.fallbackMatch(
          userJenjang: userJenjang,
          userUsia: userUsia,
          userBidangStudi: jurusan.isNotEmpty ? jurusan : 'Umum',
          userIpk: userIpkForMatching,
          scholarshipTitle: scholarship.title,
          reqJenjang: parseJenjang(scholarship.criteria),
          reqBatasUsia: parseBatasUsia(scholarship.criteria),
          reqBidangStudi: parseBidangStudi(scholarship.criteria),
          reqMinIpk: parseMinIpk(scholarship.criteria),
        );
        return scholarship.copyWith(matchPercentage: fallback.matchPercentage);
      }).toList()
        ..sort((a, b) => b.matchPercentage.compareTo(a.matchPercentage));
      state = fallbackList;

      // 2. Jalankan request AI secara paralel dan update satu-per-satu setelah respon AI diterima
      final futures = state.map((scholarship) async {
        final matchResult = await AiService.getMatch(
          userJenjang: userJenjang,
          userUsia: userUsia,
          userBidangStudi: jurusan.isNotEmpty ? jurusan : 'Umum',
          userIpk: userIpkForMatching,
          scholarshipTitle: scholarship.title,
          reqJenjang: parseJenjang(scholarship.criteria),
          reqBatasUsia: parseBatasUsia(scholarship.criteria),
          reqBidangStudi: parseBidangStudi(scholarship.criteria),
          reqMinIpk: parseMinIpk(scholarship.criteria),
        );

        // Hanya update jika ini masih request aktif terbaru
        if (loadId == _activeLoadId) {
          state = state.map((s) {
            if (s.id == scholarship.id) {
              return s.copyWith(matchPercentage: matchResult.matchPercentage);
            }
            return s;
          }).toList()
            ..sort((a, b) => b.matchPercentage.compareTo(a.matchPercentage));
        }
      }).toList();

      await Future.wait(futures);
      debugPrint('✅ AI Match percentages loaded concurrently for ${state.length} scholarships');
    } catch (e) {
      debugPrint('Error loading AI match percentages: $e');
    }
  }


  Future<void> toggleSave(String id) async {
    // Optimistic update dulu
    final scholarship = state.firstWhere((s) => s.id == id);
    final newSavedState = !scholarship.isSaved;

    state = state.map((s) {
      if (s.id == id) return s.copyWith(isSaved: newSavedState);
      return s;
    }).toList();

    // Sync ke Firestore
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('saved_scholarships')
          .doc(id);

      if (newSavedState) {
        await docRef.set({
          'scholarship_id': id,
          'saved_at': FieldValue.serverTimestamp(),
        });
      } else {
        await docRef.delete();
      }
    } catch (e) {
      debugPrint('Error toggling save: $e');
      // Rollback on error
      state = state.map((s) {
        if (s.id == id) return s.copyWith(isSaved: !newSavedState);
        return s;
      }).toList();
    }
  }

  static final List<Scholarship> _initialData = [
    Scholarship(
      id: ScholarshipIds.buk,
      title: 'Beasiswa Unggulan Kemendikbud',
      provider: 'Kemendikbud RI',
      providerColor: const Color(0xFF00A47D),
      logoPath: 'assets/beasiswa/KEMENDIKBUD.png',
      tags: ['Matematika', 'Pemerintah', 'Prestasi', 'Parsial'],
      matchPercentage: 0,
      deadline: DateTime(2026, 6, 30),
      isSaved: false,
      description: "Beasiswa Unggulan merupakan program beasiswa yang diselenggarakan oleh Kementerian Pendidikan dan Kebudayaan RI untuk siswa berprestasi. Program ini mencakup biaya pendidikan, biaya hidup, dan tunjangan buku selama masa studi.",
      requirements: [
        "Nilai rapor rata - rata minimal 8.5",
        "Aktif dalam organisasi sekolah",
        "Memiliki prestasi akademik tingkat kabupaten / kota",
        "Surat rekomendasi dari kepala sekolah"
      ],
      criteria: {
        "Min. Nilai Rapor": "85",
        "Min. IPK": "3.40",
        "Kelas": "11, 12 (Semester 3-6)",
        "Jurusan": "IPA, IPS, Bahasa"
      },
      documents: [
        "Fotokopi rapor semester terakhir",
        "Surat rekomendasi kepala sekolah",
        "Esai motivasi (500 kata)",
        "Fotokopi KTP / Kartu Pelajar",
        "Pas foto 3x4",
        "Sertifikat prestasi"
      ],
    ),
    Scholarship(
      id: ScholarshipIds.bapk,
      title: 'Beasiswa Atlet Berprestasi KONI',
      provider: 'KONI Pusat',
      providerColor: const Color(0xFFFE4820),
      logoPath: 'assets/beasiswa/KONI.png',
      tags: ['Olahraga', 'Pemerintah', 'Khusus', 'Penuh'],
      matchPercentage: 0,
      deadline: DateTime(2026, 7, 1),
      isSaved: false,
      description: "Program beasiswa khusus untuk atlet pelajar berprestasi yang telah mewakili daerah atau nasional dalam kompetisi olahraga resmi. Mencakup biaya pendidikan dan pelatihan.",
      requirements: [
        "Atlet berprestasi tingkat provinsi / nasional",
        "Masih aktif berlatih dan bertanding",
        "Nilai rapor rata - rata minimal 7.0",
        "Rekomendasi dari pengurus cabang olahraga"
      ],
      criteria: {
        "Min. Nilai Rapor": "70",
        "Min. IPK": "2.80",
        "Kelas": "10, 11, 12 (Semester 1-6)",
        "Jurusan": "IPA, IPS, Bahasa, SMK"
      },
      documents: [
        "Sertifikat / medali kejuaraan",
        "Surat rekomendasi KONI daerah",
        "Fotokopi rapor",
        "Foto aksi olahraga",
        "Riwayat prestasi olahraga"
      ],
    ),
    Scholarship(
      id: ScholarshipIds.bsnd,
      title: 'Beasiswa Seni Budaya Nusantara',
      provider: 'Kemendikbud RI',
      providerColor: const Color(0xFF68417E),
      logoPath: 'assets/beasiswa/KEMENDIKBUD.png',
      tags: ['Seni & Desain', 'Pemerintah', 'Prestasi', 'Parsial'],
      matchPercentage: 0,
      deadline: DateTime(2026, 7, 1),
      isSaved: false,
      description: "Beasiswa untuk siswa yang memiliki bakat dan prestasi di bidang seni dan budaya Indonesia. Mendukung pelestarian dan pengembangan seni budaya nusantara melalui pendidikan.",
      requirements: [
        "Memiliki prestasi di bidang seni / budaya",
        "Aktif dalam kegiatan seni di sekolah / komunitas",
        "Nilai rapor rata - rata minimal 7.0",
        "Menguasai minimal satu bidang seni tradisional"
      ],
      criteria: {
        "Min. Nilai Rapor": "70",
        "Min. IPK": "2.80",
        "Kelas": "10, 11, 12 (Semester 1-6)",
        "Jurusan": "IPA, IPS, Bahasa, SMK"
      },
      documents: [
        "Portofolio karya seni",
        "Video penampilan seni (5 menit)",
        "Sertifikat prestasi seni",
        "Fotokopi rapor",
        "Esai tentang visi pelestarian budaya"
      ],
    ),
    Scholarship(
      id: ScholarshipIds.ppt,
      title: 'Paragon for Future Leaders',
      provider: 'PT Paragon Technology',
      providerColor: const Color(0xFFB7962A),
      logoPath: 'assets/beasiswa/PARAGON.png',
      tags: ['Wirausahawan', 'Swasta', 'Khusus', 'Parsial'],
      matchPercentage: 0,
      deadline: DateTime(2026, 7, 4),
      isSaved: false,
      description: "Beasiswa dari Paragon Technology and Innovation untuk siswa SMA/SMK yang memiliki semangat inovasi dan entrepreneurship. Program ini juga mencakup pelatihan kewirausahaan dan mentoring.",
      requirements: [
        "Memiliki minat kewirausahaan",
        "Nilai rapor rata - rata minimal 7.5",
        "Pernah membuat proyek / usaha kecil (diutamakan)",
        "Bersedia mengikuti program mentoring"
      ],
      criteria: {
        "Min. Nilai Rapor": "75",
        "Min. IPK": "3.00",
        "Kelas": "10, 11, 12 (Semester 1-6)",
        "Jurusan": "IPA, IPS, Bahasa, SMK"
      },
      documents: [
        "Fotokopi rapor",
        "Proposal ide bisnis / proyek",
        "Esai tentang semangat inovasi",
        "Dokumentasi proyek / usaha (jika ada)",
        "Surat rekomendasi"
      ],
    ),
    Scholarship(
      id: ScholarshipIds.lpdp,
      title: 'LPDP Beasiswa Reguler',
      provider: 'LPDP Kemenkeu',
      providerColor: const Color(0xFFE63333),
      logoPath: 'assets/beasiswa/image.png',
      tags: ['Seni & Desain', 'Pemerintah', 'Prestasi', 'Parsial'],
      matchPercentage: 0,
      deadline: DateTime(2026, 7, 6),
      isSaved: false,
      description: "Lembaga Pengelola Dana Pendidikan (LPDP) menawarkan beasiswa reguler bagi putra - putri terbaik bangsa untuk melanjutkan pendidikan ke jenjang yang lebih tinggi di universitas terkemuka.",
      requirements: [
        "IPK minimal 3.0 atau nilai rapor rata - rata 8.0",
        "Usia maksimal 25 tahun",
        "Sehat jasmani dan rohani",
        "Tidak sedang menerima beasiswa lain"
      ],
      criteria: {
        "Min. Nilai Rapor": "80",
        "Min. IPK": "3.20",
        "Kelas": "12 (Semester 5-6)",
        "Jurusan": "IPA, IPS, Bahasa"
      },
      documents: [
        "Transkrip nilai / rapor",
        "Surat keterangan sehat",
        "Esai rencana studi",
        "CV / daftar riwayat hidup",
        "Fotokopi KTP",
        "SKCK"
      ],
    ),
    Scholarship(
      id: ScholarshipIds.ai,
      title: 'Beasiswa Astra 1st',
      provider: 'Astra International',
      providerColor: const Color(0xFFA729B3),
      logoPath: 'assets/beasiswa/ASTRA.png',
      tags: ['Matematika', 'Swasta', 'Kurang Mampu', 'Penuh'],
      matchPercentage: 0,
      deadline: DateTime(2026, 7, 6),
      isSaved: false,
      description: "Program beasiswa dari PT Astra International Tbk untuk siswa SMK berprestasi yang tertarik di bidang otomotif, teknik, dan manufaktur. Termasuk kesempatan magang di perusahaan Astra.",
      requirements: [
        "Siswa SMK jurusan teknik / otomotif",
        "Nilai rapor rata - rata minimal 80",
        "Tertarik di bidang otomotif dan teknologi",
        "Bersedia mengikuti program magang"
      ],
      criteria: {
        "Min. Nilai Rapor": "80",
        "Min. IPK": "3.20",
        "Kelas": "11, 12 (Semester 3-6)",
        "Jurusan": "SMK"
      },
      documents: [
        "Fotokopi rapor",
        "Surat rekomendasi kepala sekolah",
        "Esai tentang minat di bidang teknologi",
        "CV",
        "Fotokopi kartu pelajar"
      ],
    ),
    Scholarship(
      id: ScholarshipIds.tf,
      title: 'TELADAN - Tanoto Foundation',
      provider: 'Tanoto Foundation',
      providerColor: const Color(0xFF4AD743),
      logoPath: 'assets/beasiswa/TANOTO.png',
      tags: ['Kesehatan', 'Kampus', 'Ikatan Dinas', 'Penuh'],
      matchPercentage: 0,
      deadline: DateTime(2026, 7, 8),
      isSaved: false,
      description: "Program TELADAN (Transformasi Edukasi untuk Melahirkan Pemimpin Masa Depan) dari Tanoto Foundation memberikan dukungan finansial dan pengembangan kepemimpinan bagi siswa berprestasi.",
      requirements: [
        "Nilai rapor rata - rata minimal 7.5",
        "Aktif dalam kegiatan kepemimpinan",
        "Memiliki rencana kontribusi sosial",
        "Bersedia mengikuti program pengembangan"
      ],
      criteria: {
        "Min. Nilai Rapor": "75",
        "Min. IPK": "3.00",
        "Kelas": "11, 12 (Semester 3-6)",
        "Jurusan": "IPA, IPS, Bahasa"
      },
      documents: [
        "Formulir pendaftaran",
        "Fotokopi rapor 2 semester terakhir",
        "Esai kepemimpinan dan kontribusi sosial",
        "Video perkenalan (3 menit)",
        "Surat rekomendasi"
      ],
    ),
  ];
}

final scholarshipProvider = NotifierProvider<ScholarshipNotifier, List<Scholarship>>(() {
  return ScholarshipNotifier();
});

// Controller state untuk Filter Kategori Home
class HomeCategoryFilterNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setCategory(int index) {
    state = index;
  }
}

final homeCategoryFilterProvider = NotifierProvider<HomeCategoryFilterNotifier, int>(() {
  return HomeCategoryFilterNotifier();
});
