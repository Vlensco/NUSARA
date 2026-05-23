import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cabe/core/theme/app_colors.dart';
import 'package:cabe/core/theme/app_text_styles.dart';
import 'package:cabe/features/auth/widgets/custom_text_field.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Step 2: Info Akademik
class InfoAkademikStep extends StatelessWidget {
  final TextEditingController kelasController;
  final TextEditingController jurusanController;
  final TextEditingController nilaiController;
  final VoidCallback? onUploadFile;
  final List<PlatformFile> newFiles;
  final void Function(PlatformFile)? onRemoveFile;

  const InfoAkademikStep({
    super.key,
    required this.kelasController,
    required this.jurusanController,
    required this.nilaiController,
    this.onUploadFile,
    this.newFiles = const [],
    this.onRemoveFile,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Info Akademik', style: AppTextStyles.h2),
          const SizedBox(height: 4),
          Text(
            'Bantu kami mencocokkan Beasiswa yang pas untukmu',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray500),
          ),
          const SizedBox(height: 28),

          _label('Kelas'),
          const SizedBox(height: 8),
          CustomTextField(
            hintText: 'Masukkan kelasmu saat ini . . .',
            controller: kelasController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 20),

          _label('Jurusan'),
          const SizedBox(height: 8),
          CustomTextField(
            hintText: 'Masukkan jurusanmu saat ini . . .',
            controller: jurusanController,
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 20),

          _label('Nilai rata - rata Rapor (0-100)'),
          const SizedBox(height: 8),
          CustomTextField(
            hintText: 'Contoh : 85',
            controller: nilaiController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
          ),
          const SizedBox(height: 20),

          _label('Prestasi (sertifikat, piagam, hingga piala)'),
          const SizedBox(height: 4),
          Text(
            '*Upload maksimum 10 file yang didukung : jpeg, jpg, png, pdf. Maks 5MB per file.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.gray400,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 12),

          if (newFiles.isNotEmpty) ...[
            ...newFiles.map((file) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(LucideIcons.fileText, size: 16, color: AppColors.gray500),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(file.name, style: const TextStyle(fontSize: 12, color: Colors.black54), overflow: TextOverflow.ellipsis),
                  ),
                  if (onRemoveFile != null)
                    GestureDetector(
                      onTap: () => onRemoveFile!(file),
                      child: const Icon(Icons.close, size: 16, color: Colors.red),
                    ),
                ],
              ),
            )),
            const SizedBox(height: 12),
          ],

          // Upload file button
          GestureDetector(
            onTap: onUploadFile,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.gray200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.upload, size: 16, color: AppColors.gray500),
                  const SizedBox(width: 8),
                  Text(
                    'Tambahkan file',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray500),
                  ),
                ],
              ),
            ),
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
