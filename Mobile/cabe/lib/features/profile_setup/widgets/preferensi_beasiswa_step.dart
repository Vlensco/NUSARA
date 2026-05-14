import 'package:flutter/material.dart';
import 'package:cabe/core/theme/app_colors.dart';
import 'package:cabe/core/theme/app_text_styles.dart';
import 'package:cabe/features/profile_setup/models/profile_setup_data.dart';

/// Step 4: Preferensi Beasiswa
class PreferensiBeasiswaStep extends StatelessWidget {
  final List<String> selectedSumberPendanaan;
  final List<String> selectedJenisBeasiswa;
  final List<String> selectedCakupanBiaya;
  final ValueChanged<String> onToggleSumber;
  final ValueChanged<String> onToggleJenis;
  final ValueChanged<String> onToggleCakupan;

  const PreferensiBeasiswaStep({
    super.key,
    required this.selectedSumberPendanaan,
    required this.selectedJenisBeasiswa,
    required this.selectedCakupanBiaya,
    required this.onToggleSumber,
    required this.onToggleJenis,
    required this.onToggleCakupan,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Preferensi Beasiswa', style: AppTextStyles.h2),
          const SizedBox(height: 4),
          Text(
            'Jenis beasiswa apa yang kamu cari ?',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray500),
          ),
          const SizedBox(height: 28),

          // Sumber Pendanaan
          _sectionTitle('Berdasarkan sumber pendanaan (boleh lebih dari satu)'),
          const SizedBox(height: 12),
          _buildChips(sumberPendanaanOptions, selectedSumberPendanaan, onToggleSumber),
          const SizedBox(height: 24),

          // Jenis & Syarat
          _sectionTitle('Berdasarkan jenis dan syarat (boleh lebih dari satu)'),
          const SizedBox(height: 12),
          _buildChips(jenisBeasiswaOptions, selectedJenisBeasiswa, onToggleJenis),
          const SizedBox(height: 24),

          // Cakupan Biaya
          _sectionTitle('Berdasarkan cakupan biaya (boleh lebih dari satu)'),
          const SizedBox(height: 12),
          _buildChips(cakupanBiayaOptions, selectedCakupanBiaya, onToggleCakupan),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text, {bool isRequired = true}) {
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

  Widget _buildChips(
    List<String> options,
    List<String> selected,
    ValueChanged<String> onToggle,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 10,
      children: options.map((item) {
        final isSelected = selected.contains(item);
        return GestureDetector(
          onTap: () => onToggle(item),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.blue900 : AppColors.white,
              border: Border.all(
                color: isSelected ? AppColors.blue900 : AppColors.gray300,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              item,
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected ? AppColors.white : AppColors.gray700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
