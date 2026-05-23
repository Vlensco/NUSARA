import 'package:flutter/material.dart';
import 'package:cabe/features/profile_setup/controllers/profile_setup_controller.dart';
import 'package:cabe/features/profile_setup/widgets/data_diri_step.dart';
import 'package:cabe/features/profile_setup/widgets/info_akademik_step.dart';
import 'package:cabe/features/profile_setup/widgets/minat_bakat_step.dart';
import 'package:cabe/features/profile_setup/widgets/preferensi_beasiswa_step.dart';

class ProfileSetupContent extends StatelessWidget {
  final ProfileSetupController controller;

  const ProfileSetupContent({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    switch (controller.currentStep) {
      case 0:
        return DataDiriStep(
          namaController: controller.namaController,
          tanggalLahirController: controller.tanggalLahirController,
          jenisKelaminController: controller.jenisKelaminController,
          sekolahController: controller.sekolahController,
        );
      case 1:
        return InfoAkademikStep(
          kelasController: controller.kelasController,
          jurusanController: controller.jurusanController,
          nilaiController: controller.nilaiController,
          newFiles: controller.newFiles,
          onUploadFile: () => controller.pickFiles(context),
          onRemoveFile: controller.removeFile,
        );
      case 2:
        return MinatBakatStep(
          selectedItems: controller.profileData.minatBakat,
          onToggle: controller.toggleMinatBakat,
        );
      case 3:
        return PreferensiBeasiswaStep(
          selectedSumberPendanaan: controller.profileData.sumberPendanaan,
          selectedJenisBeasiswa: controller.profileData.jenisBeasiswa,
          selectedCakupanBiaya: controller.profileData.cakupanBiaya,
          onToggleSumber: controller.toggleSumberPendanaan,
          onToggleJenis: controller.toggleJenisBeasiswa,
          onToggleCakupan: controller.toggleCakupanBiaya,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
