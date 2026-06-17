import 'package:flutter/material.dart';
import 'package:cabe/features/profile_setup/controllers/profile_setup_controller.dart';
import 'package:cabe/features/profile_setup/widgets/data_diri_step.dart';
import 'package:cabe/features/profile_setup/widgets/info_akademik_step.dart';
import 'package:cabe/features/profile_setup/widgets/finansial_step.dart';
import 'package:cabe/features/profile_setup/widgets/prestasi_non_akademik_step.dart';
import 'package:cabe/features/profile_setup/widgets/minat_bakat_step.dart';
import 'package:cabe/features/profile_setup/widgets/dokumen_motivasi_step.dart';
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
          selectedJenjang: controller.profileData.jenjang,
          onJenjangChanged: controller.setJenjang,
        );
      case 1:
        return InfoAkademikStep(
          kelasController: controller.kelasController,
          jurusanController: controller.jurusanController,
          nilaiController: controller.nilaiController,
          newFiles: controller.newFiles,
          onUploadFile: () => controller.pickFromFiles(context),
          onUploadGallery: () => controller.pickFromGallery(context),
          onRemoveFile: controller.removeFile,
          tipeNilai: controller.profileData.tipeNilai,
          onTipeNilaiChanged: controller.setTipeNilai,
          jenjang: controller.profileData.jenjang,
          renamedFiles: controller.renamedFiles,
          onRenameFile: controller.renameFile,
        );
      case 2:
        return FinansialStep(
          selectedPenghasilan: controller.profileData.penghasilanOrtu,
          selectedBantuanSosial: controller.profileData.bantuanSosial,
          selectedTanggungan: controller.profileData.tanggungan,
          selectedPekerjaanOrtu: controller.profileData.pekerjaanOrtu,
          onPenghasilanChanged: controller.setPenghasilanOrtu,
          onBantuanSosialChanged: controller.setBantuanSosial,
          onTanggunganChanged: controller.setTanggungan,
          onPekerjaanOrtuChanged: controller.setPekerjaanOrtu,
        );
      case 3:
        return PrestasiNonAkademikStep(
          selectedLevelPrestasi: controller.profileData.levelPrestasi,
          selectedJumlahPrestasi: controller.profileData.jumlahPrestasi,
          selectedOrganisasi: controller.profileData.organisasi,
          selectedAktivitasTambahan: controller.profileData.aktivitasTambahan,
          onLevelPrestasiChanged: controller.setLevelPrestasi,
          onJumlahPrestasiChanged: controller.setJumlahPrestasi,
          onOrganisasiChanged: controller.setOrganisasi,
          onAktivitasTambahanChanged: controller.setAktivitasTambahan,
        );
      case 4:
        return MinatBakatStep(
          selectedItems: controller.profileData.minatBakat,
          onToggle: controller.toggleMinatBakat,
        );
      case 5:
        return DokumenMotivasiStep(
          selectedDokumen: controller.profileData.dokumenPendukung,
          selectedKejelasanTujuan: controller.profileData.kejelasanTujuan,
          selectedTujuanKarir: controller.profileData.tujuanKarir,
          selectedKeterkaitan: controller.profileData.keterkaitan,
          onToggleDokumen: controller.toggleDokumenPendukung,
          onKejelasanTujuanChanged: controller.setKejelasanTujuan,
          onTujuanKarirChanged: controller.setTujuanKarir,
          onKeterkaitanChanged: controller.setKeterkaitan,
        );
      case 6:
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
