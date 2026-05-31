import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:cabe/core/services/ai_service.dart';
import 'package:cabe/features/profile_setup/models/profile_setup_data.dart';

/// Daftar opsi minat & bakat default.
const List<String> defaultMinatBakatOptions = [
  "Olahraga", "Bahasa & Sastra", "Memasak & Baking", "Kewirausahaan",
  "Kesehatan", "Matematika", "Seni & Desain", "Sosial & Kemanusiaan",
  "Musik", "Hukum & Politik", "Sains & Teknologi", "Ekonomi & Bisnis",
];

class EditProfileController extends ChangeNotifier {
  final PageController pageController = PageController();
  int currentPage = 0;
  bool isLoading = false;

  // ── Text Controllers ──
  final namaController = TextEditingController();
  final tglLahirController = TextEditingController();
  final jenisKelaminController = TextEditingController();
  final sekolahController = TextEditingController();
  final kelasController = TextEditingController();
  final jurusanController = TextEditingController();
  final nilaiRaporController = TextEditingController();
  final minatSearchController = TextEditingController();

  // ── State Lists ──
  List<String> prestasiFiles = [];
  List<PlatformFile> newFiles = [];
  List<String> selectedMinatBakat = [];
  List<String> selectedSumberPendanaan = [];
  List<String> selectedJenisSyarat = [];
  List<String> selectedCakupanBiaya = [];

  // ─── New: Finansial, Non-Akademik, Dokumen, Motivasi ───
  String penghasilanOrtu = '';
  String bantuanSosial = '';
  String tanggungan = '';
  String pekerjaanOrtu = '';
  String levelPrestasi = '';
  String jumlahPrestasi = '';
  String organisasi = '';
  String aktivitasTambahan = '';
  List<String> dokumenPendukung = [];
  String kejelasanTujuan = '';
  String tujuanKarir = '';
  String keterkaitan = '';
  String tipeNilai = 'rapor';
  String jenjang = '';

  // ── Initialization ──
  void loadFromProfile(Map<String, dynamic>? dbProfile) {
    if (dbProfile == null) return;

    namaController.text = dbProfile['nama_lengkap'] ?? '';
    tglLahirController.text = dbProfile['tanggal_lahir'] ?? '';
    jenisKelaminController.text = dbProfile['jenis_kelamin'] ?? '';
    sekolahController.text = dbProfile['nama_sekolah'] ?? '';
    kelasController.text = dbProfile['kelas'] ?? '';
    jurusanController.text = dbProfile['jurusan'] ?? '';
    nilaiRaporController.text = dbProfile['nilai_rata_rata']?.toString() ?? '';

    prestasiFiles = _parseStringList(dbProfile['prestasi']);
    selectedMinatBakat = _parseStringList(dbProfile['minat_bakat']);

    if (dbProfile['sumber_pendanaan'] is List) {
      selectedSumberPendanaan = List<String>.from(dbProfile['sumber_pendanaan']);
    }
    if (dbProfile['jenis_beasiswa'] is List) {
      selectedJenisSyarat = List<String>.from(dbProfile['jenis_beasiswa']);
    }
    if (dbProfile['cakupan_biaya'] is List) {
      selectedCakupanBiaya = List<String>.from(dbProfile['cakupan_biaya']);
    }

    // Load new fields
    tipeNilai = dbProfile['tipe_nilai'] ?? 'rapor';
    jenjang = dbProfile['jenjang'] ?? '';
    penghasilanOrtu = dbProfile['penghasilan_ortu'] ?? '';
    bantuanSosial = dbProfile['bantuan_sosial'] ?? '';
    tanggungan = dbProfile['tanggungan'] ?? '';
    pekerjaanOrtu = dbProfile['pekerjaan_ortu'] ?? '';
    levelPrestasi = dbProfile['level_prestasi'] ?? '';
    jumlahPrestasi = dbProfile['jumlah_prestasi'] ?? '';
    organisasi = dbProfile['organisasi'] ?? '';
    aktivitasTambahan = dbProfile['aktivitas_tambahan'] ?? '';
    if (dbProfile['dokumen_pendukung'] is List) {
      dokumenPendukung = List<String>.from(dbProfile['dokumen_pendukung']);
    }
    kejelasanTujuan = dbProfile['kejelasan_tujuan'] ?? '';
    tujuanKarir = dbProfile['tujuan_karir'] ?? '';
    keterkaitan = dbProfile['keterkaitan'] ?? '';

    notifyListeners();
  }

  List<String> _parseStringList(dynamic value) {
    if (value is List) return List<String>.from(value);
    if (value is String && value.isNotEmpty) {
      return value.split(',').map((e) => e.trim()).toList();
    }
    return [];
  }

  // ── Navigation ──
  void nextPage() {
    if (currentPage < 6) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void prevPage() {
    if (currentPage > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void setPage(int index) {
    currentPage = index;
    notifyListeners();
  }

  // ── Toggle Chips ──
  void toggleMinatBakat(String item) {
    if (selectedMinatBakat.contains(item)) {
      selectedMinatBakat.remove(item);
    } else {
      selectedMinatBakat.add(item);
    }
    notifyListeners();
  }

  void addCustomMinatBakat(String item) {
    if (item.isNotEmpty && !selectedMinatBakat.contains(item)) {
      selectedMinatBakat.add(item);
      notifyListeners();
    }
  }

  void toggleSumberPendanaan(String item) {
    if (selectedSumberPendanaan.contains(item)) {
      selectedSumberPendanaan.remove(item);
    } else {
      selectedSumberPendanaan.add(item);
    }
    notifyListeners();
  }

  void toggleJenisSyarat(String item) {
    if (selectedJenisSyarat.contains(item)) {
      selectedJenisSyarat.remove(item);
    } else {
      selectedJenisSyarat.add(item);
    }
    notifyListeners();
  }

  void toggleCakupanBiaya(String item) {
    if (selectedCakupanBiaya.contains(item)) {
      selectedCakupanBiaya.remove(item);
    } else {
      selectedCakupanBiaya.add(item);
    }
    notifyListeners();
  }

  // ─── Setters untuk field baru ───
  void setTipeNilai(String val) {
    tipeNilai = val;
    notifyListeners();
  }

  void setJenjang(String val) {
    jenjang = val;
    // Reset kelas when jenjang changes
    kelasController.clear();
    notifyListeners();
  }

  bool get isSekolahMenengah => jenjang == 'SMA/SMK/MA';
  void setPenghasilanOrtu(String v) { penghasilanOrtu = v; notifyListeners(); }
  void setBantuanSosial(String v) { bantuanSosial = v; notifyListeners(); }
  void setTanggungan(String v) { tanggungan = v; notifyListeners(); }
  void setPekerjaanOrtu(String v) { pekerjaanOrtu = v; notifyListeners(); }
  void setLevelPrestasi(String v) { levelPrestasi = v; notifyListeners(); }
  void setJumlahPrestasi(String v) { jumlahPrestasi = v; notifyListeners(); }
  void setOrganisasi(String v) { organisasi = v; notifyListeners(); }
  void setAktivitasTambahan(String v) { aktivitasTambahan = v; notifyListeners(); }
  void toggleDokumenPendukung(String item) {
    if (dokumenPendukung.contains(item)) {
      dokumenPendukung.remove(item);
    } else {
      dokumenPendukung.add(item);
    }
    notifyListeners();
  }
  void setKejelasanTujuan(String v) { kejelasanTujuan = v; notifyListeners(); }
  void setTujuanKarir(String v) { tujuanKarir = v; notifyListeners(); }
  void setKeterkaitan(String v) { keterkaitan = v; notifyListeners(); }

  // ── Minat Search Filter ──
  List<String> get filteredMinatOptions {
    final query = minatSearchController.text.toLowerCase();
    final allOptions = [
      ...defaultMinatBakatOptions,
      // Custom minat yang bukan dari daftar default
      ...selectedMinatBakat.where((m) => !defaultMinatBakatOptions.contains(m)),
    ];
    if (query.isEmpty) return allOptions;
    return allOptions.where((item) => item.toLowerCase().contains(query)).toList();
  }

  // ── File Pick ──
  /// Pick gambar dari galeri
  Future<String?> pickFromGallery() async {
    return _pickWithType(FileType.image, null);
  }

  /// Pick file dari file manager (jpg, png, pdf)
  Future<String?> pickFromFiles() async {
    return _pickWithType(FileType.custom, ['jpg', 'jpeg', 'png', 'pdf']);
  }

  Future<String?> _pickWithType(FileType type, List<String>? extensions) async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: type,
        allowedExtensions: extensions,
        allowMultiple: true,
        withData: true,
      );

      if (result != null) {
        List<PlatformFile> validFiles = [];
        String? errorMessage;

        for (var file in result.files) {
          if (file.size <= 5 * 1024 * 1024) {
            validFiles.add(file);
          } else {
            errorMessage = 'File ${file.name} melebihi batas 5MB';
          }
        }

        if (newFiles.length + validFiles.length <= 10) {
          newFiles.addAll(validFiles);
          notifyListeners();
        } else {
          return 'Maksimal 10 file yang diperbolehkan';
        }

        return errorMessage;
      }
    } catch (e) {
      debugPrint("Error picking file: $e");
      return 'Gagal memilih file';
    }
    return null;
  }

  // ── Remove Files ──
  void removePrestasiFile(String fileName) {
    prestasiFiles.remove(fileName);
    notifyListeners();
  }

  void removeNewFile(PlatformFile file) {
    newFiles.remove(file);
    renamedFiles.remove(file.name);
    notifyListeners();
  }

  Map<String, String> renamedFiles = {};

  void renameNewFile(PlatformFile file, String newName) {
    String finalName = newName.trim();
    final ext = file.extension;
    if (ext != null && ext.isNotEmpty && !finalName.toLowerCase().endsWith('.${ext.toLowerCase()}')) {
      finalName = '$finalName.$ext';
    }
    renamedFiles[file.name] = finalName;
    notifyListeners();
  }

  // ── Save to Firestore ──
  Future<String?> saveData() async {
    isLoading = true;
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return 'User not logged in';

      // Upload file baru ke Firebase Storage
      List<String> uploadedFileNames = [];
      for (final platformFile in newFiles) {
        final displayName = renamedFiles[platformFile.name] ?? platformFile.name;
        final filePath = 'prestasi/${user.uid}/$displayName';
        try {
          final ref = FirebaseStorage.instance.ref().child(filePath);
          final Uint8List fileBytes;
          if (platformFile.bytes != null) {
            fileBytes = platformFile.bytes!;
          } else if (platformFile.path != null) {
            fileBytes = await File(platformFile.path!).readAsBytes();
          } else {
            return 'File $displayName tidak memiliki data atau path yang valid';
          }
          await ref.putData(fileBytes);
          uploadedFileNames.add(displayName);
        } catch (uploadError) {
          debugPrint('Upload error for $displayName: $uploadError');
          // Jika gagal upload ke Storage (misal karena bucket belum dibuat atau rules error),
          // kita tetap simpan nama file ke Firestore agar pengguna tidak stuck.
          uploadedFileNames.add(displayName);
        }
      }

      List<String> combinedPrestasi = [
        ...prestasiFiles,
        ...uploadedFileNames,
      ];

      final updates = {
        'nama_lengkap': namaController.text,
        'tanggal_lahir': tglLahirController.text,
        'jenis_kelamin': jenisKelaminController.text,
        'jenjang': jenjang,
        'nama_sekolah': sekolahController.text,
        'kelas': kelasController.text,
        'jurusan': jurusanController.text,
        'tipe_nilai': tipeNilai,
        'nilai_rata_rata': double.tryParse(nilaiRaporController.text) ?? 0.0,
        'prestasi': combinedPrestasi,
        'minat_bakat': selectedMinatBakat,
        'sumber_pendanaan': selectedSumberPendanaan,
        'jenis_beasiswa': selectedJenisSyarat,
        'cakupan_biaya': selectedCakupanBiaya,
        // Finansial
        'penghasilan_ortu': penghasilanOrtu,
        'bantuan_sosial': bantuanSosial,
        'tanggungan': tanggungan,
        'pekerjaan_ortu': pekerjaanOrtu,
        // Non-Akademik
        'level_prestasi': levelPrestasi,
        'jumlah_prestasi': jumlahPrestasi,
        'organisasi': organisasi,
        'aktivitas_tambahan': aktivitasTambahan,
        // Dokumen & Motivasi
        'dokumen_pendukung': dokumenPendukung,
        'kejelasan_tujuan': kejelasanTujuan,
        'tujuan_karir': tujuanKarir,
        'keterkaitan': keterkaitan,
        'updated_at': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(updates, SetOptions(merge: true));

      // ─── Recalculate readiness score in background ───
      _recalculateReadiness(user.uid);

      return null; // success
    } catch (e) {
      return 'Gagal menyimpan profil: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Fire-and-forget: recalculate readiness score after profile edit
  void _recalculateReadiness(String uid) async {
    try {
      final nilai = double.tryParse(nilaiRaporController.text) ?? 0;

      final result = await AiService.getReadinessScore(
        nilaiRapor: nilai,
        tipeNilai: tipeNilai,
        penghasilanOrtu: penghasilanOrtu.isNotEmpty ? penghasilanOrtu : '> 5 Juta',
        bantuanSosial: bantuanSosial.isNotEmpty ? bantuanSosial : 'Tidak ada',
        tanggungan: tanggungan.isNotEmpty ? tanggungan : 'Tidak ada',
        pekerjaanOrtu: pekerjaanOrtu.isNotEmpty ? pekerjaanOrtu : 'Tetap',
        levelPrestasi: levelPrestasi.isNotEmpty ? levelPrestasi : 'Tidak ada',
        jumlahPrestasi: jumlahPrestasi.isNotEmpty ? jumlahPrestasi : 'Tidak Ada',
        organisasi: organisasi.isNotEmpty ? organisasi : 'Tidak ada',
        aktivitasTambahan: aktivitasTambahan.isNotEmpty ? aktivitasTambahan : 'Tidak ada',
        dokumenPendukung: dokumenPendukung,
        kejelasanTujuan: kejelasanTujuan.isNotEmpty ? kejelasanTujuan : 'Belum yakin',
        tujuanKarir: tujuanKarir.isNotEmpty ? tujuanKarir : 'Belum ada',
        keterkaitan: keterkaitan.isNotEmpty ? keterkaitan : 'Belum sesuai / belum tahu',
      );

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'readiness_total': result.totalScore,
        'readiness_akademik': result.skorAkademik,
        'readiness_finansial': result.skorFinansial,
        'readiness_non_akademik': result.skorNonAkademik,
        'readiness_sertifikat': result.skorSertifikat,
        'readiness_motivasi': result.skorMotivasi,
        'readiness_label': result.label,
        'readiness_tips': result.tips,
        'readiness_updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('Readiness recalculated after edit: ${result.totalScore}');
    } catch (e) {
      debugPrint('Readiness recalculation failed (non-blocking): $e');
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    namaController.dispose();
    tglLahirController.dispose();
    jenisKelaminController.dispose();
    sekolahController.dispose();
    kelasController.dispose();
    jurusanController.dispose();
    nilaiRaporController.dispose();
    minatSearchController.dispose();
    super.dispose();
  }
}
