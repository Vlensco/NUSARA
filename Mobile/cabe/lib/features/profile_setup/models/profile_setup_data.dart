/// Data model untuk menyimpan hasil input profil user.
class ProfileSetupData {
  // ─── Step 1: Data Diri ───
  String namaLengkap;
  String tanggalLahir;
  String jenisKelamin;
  String namaSekolah;
  String jenjang; // "SMA/SMK", "D3", "S1", etc.

  // ─── Step 2: Info Akademik ───
  String kelas;
  String jurusan;
  String tipeNilai; // "rapor" atau "ipk"
  String nilaiRataRata;
  String prestasi;

  // ─── Step 3: Kebutuhan Finansial ───
  String penghasilanOrtu;
  String bantuanSosial;
  String tanggungan;
  String pekerjaanOrtu;

  // ─── Step 4: Prestasi Non-Akademik ───
  String levelPrestasi;
  String jumlahPrestasi;
  String organisasi;
  String aktivitasTambahan;

  // ─── Step 5: Minat & Bakat ───
  List<String> minatBakat;

  // ─── Step 6: Dokumen Pendukung & Motivasi ───
  List<String> dokumenPendukung;
  String kejelasanTujuan;
  String tujuanKarir;
  String keterkaitan;

  // ─── Step 7: Preferensi Beasiswa ───
  List<String> sumberPendanaan;
  List<String> jenisBeasiswa;
  List<String> cakupanBiaya;

  ProfileSetupData({
    this.namaLengkap = '',
    this.tanggalLahir = '',
    this.jenisKelamin = '',
    this.namaSekolah = '',
    this.jenjang = '',
    this.kelas = '',
    this.jurusan = '',
    this.tipeNilai = 'rapor',
    this.nilaiRataRata = '',
    this.prestasi = '',
    this.penghasilanOrtu = '',
    this.bantuanSosial = '',
    this.tanggungan = '',
    this.pekerjaanOrtu = '',
    this.levelPrestasi = '',
    this.jumlahPrestasi = '',
    this.organisasi = '',
    this.aktivitasTambahan = '',
    List<String>? minatBakat,
    List<String>? dokumenPendukung,
    this.kejelasanTujuan = '',
    this.tujuanKarir = '',
    this.keterkaitan = '',
    List<String>? sumberPendanaan,
    List<String>? jenisBeasiswa,
    List<String>? cakupanBiaya,
  })  : minatBakat = minatBakat ?? [],
        dokumenPendukung = dokumenPendukung ?? [],
        sumberPendanaan = sumberPendanaan ?? [],
        jenisBeasiswa = jenisBeasiswa ?? [],
        cakupanBiaya = cakupanBiaya ?? [];

  /// Helper: apakah user jenjang sekolah menengah (SMA/SMK/MA)?
  bool get isSekolahMenengah => jenjang == 'SMA/SMK/MA';
}

// ═══════════════════════════════════════════
// OPSI-OPSI FORM
// ═══════════════════════════════════════════

/// Opsi jenjang pendidikan
const List<String> jenjangOptions = [
  'SMA/SMK/MA',
  'D3 (Diploma)',
  'D4/S1 (Sarjana)',
  'S2 (Magister)',
];

/// Opsi chip untuk Minat & Bakat
const List<String> minatBakatOptions = [
  'Sains & Teknologi',
  'Matematika',
  'Kesehatan',
  'Hukum & Politik',
  'Kewirausahaan',
  'Musik',
  'Seni & Desain',
  'Olahraga',
  'Memasak & Baking',
  'Bahasa & Sastra',
  'Sosial & Kemanusiaan',
  'Ekonomi & Bisnis',
];

/// Opsi chip untuk Sumber Pendanaan
const List<String> sumberPendanaanOptions = [
  'Beasiswa Pemerintah',
  'Beasiswa Kampus',
  'Beasiswa Swasta / Corporate',
];

/// Opsi chip untuk Jenis & Syarat
const List<String> jenisBeasiswaOptions = [
  'Beasiswa Prestasi',
  'Beasiswa Ikatan Dinas',
  'Beasiswa Khusus',
  'Beasiswa Kurang Mampu',
];

/// Opsi chip untuk Cakupan Biaya
const List<String> cakupanBiayaOptions = [
  'Beasiswa Parsial',
  'Beasiswa Penuh',
];

// ─── Opsi Finansial ───
const List<String> penghasilanOrtuOptions = [
  '< 1 juta',
  '1 - 3 Juta',
  '3 - 5 Juta',
  '> 5 Juta',
];

const List<String> bantuanSosialOptions = [
  'Ada',
  'Tidak ada',
];

const List<String> tanggunganOptions = [
  '> 4',
  '3 - 4',
  '1 - 2',
  'Tidak ada',
];

const List<String> pekerjaanOrtuOptions = [
  'Tidak Tetap',
  'Informal',
  'Tetap',
];

// ─── Opsi Non-Akademik ───
const List<String> levelPrestasiOptions = [
  'Internasional',
  'Nasional',
  'Provinsi',
  'Sekolah',
  'Tidak ada',
];

const List<String> jumlahPrestasiOptions = [
  '> 3',
  '2 - 3',
  '1',
  'Tidak Ada',
];

const List<String> organisasiOptions = [
  'Ketua / Leader',
  'Pengurus Aktif',
  'Anggota',
  'Tidak ada',
];

const List<String> aktivitasTambahanOptions = [
  'Aktif (>2 kegiatan)',
  'Pernah ikut',
  'Tidak ada',
];

// ─── Opsi Dokumen Pendukung ───
const List<String> dokumenPendukungOptions = [
  'Rekomendasi',
  'CV',
  'Sertifikat Khusus',
];

// ─── Opsi Motivasi ───
const List<String> kejelasanTujuanOptions = [
  'Sudah jelas dan spesifik',
  'Sudah ada gambaran',
  'Belum yakin',
];

const List<String> tujuanKarirOptions = [
  'Sudah jelas',
  'Masih umum',
  'Belum ada',
];

const List<String> keterkaitanOptions = [
  'Sangat sesuai',
  'Cukup sesuai',
  'Belum sesuai / belum tahu',
];
