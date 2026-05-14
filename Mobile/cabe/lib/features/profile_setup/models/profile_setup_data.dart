/// Data model untuk menyimpan hasil input profil user.
class ProfileSetupData {
  String namaLengkap;
  String tanggalLahir;
  String jenisKelamin;
  String namaSekolah;
  String kelas;
  String jurusan;
  String nilaiRataRata;
  String prestasi;
  List<String> minatBakat;
  List<String> sumberPendanaan;
  List<String> jenisBeasiswa;
  List<String> cakupanBiaya;

  ProfileSetupData({
    this.namaLengkap = '',
    this.tanggalLahir = '',
    this.jenisKelamin = '',
    this.namaSekolah = '',
    this.kelas = '',
    this.jurusan = '',
    this.nilaiRataRata = '',
    this.prestasi = '',
    List<String>? minatBakat,
    List<String>? sumberPendanaan,
    List<String>? jenisBeasiswa,
    List<String>? cakupanBiaya,
  })  : minatBakat = minatBakat ?? [],
        sumberPendanaan = sumberPendanaan ?? [],
        jenisBeasiswa = jenisBeasiswa ?? [],
        cakupanBiaya = cakupanBiaya ?? [];
}

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
