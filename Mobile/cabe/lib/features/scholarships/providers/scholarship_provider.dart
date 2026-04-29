import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/scholarship.dart';

class ScholarshipNotifier extends Notifier<List<Scholarship>> {
  @override
  List<Scholarship> build() {
    return _initialData;
  }

  void toggleSave(String id) {
    state = state.map((scholarship) {
      if (scholarship.id == id) {
        return scholarship.copyWith(isSaved: !scholarship.isSaved);
      }
      return scholarship;
    }).toList();
  }

  static final List<Scholarship> _initialData = [
    Scholarship(
      id: '1',
      title: 'Beasiswa Unggulan Kemendikbud',
      provider: 'Kemendikbud RI',
      providerColor: const Color(0xFF00A47D),
      tags: ['Matematika', 'Pemerintah', 'Prestasi', 'Parsial'],
      matchPercentage: 23,
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
      id: '2',
      title: 'Beasiswa Atlet Berprestasi KONI',
      provider: 'KONI Pusat',
      providerColor: const Color(0xFFFE4820), // Warna orange
      tags: ['Olahraga', 'Pemerintah', 'Khusus', 'Penuh'],
      matchPercentage: 86,
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
      id: '3',
      title: 'Beasiswa Seni Budaya Nusantara',
      provider: 'Kemendikbud RI',
      providerColor: const Color(0xFF68417E), // Warna ungu
      tags: ['Seni & Desain', 'Pemerintah', 'Prestasi', 'Parsial'],
      matchPercentage: 57,
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
      id: '4',
      title: 'Paragon for Future Leaders',
      provider: 'PT Paragon Technology',
      providerColor: const Color(0xFFB7962A), // Warna agak coklat
      tags: ['Wirausahawan', 'Swasta', 'Khusus', 'Parsial'],
      matchPercentage: 97,
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
      id: '5',
      title: 'LPDP Beasiswa Reguler',
      provider: 'LPDP Kemenkeu',
      providerColor: const Color(0xFFE63333), // Warna merah agak gelap
      tags: ['Seni & Desain', 'Pemerintah', 'Prestasi', 'Parsial'],
      matchPercentage: 31,
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
      id: '6',
      title: 'Beasiswa Astra 1st',
      provider: 'Astra International',
      providerColor: const Color(0xFFA729B3), 
      tags: ['Matematika', 'Swasta', 'Kurang Mampu', 'Penuh'],
      matchPercentage: 17,
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
      id: '7',
      title: 'TELADAN - Tanoto Foundation',
      provider: 'Tanoto Foundation',
      providerColor: const Color(0xFF4AD743), // Warna hijau terang
      tags: ['Kesehatan', 'Kampus', 'Ikatan Dinas', 'Penuh'],
      matchPercentage: 77,
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
