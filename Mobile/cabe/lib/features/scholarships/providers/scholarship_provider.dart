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

  /// Ambil profil user dari Firebase lalu hitung match % via AI
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

      // Ambil data profil
      final rawNilai = data['nilai_rata_rata'];
      final nilaiRataRata = (rawNilai is num) ? rawNilai.toDouble() : 0.0;
      final kelas = (data['kelas'] as String?) ?? '';
      final jurusan = (data['jurusan'] as String?) ?? '';

      // Ambil list prestasi
      final rawPrestasi = data['prestasi'];
      List<String> prestasi = [];
      if (rawPrestasi is List) {
        prestasi = rawPrestasi.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
      } else if (rawPrestasi is String && rawPrestasi.isNotEmpty) {
        prestasi = rawPrestasi.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }

      // Ambil list minat
      final rawMinat = data['minat_bakat'];
      List<String> minat = [];
      if (rawMinat is List) {
        minat = rawMinat.map((e) => e.toString()).toList();
      } else if (rawMinat is String && rawMinat.isNotEmpty) {
        minat = rawMinat.split(',').map((e) => e.trim()).toList();
      }

      // 1. Tampilkan persentase rule-based/fallback secara INSTAN terlebih dahulu
      state = state.map((scholarship) {
        final fallbackPct = AiService.fallbackMatch(
          nilaiRataRata: nilaiRataRata,
          kelas: kelas,
          jurusan: jurusan,
          minatBakat: minat,
          prestasi: prestasi,
          scholarshipCriteria: scholarship.criteria,
        );
        return scholarship.copyWith(matchPercentage: fallbackPct);
      }).toList();

      // 2. Jalankan request AI secara paralel dan update satu-per-satu setelah respon AI diterima
      final futures = state.map((scholarship) async {
        final matchPct = await AiService.getMatchPercentage(
          nilaiRataRata: nilaiRataRata,
          kelas: kelas,
          jurusan: jurusan,
          minatBakat: minat,
          prestasi: prestasi,
          scholarshipTitle: scholarship.title,
          scholarshipCriteria: scholarship.criteria,
        );

        // Hanya update jika ini masih request aktif terbaru
        if (loadId == _activeLoadId) {
          state = state.map((s) {
            if (s.id == scholarship.id) {
              return s.copyWith(matchPercentage: matchPct);
            }
            return s;
          }).toList();
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
      tags: ['Matematika', 'Pemerintah', 'Prestasi', 'Parsial'],
      matchPercentage: 0,
      daysLeft: 21,
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
        "Kelas": "11, 12",
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
      tags: ['Olahraga', 'Pemerintah', 'Khusus', 'Penuh'],
      matchPercentage: 0,
      daysLeft: 22,
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
        "Kelas": "10, 11, 12",
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
      tags: ['Seni & Desain', 'Pemerintah', 'Prestasi', 'Parsial'],
      matchPercentage: 0,
      daysLeft: 22,
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
        "Kelas": "10, 11, 12",
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
      tags: ['Wirausahawan', 'Swasta', 'Khusus', 'Parsial'],
      matchPercentage: 0,
      daysLeft: 25,
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
        "Kelas": "10, 11, 12",
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
      tags: ['Seni & Desain', 'Pemerintah', 'Prestasi', 'Parsial'],
      matchPercentage: 0,
      daysLeft: 27,
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
        "Kelas": "12",
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
      tags: ['Matematika', 'Swasta', 'Kurang Mampu', 'Penuh'],
      matchPercentage: 0,
      daysLeft: 27,
      isSaved: false,
      description: "Program beasiswa dari PT Astra International Tbk untuk siswa SMK berprestasi yang tertarik di bidang otomotif, teknik, dan manufaktur. Termasuk kesempatan magang di perusahaan Astra.",
      requirements: [
        "Siswa SMK jurusan teknik / otomotif",
        "Nilai rapor rata - rata minimal 8.0",
        "Tertarik di bidang otomotif dan teknologi",
        "Bersedia mengikuti program magang"
      ],
      criteria: {
        "Min. Nilai Rapor": "80",
        "Kelas": "11, 12",
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
      tags: ['Kesehatan', 'Kampus', 'Ikatan Dinas', 'Penuh'],
      matchPercentage: 0,
      daysLeft: 29,
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
        "Kelas": "11, 12",
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
