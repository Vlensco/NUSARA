import 'package:flutter/material.dart';
import 'package:cabe/core/theme/app_colors.dart';
import 'package:cabe/core/theme/app_text_styles.dart';
import 'package:cabe/features/profile_setup/models/profile_setup_data.dart';

/// Step 6: Dokumen Pendukung & Motivasi/Karir
class DokumenMotivasiStep extends StatelessWidget {
  final List<String> selectedDokumen;
  final String selectedKejelasanTujuan;
  final String selectedTujuanKarir;
  final String selectedKeterkaitan;
  final ValueChanged<String> onToggleDokumen;
  final ValueChanged<String> onKejelasanTujuanChanged;
  final ValueChanged<String> onTujuanKarirChanged;
  final ValueChanged<String> onKeterkaitanChanged;

  const DokumenMotivasiStep({
    super.key,
    required this.selectedDokumen,
    required this.selectedKejelasanTujuan,
    required this.selectedTujuanKarir,
    required this.selectedKeterkaitan,
    required this.onToggleDokumen,
    required this.onKejelasanTujuanChanged,
    required this.onTujuanKarirChanged,
    required this.onKeterkaitanChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dokumen & Rencana', style: AppTextStyles.h2),
          const SizedBox(height: 4),
          Text(
            'Dokumen pendukung dan rencanamu ke depan akan membantu kami menilai kesiapanmu.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray500),
          ),
          const SizedBox(height: 28),

          // ─── Dokumen Pendukung (Checkbox) ───
          _label('Dokumen apa saja yang sudah kamu siapkan?'),
          const SizedBox(height: 4),
          Text(
            'Boleh pilih lebih dari satu.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.gray400,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 8),
          ...dokumenPendukungOptions.map((opt) => _buildCheckbox(
            label: _dokumenLabel(opt),
            subtitle: _dokumenSubtitle(opt),
            isChecked: selectedDokumen.contains(opt),
            onTap: () => onToggleDokumen(opt),
          )),
          const SizedBox(height: 24),

          // ─── Motivasi: Kejelasan Tujuan Studi ───
          _divider('Rencana & Motivasi'),
          const SizedBox(height: 16),

          _label('Apakah kamu sudah tahu jurusan atau bidang yang ingin diambil?'),
          const SizedBox(height: 8),
          _buildRadioGroup(
            options: kejelasanTujuanOptions,
            selectedValue: selectedKejelasanTujuan,
            onChanged: onKejelasanTujuanChanged,
          ),
          const SizedBox(height: 20),

          // Tujuan Karir
          _label('Apakah kamu memiliki rencana karir setelah lulus?'),
          const SizedBox(height: 8),
          _buildRadioGroup(
            options: tujuanKarirOptions,
            selectedValue: selectedTujuanKarir,
            onChanged: onTujuanKarirChanged,
          ),
          const SizedBox(height: 20),

          // Keterkaitan
          _label('Apakah pilihan studimu sesuai dengan rencana karirmu?'),
          const SizedBox(height: 8),
          _buildRadioGroup(
            options: keterkaitanOptions,
            selectedValue: selectedKeterkaitan,
            onChanged: onKeterkaitanChanged,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _dokumenLabel(String key) {
    switch (key) {
      case 'Rekomendasi': return 'Surat Rekomendasi';
      case 'CV': return 'CV (Curriculum Vitae)';
      case 'Sertifikat Khusus': return 'Sertifikat Khusus';
      default: return key;
    }
  }

  String _dokumenSubtitle(String key) {
    switch (key) {
      case 'Rekomendasi': return 'Dari guru, dosen, atau pembimbing.';
      case 'CV': return 'Daftar riwayat hidup dan pencapaianmu.';
      case 'Sertifikat Khusus': return 'Sertifikat keahlian, pelatihan, dll.';
      default: return '';
    }
  }

  Widget _divider(String text) {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.gray200)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.gray400,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.gray200)),
      ],
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

  Widget _buildCheckbox({
    required String label,
    required String subtitle,
    required bool isChecked,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isChecked ? AppColors.blue900 : AppColors.white,
          border: Border.all(
            color: isChecked ? AppColors.blue900 : AppColors.gray200,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isChecked ? Colors.white : AppColors.gray300,
                  width: 2,
                ),
                color: isChecked ? Colors.white : Colors.transparent,
              ),
              child: isChecked
                  ? const Icon(Icons.check, size: 16, color: AppColors.blue900)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isChecked ? Colors.white : AppColors.gray700,
                      fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.gray400,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
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
