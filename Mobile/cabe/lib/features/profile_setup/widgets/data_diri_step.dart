import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cabe/core/theme/app_colors.dart';
import 'package:cabe/core/theme/app_text_styles.dart';
import 'package:cabe/features/auth/widgets/custom_text_field.dart';

/// Step 1: Data Diri
class DataDiriStep extends StatelessWidget {
  final TextEditingController namaController;
  final TextEditingController tanggalLahirController;
  final TextEditingController jenisKelaminController;
  final TextEditingController sekolahController;

  const DataDiriStep({
    super.key,
    required this.namaController,
    required this.tanggalLahirController,
    required this.jenisKelaminController,
    required this.sekolahController,
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

          _label('Nama Sekolah'),
          const SizedBox(height: 8),
          CustomTextField(
            hintText: 'SMA / SMK...',
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
