import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cabe/core/theme/app_colors.dart';
import 'package:cabe/core/theme/app_text_styles.dart';
import 'package:cabe/features/auth/widgets/custom_text_field.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Step 2: Info Akademik — dengan toggle Jenis Nilai (Rapor / IPK)
class InfoAkademikStep extends StatelessWidget {
  final TextEditingController kelasController;
  final TextEditingController jurusanController;
  final TextEditingController nilaiController;
  final VoidCallback? onUploadFile;
  final VoidCallback? onUploadGallery;
  final List<PlatformFile> newFiles;
  final void Function(PlatformFile)? onRemoveFile;
  final String tipeNilai; // "rapor" atau "ipk"
  final ValueChanged<String> onTipeNilaiChanged;
  final String jenjang; // Jenjang pendidikan dari Step 1
  final Map<String, String> renamedFiles;
  final void Function(PlatformFile, String)? onRenameFile;

  const InfoAkademikStep({
    super.key,
    required this.kelasController,
    required this.jurusanController,
    required this.nilaiController,
    this.onUploadFile,
    this.onUploadGallery,
    this.newFiles = const [],
    this.onRemoveFile,
    required this.tipeNilai,
    required this.onTipeNilaiChanged,
    this.jenjang = '',
    required this.renamedFiles,
    this.onRenameFile,
  });

  bool get _isSekolahMenengah => jenjang == 'SMA/SMK/MA';
  bool get _isKuliah => jenjang.contains('D3') || jenjang.contains('S1') || jenjang.contains('S2') || jenjang.contains('D4');

  @override
  Widget build(BuildContext context) {
    final isRapor = tipeNilai == 'rapor';

    // Dropdown options based on jenjang
    final List<String> kelasOptions = _isSekolahMenengah
        ? ['10', '11', '12']
        : ['1', '2', '3', '4', '5', '6', '7', '8+'];

    final String kelasLabel = _isSekolahMenengah ? 'Kelas' : 'Semester';
    final String kelasHint = _isSekolahMenengah
        ? 'Pilih kelasmu saat ini'
        : 'Pilih semestermu saat ini';

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

          _label(kelasLabel),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(
                color: kelasController.text.isNotEmpty ? AppColors.blue900 : AppColors.gray200,
              ),
              borderRadius: BorderRadius.circular(12),
              color: kelasController.text.isNotEmpty
                  ? AppColors.blue900.withValues(alpha: 0.04)
                  : Colors.white,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: kelasOptions.contains(kelasController.text)
                    ? kelasController.text
                    : null,
                hint: Text(
                  kelasHint,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray400),
                ),
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.gray400),
                items: kelasOptions.map((opt) => DropdownMenuItem(
                  value: opt,
                  child: Text(
                    _isSekolahMenengah ? 'Kelas $opt' : 'Semester $opt',
                    style: AppTextStyles.bodyMedium,
                  ),
                )).toList(),
                onChanged: (val) {
                  if (val != null) {
                    kelasController.text = val;
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 20),

          _label('Jurusan / Program Studi'),
          const SizedBox(height: 8),
          CustomTextField(
            hintText: 'Masukkan jurusanmu saat ini . . .',
            controller: jurusanController,
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 20),

          // ─── Jenis Nilai Toggle + Input ───
          _label('Nilai Akademik'),
          const SizedBox(height: 8),

          // Toggle: Rapor / IPK
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                _buildToggleOption(
                  label: 'Rapor (Skala 100)',
                  isActive: isRapor,
                  onTap: () => onTipeNilaiChanged('rapor'),
                ),
                const SizedBox(width: 4),
                _buildToggleOption(
                  label: 'IPK (Skala 4.0)',
                  isActive: !isRapor,
                  onTap: () => onTipeNilaiChanged('ipk'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Input nilai yang berubah sesuai tipe
          CustomTextField(
            hintText: isRapor ? 'Contoh: 85' : 'Contoh: 3.75',
            controller: nilaiController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
          ),
          Text(
            isRapor
                ? 'Masukkan nilai rata-rata rapor (skala 0 - 100)'
                : 'Masukkan IPK kumulatif (skala 0 - 4.0)',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.gray400,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 20),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context, PlatformFile file) {
    final originalName = renamedFiles[file.name] ?? file.name;
    final ext = file.extension;
    String nameWithoutExt = originalName;
    if (ext != null && ext.isNotEmpty && originalName.endsWith('.$ext')) {
      nameWithoutExt = originalName.substring(0, originalName.length - ext.length - 1);
    }
    
    final editController = TextEditingController(text: nameWithoutExt);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ganti Nama File'),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(
            hintText: 'Masukkan nama file baru...',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              if (editController.text.trim().isNotEmpty && onRenameFile != null) {
                onRenameFile!(file, editController.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isActive ? AppColors.blue900 : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive ? AppColors.blue900 : Colors.transparent,
              width: 2,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.blue900.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Radio indicator
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive ? Colors.white : AppColors.gray300,
                    width: 2,
                  ),
                  color: isActive ? AppColors.blue900 : Colors.white,
                ),
                child: isActive
                    ? Center(
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isActive ? Colors.white : AppColors.gray500,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
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
