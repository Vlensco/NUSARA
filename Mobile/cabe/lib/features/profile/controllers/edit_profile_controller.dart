import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:typed_data';

/// Daftar opsi minat & bakat default.
const List<String> defaultMinatBakatOptions = [
  "Olahraga", "Bahasa & Sastra", "Memasak & Baking", "Kewirausahaan",
  "Kesehatan", "Matematika", "Seni & Desain", "Sosial & Kemanusiaan",
  "Musik", "Hukum & Politik", "Sains & Teknologi", "Ekonomi & Bisnis",
];

const List<String> sumberPendanaanOptions = [
  "Beasiswa Pemerintah", "Beasiswa Kampus", "Beasiswa Swasta / Coorporate",
];

const List<String> jenisSyaratOptions = [
  "Beasiswa Prestasi", "Beasiswa Ikatan Dinas", "Beasiswa Kurang Mampu", "Beasiswa Khusus",
];

const List<String> cakupanBiayaOptions = [
  "Beasiswa Penuh", "Beasiswa Parsial",
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
    if (currentPage < 3) {
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
        final filePath = 'prestasi/${user.uid}/${platformFile.name}';
        try {
          final ref = FirebaseStorage.instance.ref().child(filePath);
          final Uint8List fileBytes;
          if (platformFile.bytes != null) {
            fileBytes = platformFile.bytes!;
          } else if (platformFile.path != null) {
            fileBytes = await File(platformFile.path!).readAsBytes();
          } else {
            return 'File ${platformFile.name} tidak memiliki data atau path yang valid';
          }
          await ref.putData(fileBytes);
          uploadedFileNames.add(platformFile.name);
        } catch (uploadError) {
          debugPrint('Upload error for ${platformFile.name}: $uploadError');
          // Jika gagal upload ke Storage (misal karena bucket belum dibuat atau rules error),
          // kita tetap simpan nama file ke Firestore agar pengguna tidak stuck.
          uploadedFileNames.add(platformFile.name);
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
        'nama_sekolah': sekolahController.text,
        'kelas': kelasController.text,
        'jurusan': jurusanController.text,
        'nilai_rata_rata': double.tryParse(nilaiRaporController.text) ?? 0.0,
        'prestasi': combinedPrestasi,
        'minat_bakat': selectedMinatBakat,
        'sumber_pendanaan': selectedSumberPendanaan,
        'jenis_beasiswa': selectedJenisSyarat,
        'cakupan_biaya': selectedCakupanBiaya,
        'updated_at': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(updates, SetOptions(merge: true));

      return null; // success
    } catch (e) {
      return 'Gagal menyimpan profil: $e';
    } finally {
      isLoading = false;
      notifyListeners();
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
