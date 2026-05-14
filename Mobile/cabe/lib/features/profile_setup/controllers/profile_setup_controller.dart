import 'package:flutter/material.dart';
import 'package:cabe/features/profile_setup/models/profile_setup_data.dart';
import 'package:cabe/features/profile_setup/screens/welcome_screen.dart';

class ProfileSetupController extends ChangeNotifier {
  int currentStep = 0;
  final int totalSteps = 4;
  final ProfileSetupData profileData = ProfileSetupData();

  // ── Controllers Step 1 ──
  final namaController = TextEditingController();
  final tanggalLahirController = TextEditingController();
  final jenisKelaminController = TextEditingController();
  final sekolahController = TextEditingController();

  // ── Controllers Step 2 ──
  final kelasController = TextEditingController();
  final jurusanController = TextEditingController();
  final nilaiController = TextEditingController();
  final prestasiController = TextEditingController();

  ProfileSetupController() {
    namaController.addListener(notifyListeners);
    tanggalLahirController.addListener(notifyListeners);
    jenisKelaminController.addListener(notifyListeners);
    sekolahController.addListener(notifyListeners);
    
    kelasController.addListener(notifyListeners);
    jurusanController.addListener(notifyListeners);
    nilaiController.addListener(notifyListeners);
    prestasiController.addListener(notifyListeners);
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
    prestasiController.dispose();
    super.dispose();
  }

  // ── Navigation Logic ──
  void nextStep(BuildContext context) {
    if (!_validateCurrentStep(context)) return;

    _saveCurrentStep();
    if (currentStep < totalSteps - 1) {
      currentStep++;
      notifyListeners();
    } else {
      finishSetup(context);
    }
  }

  bool get isCurrentStepValid {
    if (currentStep == 0) {
      return namaController.text.trim().isNotEmpty &&
          tanggalLahirController.text.trim().isNotEmpty &&
          jenisKelaminController.text.trim().isNotEmpty &&
          sekolahController.text.trim().isNotEmpty;
    } else if (currentStep == 1) {
      return kelasController.text.trim().isNotEmpty &&
          jurusanController.text.trim().isNotEmpty &&
          nilaiController.text.trim().isNotEmpty;
    } else if (currentStep == 2) {
      return profileData.minatBakat.isNotEmpty;
    } else if (currentStep == 3) {
      return profileData.sumberPendanaan.isNotEmpty &&
          profileData.jenisBeasiswa.isNotEmpty &&
          profileData.cakupanBiaya.isNotEmpty;
    }
    return true;
  }

  bool _validateCurrentStep(BuildContext context) {
    if (currentStep == 0 && !isCurrentStepValid) {
      _showError(context, "Yuk, lengkapi profilmu dulu! Atau klik 'Lewati' kalau mau diisi nanti.");
      return false;
    } else if (currentStep == 1 && !isCurrentStepValid) {
      _showError(context, "Yuk, lengkapi profilmu dulu! Atau klik 'Lewati' kalau mau diisi nanti.");
      return false;
    } else if (currentStep == 2 && !isCurrentStepValid) {
      _showError(context, "Yuk, lengkapi profilmu dulu! Atau klik 'Lewati' kalau mau diisi nanti.");
      return false;
    } else if (currentStep == 3 && !isCurrentStepValid) {
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
        break;
      case 1:
        profileData.kelas = kelasController.text;
        profileData.jurusan = jurusanController.text;
        profileData.nilaiRataRata = nilaiController.text;
        profileData.prestasi = prestasiController.text;
        break;
    }
  }

  void finishSetup(BuildContext context) {
    final name = profileData.namaLengkap.isNotEmpty
        ? profileData.namaLengkap
        : 'Patrick Star';
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => WelcomeScreen(userName: name)),
    );
  }

  // ── Chips Toggle Logic ──
  void toggleMinatBakat(String item) {
    if (profileData.minatBakat.contains(item)) {
      profileData.minatBakat.remove(item);
    } else {
      profileData.minatBakat.add(item);
    }
    notifyListeners();
  }

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
}
