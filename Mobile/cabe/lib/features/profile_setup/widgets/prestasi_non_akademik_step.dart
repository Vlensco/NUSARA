import 'package:flutter/material.dart';
import 'package:cabe/core/theme/app_colors.dart';
import 'package:cabe/core/theme/app_text_styles.dart';
import 'package:cabe/features/profile_setup/models/profile_setup_data.dart';

/// Step 4: Prestasi Non-Akademik
class PrestasiNonAkademikStep extends StatelessWidget {
  final String selectedLevelPrestasi;
  final String selectedJumlahPrestasi;
  final String selectedOrganisasi;
  final String selectedAktivitasTambahan;
  final ValueChanged<String> onLevelPrestasiChanged;
  final ValueChanged<String> onJumlahPrestasiChanged;
  final ValueChanged<String> onOrganisasiChanged;
  final ValueChanged<String> onAktivitasTambahanChanged;

  const PrestasiNonAkademikStep({
    super.key,
    required this.selectedLevelPrestasi,
    required this.selectedJumlahPrestasi,
    required this.selectedOrganisasi,
    required this.selectedAktivitasTambahan,
    required this.onLevelPrestasiChanged,
    required this.onJumlahPrestasiChanged,
    required this.onOrganisasiChanged,
    required this.onAktivitasTambahanChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Prestasi & Kegiatan', style: AppTextStyles.h2),
          const SizedBox(height: 4),
          Text(
            'Ceritakan pencapaian dan pengalamanmu di luar kelas!',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray500),
          ),
          const SizedBox(height: 28),

          // Level Prestasi Tertinggi
          _label('Apa tingkat prestasi tertinggi yang pernah kamu capai?'),
          const SizedBox(height: 4),
          Text(
            'Lomba, kompetisi, olimpiade, dll.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.gray400,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 8),
          _buildRadioGroup(
            options: levelPrestasiOptions,
            selectedValue: selectedLevelPrestasi,
            onChanged: onLevelPrestasiChanged,
          ),
          const SizedBox(height: 20),

          // Jumlah Prestasi
          _label('Berapa jumlah prestasi yang pernah kamu raih?'),
          const SizedBox(height: 8),
          _buildRadioGroup(
            options: jumlahPrestasiOptions,
            selectedValue: selectedJumlahPrestasi,
            onChanged: onJumlahPrestasiChanged,
          ),
          const SizedBox(height: 20),

          // Organisasi
          _label('Peran kamu di organisasi atau ekstrakurikuler?'),
          const SizedBox(height: 4),
          Text(
            'OSIS, PMR, Pramuka, BEM, atau organisasi lainnya.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.gray400,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 8),
          _buildRadioGroup(
            options: organisasiOptions,
            selectedValue: selectedOrganisasi,
            onChanged: onOrganisasiChanged,
          ),
          const SizedBox(height: 20),

          // Aktivitas Tambahan
          _label('Apakah kamu aktif di kegiatan tambahan lain?'),
          const SizedBox(height: 4),
          Text(
            'Volunteer, kursus, komunitas, dll.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.gray400,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 8),
          _buildRadioGroup(
            options: aktivitasTambahanOptions,
            selectedValue: selectedAktivitasTambahan,
            onChanged: onAktivitasTambahanChanged,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _label(String text, {bool isRequired = true}) {
    return Text.rich(
      TextSpan(
        text: text,
        style: AppTextStyles.labelLarge.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.blue900,
        ),
        children: [
          if (isRequired)
            TextSpan(
              text: ' *',
              style: AppTextStyles.labelLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRadioGroup({
    required List<String> options,
    required String selectedValue,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      children: options.map((opt) {
        final isSelected = selectedValue == opt;
        return GestureDetector(
          onTap: () => onChanged(opt),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.blue900 : AppColors.white,
              border: Border.all(
                color: isSelected ? AppColors.blue900 : AppColors.gray200,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : AppColors.gray300,
                      width: 2,
                    ),
                    color: isSelected ? AppColors.blue900 : Colors.transparent,
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    opt,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isSelected ? Colors.white : AppColors.gray700,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
