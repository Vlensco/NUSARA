import 'package:flutter/material.dart';
import 'package:cabe/core/theme/app_colors.dart';
import 'package:cabe/core/theme/app_text_styles.dart';
import 'package:cabe/features/profile_setup/models/profile_setup_data.dart';

/// Step 3: Kebutuhan Finansial — menggunakan Radio Widget sesungguhnya
class FinansialStep extends StatelessWidget {
  final String selectedPenghasilan;
  final String selectedBantuanSosial;
  final String selectedTanggungan;
  final String selectedPekerjaanOrtu;
  final ValueChanged<String> onPenghasilanChanged;
  final ValueChanged<String> onBantuanSosialChanged;
  final ValueChanged<String> onTanggunganChanged;
  final ValueChanged<String> onPekerjaanOrtuChanged;

  const FinansialStep({
    super.key,
    required this.selectedPenghasilan,
    required this.selectedBantuanSosial,
    required this.selectedTanggungan,
    required this.selectedPekerjaanOrtu,
    required this.onPenghasilanChanged,
    required this.onBantuanSosialChanged,
    required this.onTanggunganChanged,
    required this.onPekerjaanOrtuChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Kondisi Finansial', style: AppTextStyles.h2),
          const SizedBox(height: 4),
          Text(
            'Informasi ini membantu kami mencocokkan beasiswa yang sesuai dengan kondisimu.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray500),
          ),
          const SizedBox(height: 28),

          // Penghasilan Orang Tua
          _label('Berapa penghasilan orang tua/wali per bulan?'),
          const SizedBox(height: 8),
          _buildDropdown(
            value: selectedPenghasilan,
            hint: 'Pilih rentang penghasilan...',
            options: penghasilanOrtuOptions,
            onChanged: onPenghasilanChanged,
          ),
          const SizedBox(height: 20),

          // Bantuan Sosial — Radio Button Group
          _label('Apakah keluargamu menerima bantuan sosial?'),
          const SizedBox(height: 4),
          Text(
            'Contoh: KIP, PKH, BLT, atau bantuan lainnya.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.gray400,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 8),
          _buildRadioGroup(
            options: bantuanSosialOptions,
            selectedValue: selectedBantuanSosial,
            onChanged: onBantuanSosialChanged,
          ),
          const SizedBox(height: 20),

          // Tanggungan — Radio Button Group
          _label('Berapa jumlah tanggungan orang tua/wali?'),
          const SizedBox(height: 4),
          Text(
            'Termasuk dirimu dan saudara yang masih sekolah/kuliah.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.gray400,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 8),
          _buildRadioGroup(
            options: tanggunganOptions,
            selectedValue: selectedTanggungan,
            onChanged: onTanggunganChanged,
          ),
          const SizedBox(height: 20),

          // Pekerjaan Orang Tua — Radio Button Group
          _label('Status pekerjaan orang tua/wali'),
          const SizedBox(height: 8),
          _buildRadioGroup(
            options: pekerjaanOrtuOptions,
            selectedValue: selectedPekerjaanOrtu,
            onChanged: onPekerjaanOrtuChanged,
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

  Widget _buildDropdown({
    required String value,
    required String hint,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value.isEmpty ? null : value,
          hint: Text(hint, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray400)),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.gray400),
          items: options.map((opt) => DropdownMenuItem(
            value: opt,
            child: Text(opt, style: AppTextStyles.bodyMedium),
          )).toList(),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
        ),
      ),
    );
  }

  /// Menggunakan Flutter Radio widget sesungguhnya
  Widget _buildRadioGroup({
    required List<String> options,
    required String selectedValue,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      children: options.map((opt) {
        final isSelected = selectedValue == opt;
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Material(
            color: isSelected ? AppColors.blue900 : AppColors.white,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => onChanged(opt),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? AppColors.blue900 : AppColors.gray200,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: RadioListTile<String>(
                  value: opt,
                  groupValue: selectedValue,
                  onChanged: (val) {
                    if (val != null) onChanged(val);
                  },
                  title: Text(
                    opt,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isSelected ? Colors.white : AppColors.gray700,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  activeColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  dense: true,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
