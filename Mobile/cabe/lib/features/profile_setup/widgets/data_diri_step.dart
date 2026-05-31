import 'package:flutter/material.dart';
import 'package:cabe/core/theme/app_colors.dart';
import 'package:cabe/core/theme/app_text_styles.dart';
import 'package:cabe/features/auth/widgets/custom_text_field.dart';
import 'package:cabe/features/profile_setup/models/profile_setup_data.dart';

/// Step 1: Data Diri — dengan dropdown Jenjang Pendidikan
class DataDiriStep extends StatelessWidget {
  final TextEditingController namaController;
  final TextEditingController tanggalLahirController;
  final TextEditingController jenisKelaminController;
  final TextEditingController sekolahController;
  final String selectedJenjang;
  final ValueChanged<String> onJenjangChanged;

  const DataDiriStep({
    super.key,
    required this.namaController,
    required this.tanggalLahirController,
    required this.jenisKelaminController,
    required this.sekolahController,
    required this.selectedJenjang,
    required this.onJenjangChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              text: 'Selamat Datang di ',
              style: AppTextStyles.h2,
              children: [
                TextSpan(
                  text: 'CaBe !',
                  style: AppTextStyles.h2.copyWith(color: AppColors.blue900),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Yuk kenalan dulu. Siapa nama Kamu?',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray500),
          ),
          const SizedBox(height: 28),

          _label('Nama Lengkap'),
          const SizedBox(height: 8),
          CustomTextField(
            hintText: 'Masukkan nama lengkapmu...',
            controller: namaController,
            keyboardType: TextInputType.name,
          ),
          const SizedBox(height: 20),

          _label('Tanggal Lahir'),
          const SizedBox(height: 8),
          CustomTextField(
            hintText: 'Masukkan tanggal lahirmu...',
            controller: tanggalLahirController,
            keyboardType: TextInputType.datetime,
            readOnly: true,
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                tanggalLahirController.text = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
              }
            },
          ),
          const SizedBox(height: 20),

          _label('Jenis Kelamin'),
          const SizedBox(height: 8),
          CustomTextField(
            hintText: 'Masukkan jenis kelaminmu...',
            controller: jenisKelaminController,
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 20),

          // ─── Jenjang Pendidikan Dropdown ───
          _label('Jenjang Pendidikan'),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(
                color: selectedJenjang.isNotEmpty ? AppColors.blue900 : AppColors.gray200,
              ),
              borderRadius: BorderRadius.circular(12),
              color: selectedJenjang.isNotEmpty ? AppColors.blue900.withValues(alpha: 0.04) : Colors.white,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedJenjang.isEmpty ? null : selectedJenjang,
                hint: Text(
                  'Pilih jenjang pendidikanmu',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray400),
                ),
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.gray400),
                items: jenjangOptions.map((opt) => DropdownMenuItem(
                  value: opt,
                  child: Text(opt, style: AppTextStyles.bodyMedium),
                )).toList(),
                onChanged: (val) {
                  if (val != null) onJenjangChanged(val);
                },
              ),
            ),
          ),
          const SizedBox(height: 20),

          _label('Asal Sekolah / Kampus'),
          const SizedBox(height: 8),
          CustomTextField(
            hintText: 'Contoh: SMAN 1 Semarang / Universitas Diponegoro',
            controller: sekolahController,
            keyboardType: TextInputType.text,
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
}
