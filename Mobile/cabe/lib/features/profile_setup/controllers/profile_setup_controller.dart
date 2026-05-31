import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:cabe/features/profile_setup/models/profile_setup_data.dart';
import 'package:cabe/features/profile_setup/screens/readiness_score_screen.dart';

class ProfileSetupController extends ChangeNotifier {
  int currentStep = 0;
  final int totalSteps = 7; // 7 langkah sekarang
  final ProfileSetupData profileData = ProfileSetupData();

  /// Muat data draft yang sudah tersimpan di Firestore (saat resume)
  Future<void> loadDraftFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) return;
      final data = doc.data()!;

      // Step 1 — Data Diri
      namaController.text = data['nama_lengkap'] as String? ?? '';
      tanggalLahirController.text = data['tanggal_lahir'] as String? ?? '';
      jenisKelaminController.text = data['jenis_kelamin'] as String? ?? '';
      sekolahController.text = data['nama_sekolah'] as String? ?? '';
      profileData.jenjang = data['jenjang'] as String? ?? '';

      // Step 2 — Akademik
      kelasController.text = data['kelas'] as String? ?? '';
      jurusanController.text = data['jurusan'] as String? ?? '';
      profileData.tipeNilai = data['tipe_nilai'] as String? ?? 'rapor';
      final nilaiRaw = data['nilai_rata_rata'];
      if (nilaiRaw != null) {
        nilaiController.text = nilaiRaw.toString();
      }

      // Step 3 — Finansial
      profileData.penghasilanOrtu = data['penghasilan_ortu'] as String? ?? '';
      profileData.bantuanSosial = data['bantuan_sosial'] as String? ?? '';
      profileData.tanggungan = data['tanggungan'] as String? ?? '';
      profileData.pekerjaanOrtu = data['pekerjaan_ortu'] as String? ?? '';

      // Step 4 — Non-Akademik
      profileData.levelPrestasi = data['level_prestasi'] as String? ?? '';
      profileData.jumlahPrestasi = data['jumlah_prestasi'] as String? ?? '';
      profileData.organisasi = data['organisasi'] as String? ?? '';
      profileData.aktivitasTambahan = data['aktivitas_tambahan'] as String? ?? '';

      // Step 5 — Minat & Bakat
      profileData.minatBakat = List<String>.from(data['minat_bakat'] ?? []);

      // Step 6 — Dokumen & Motivasi
      profileData.dokumenPendukung = List<String>.from(data['dokumen_pendukung'] ?? []);
      profileData.kejelasanTujuan = data['kejelasan_tujuan'] as String? ?? '';
      profileData.tujuanKarir = data['tujuan_karir'] as String? ?? '';
      profileData.keterkaitan = data['keterkaitan'] as String? ?? '';

      // Step 7 — Preferensi Beasiswa
      profileData.sumberPendanaan = List<String>.from(data['sumber_pendanaan'] ?? []);
      profileData.jenisBeasiswa = List<String>.from(data['jenis_beasiswa'] ?? []);
      profileData.cakupanBiaya = List<String>.from(data['cakupan_biaya'] ?? []);

      // Restore step index terakhir
      final savedStep = data['setup_step'] as int? ?? 0;
      currentStep = savedStep.clamp(0, totalSteps - 1);

      notifyListeners();
      debugPrint('Draft dimuat, lanjut dari step $currentStep');
    } catch (e) {
      debugPrint('Gagal memuat draft: $e');
    }
  }

  /// Simpan progress langkah saat ini ke Firestore (tanpa menandai setup selesai)
  Future<void> _saveProgressToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Kumpulkan data yang telah diisi sampai langkah sekarang
    double? nilai;
    if (profileData.nilaiRataRata.isNotEmpty) {
      nilai = double.tryParse(profileData.nilaiRataRata.replaceAll(',', '.'));
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        // Informasi progres
        'setup_completed': false,
        'setup_step': currentStep,
        // Step 1
        'nama_lengkap': profileData.namaLengkap,
        'tanggal_lahir': profileData.tanggalLahir.isEmpty ? null : profileData.tanggalLahir,
        'jenis_kelamin': profileData.jenisKelamin,
        'jenjang': profileData.jenjang,
        'nama_sekolah': profileData.namaSekolah,
        // Step 2
        'kelas': profileData.kelas,
        'jurusan': profileData.jurusan,
        'tipe_nilai': profileData.tipeNilai,
        'nilai_rata_rata': nilai,
        // Step 3
        'penghasilan_ortu': profileData.penghasilanOrtu,
        'bantuan_sosial': profileData.bantuanSosial,
        'tanggungan': profileData.tanggungan,
        'pekerjaan_ortu': profileData.pekerjaanOrtu,
        // Step 4
        'level_prestasi': profileData.levelPrestasi,
        'jumlah_prestasi': profileData.jumlahPrestasi,
        'organisasi': profileData.organisasi,
        'aktivitas_tambahan': profileData.aktivitasTambahan,
        // Step 5
        'minat_bakat': profileData.minatBakat,
        // Step 6
        'dokumen_pendukung': profileData.dokumenPendukung,
        'kejelasan_tujuan': profileData.kejelasanTujuan,
        'tujuan_karir': profileData.tujuanKarir,
        'keterkaitan': profileData.keterkaitan,
        // Step 7
        'sumber_pendanaan': profileData.sumberPendanaan,
        'jenis_beasiswa': profileData.jenisBeasiswa,
        'cakupan_biaya': profileData.cakupanBiaya,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Gagal menyimpan progress: $e');
    }
  }

  // Controllers Step 1: Data Diri
  final namaController = TextEditingController();
  final tanggalLahirController = TextEditingController();
  final jenisKelaminController = TextEditingController();
  final sekolahController = TextEditingController();

  // Controllers Step 2: Info Akademik
  final kelasController = TextEditingController();
  final jurusanController = TextEditingController();
  final nilaiController = TextEditingController();
  List<PlatformFile> newFiles = [];

  ProfileSetupController() {
    namaController.addListener(notifyListeners);
    tanggalLahirController.addListener(notifyListeners);
    jenisKelaminController.addListener(notifyListeners);
    sekolahController.addListener(notifyListeners);
    
    kelasController.addListener(notifyListeners);
    jurusanController.addListener(notifyListeners);
    nilaiController.addListener(notifyListeners);
  }

  @override
  void dispose() {
    namaController.dispose();
    tanggalLahirController.dispose();
    jenisKelaminController.dispose();
    sekolahController.dispose();
    kelasController.dispose();
    jurusanController.dispose();
    nilaiController.dispose();
    super.dispose();
  }

  // ─── File Picker Logic ───
  Map<String, String> renamedFiles = {};

  void renameFile(PlatformFile file, String newName) {
    String finalName = newName.trim();
    final ext = file.extension;
    if (ext != null && ext.isNotEmpty && !finalName.toLowerCase().endsWith('.${ext.toLowerCase()}')) {
      finalName = '$finalName.$ext';
    }
    renamedFiles[file.name] = finalName;
    notifyListeners();
  }

  Future<void> pickFromGallery(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: true,
      );
      _handlePickedFiles(context, result);
    } catch (e) {
      debugPrint("Error picking from gallery: $e");
      _showError(context, 'Gagal memilih gambar dari galeri');
    }
  }

  Future<void> pickFromFiles(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        allowMultiple: true,
        withData: true,
      );
      _handlePickedFiles(context, result);
    } catch (e) {
      debugPrint("Error picking files: $e");
      _showError(context, 'Gagal memilih file');
    }
  }

  void _handlePickedFiles(BuildContext context, FilePickerResult? result) {
    if (result != null) {
      for (var file in result.files) {
        if (file.size <= 5 * 1024 * 1024) {
          if (newFiles.length < 10) {
            newFiles.add(file);
          } else {
            _showError(context, 'Maksimal 10 file yang diperbolehkan');
            break;
          }
        } else {
          _showError(context, 'File ${file.name} melebihi batas 5MB');
        }
      }
      notifyListeners();
    }
  }

  void removeFile(PlatformFile file) {
    newFiles.remove(file);
    renamedFiles.remove(file.name);
    notifyListeners();
  }

  // ─── Navigation Logic ───
  void nextStep(BuildContext context) {
    if (!_validateCurrentStep(context)) return;

    _saveCurrentStep();
    if (currentStep < totalSteps - 1) {
      currentStep++;
      notifyListeners();
      // Simpan progress step terbaru ke Firestore secara async
      _saveProgressToFirestore();
    } else {
      finishSetup(context);
    }
  }

  bool get isCurrentStepValid {
    switch (currentStep) {
      case 0: // Data Diri
        return namaController.text.trim().isNotEmpty &&
            tanggalLahirController.text.trim().isNotEmpty &&
            jenisKelaminController.text.trim().isNotEmpty &&
            sekolahController.text.trim().isNotEmpty &&
            profileData.jenjang.isNotEmpty;
      case 1: // Info Akademik
        return kelasController.text.trim().isNotEmpty &&
            jurusanController.text.trim().isNotEmpty &&
            nilaiController.text.trim().isNotEmpty;
      case 2: // Finansial
        return profileData.penghasilanOrtu.isNotEmpty;
      case 3: // Prestasi Non-Akademik
        return profileData.levelPrestasi.isNotEmpty;
      case 4: // Minat & Bakat
        return profileData.minatBakat.isNotEmpty;
      case 5: // Dokumen & Motivasi
        return profileData.kejelasanTujuan.isNotEmpty;
      case 6: // Preferensi Beasiswa
        return profileData.sumberPendanaan.isNotEmpty &&
            profileData.jenisBeasiswa.isNotEmpty &&
            profileData.cakupanBiaya.isNotEmpty;
      default:
        return true;
    }
  }

  bool _validateCurrentStep(BuildContext context) {
    if (!isCurrentStepValid) {
      _showError(context, "Yuk, lengkapi profilmu dulu! Atau klik 'Lewati' kalau mau diisi nanti.");
      return false;
    }
    return true;
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 150,
          left: 20,
          right: 20,
        ),
        duration: const Duration(seconds: 3),
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }

  void prevStep() {
    if (currentStep > 0) {
      currentStep--;
      notifyListeners();
    }
  }

  void skip(BuildContext context) {
    _saveCurrentStep();
    if (currentStep < totalSteps - 1) {
      currentStep++;
      notifyListeners();
      // Simpan progress step terbaru ke Firestore secara async
      _saveProgressToFirestore();
    } else {
      finishSetup(context);
    }
  }

  void _saveCurrentStep() {
    switch (currentStep) {
      case 0:
        profileData.namaLengkap = namaController.text;
        profileData.tanggalLahir = tanggalLahirController.text;
        profileData.jenisKelamin = jenisKelaminController.text;
        profileData.namaSekolah = sekolahController.text;
        // jenjang is saved directly via setJenjang callback
        break;
      case 1:
        profileData.kelas = kelasController.text;
        profileData.jurusan = jurusanController.text;
        profileData.nilaiRataRata = nilaiController.text;
        break;
      // Step 2-6 save via toggle/callback langsung ke profileData
    }
  }

  // ─── Setter untuk Jenjang Pendidikan ───
  void setJenjang(String value) {
    profileData.jenjang = value;
    // Reset kelas saat ganti jenjang
    kelasController.clear();
    notifyListeners();
  }

  // ─── Setter untuk Tipe Nilai (Rapor vs IPK) ───
  void setTipeNilai(String value) {
    profileData.tipeNilai = value;
    notifyListeners();
  }

  // ─── Toggle Methods untuk Step 3: Finansial ───
  void setPenghasilanOrtu(String value) {
    profileData.penghasilanOrtu = value;
    notifyListeners();
  }

  void setBantuanSosial(String value) {
    profileData.bantuanSosial = value;
    notifyListeners();
  }

  void setTanggungan(String value) {
    profileData.tanggungan = value;
    notifyListeners();
  }

  void setPekerjaanOrtu(String value) {
    profileData.pekerjaanOrtu = value;
    notifyListeners();
  }

  // ─── Toggle Methods untuk Step 4: Prestasi Non-Akademik ───
  void setLevelPrestasi(String value) {
    profileData.levelPrestasi = value;
    notifyListeners();
  }

  void setJumlahPrestasi(String value) {
    profileData.jumlahPrestasi = value;
    notifyListeners();
  }

  void setOrganisasi(String value) {
    profileData.organisasi = value;
    notifyListeners();
  }

  void setAktivitasTambahan(String value) {
    profileData.aktivitasTambahan = value;
    notifyListeners();
  }

  // ─── Toggle Methods untuk Step 5: Minat & Bakat ───
  void toggleMinatBakat(String item) {
    if (profileData.minatBakat.contains(item)) {
      profileData.minatBakat.remove(item);
    } else {
      profileData.minatBakat.add(item);
    }
    notifyListeners();
  }

  // ─── Toggle Methods untuk Step 6: Dokumen & Motivasi ───
  void toggleDokumenPendukung(String item) {
    if (profileData.dokumenPendukung.contains(item)) {
      profileData.dokumenPendukung.remove(item);
    } else {
      profileData.dokumenPendukung.add(item);
    }
    notifyListeners();
  }

  void setKejelasanTujuan(String value) {
    profileData.kejelasanTujuan = value;
    notifyListeners();
  }

  void setTujuanKarir(String value) {
    profileData.tujuanKarir = value;
    notifyListeners();
  }

  void setKeterkaitan(String value) {
    profileData.keterkaitan = value;
    notifyListeners();
  }

  // ─── Toggle Methods untuk Step 7: Preferensi Beasiswa ───
  void toggleSumberPendanaan(String item) {
    if (profileData.sumberPendanaan.contains(item)) {
      profileData.sumberPendanaan.remove(item);
    } else {
      profileData.sumberPendanaan.add(item);
    }
    notifyListeners();
  }

  void toggleJenisBeasiswa(String item) {
    if (profileData.jenisBeasiswa.contains(item)) {
      profileData.jenisBeasiswa.remove(item);
    } else {
      profileData.jenisBeasiswa.add(item);
    }
    notifyListeners();
  }

  void toggleCakupanBiaya(String item) {
    if (profileData.cakupanBiaya.contains(item)) {
      profileData.cakupanBiaya.remove(item);
    } else {
      profileData.cakupanBiaya.add(item);
    }
    notifyListeners();
  }

  // ─── Finish & Save ke Firebase ───
  Future<void> finishSetup(BuildContext context) async {
    _saveCurrentStep();

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showError(context, "Terjadi kesalahan: Anda belum login!");
      return;
    }

    try {
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
            _showError(context, 'File $displayName tidak memiliki data atau path yang valid');
            return;
          }
          await ref.putData(fileBytes);
          uploadedFileNames.add(displayName);
        } catch (uploadError) {
          debugPrint('Upload error for $displayName: $uploadError');
          uploadedFileNames.add(displayName);
        }
      }

      double? nilai;
      if (profileData.nilaiRataRata.isNotEmpty) {
        nilai = double.tryParse(profileData.nilaiRataRata.replaceAll(',', '.'));
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        // Tandai setup selesai
        'setup_completed': true,
        'setup_step': totalSteps - 1,
        // Data profil
        'nama_lengkap': profileData.namaLengkap,
        'tanggal_lahir': profileData.tanggalLahir.isEmpty ? null : profileData.tanggalLahir,
        'jenis_kelamin': profileData.jenisKelamin,
        'jenjang': profileData.jenjang,
        'nama_sekolah': profileData.namaSekolah,
        'kelas': profileData.kelas,
        'jurusan': profileData.jurusan,
        'tipe_nilai': profileData.tipeNilai,
        'nilai_rata_rata': nilai,
        'prestasi': uploadedFileNames,
        'minat_bakat': profileData.minatBakat,
        // Finansial
        'penghasilan_ortu': profileData.penghasilanOrtu,
        'bantuan_sosial': profileData.bantuanSosial,
        'tanggungan': profileData.tanggungan,
        'pekerjaan_ortu': profileData.pekerjaanOrtu,
        // Non-Akademik
        'level_prestasi': profileData.levelPrestasi,
        'jumlah_prestasi': profileData.jumlahPrestasi,
        'organisasi': profileData.organisasi,
        'aktivitas_tambahan': profileData.aktivitasTambahan,
        // Dokumen & Motivasi
        'dokumen_pendukung': profileData.dokumenPendukung,
        'kejelasan_tujuan': profileData.kejelasanTujuan,
        'tujuan_karir': profileData.tujuanKarir,
        'keterkaitan': profileData.keterkaitan,
        // Preferensi
        'sumber_pendanaan': profileData.sumberPendanaan,
        'jenis_beasiswa': profileData.jenisBeasiswa,
        'cakupan_biaya': profileData.cakupanBiaya,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!context.mounted) return;
      final name = profileData.namaLengkap.isNotEmpty
          ? profileData.namaLengkap
          : 'User';

      // Navigasi ke Readiness Score Screen, bukan Welcome Screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ReadinessScoreScreen(
            userName: name,
            profileData: profileData,
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      _showError(context, "Gagal menyimpan data ke database: $e");
    }
  }
}
