import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cabe/core/theme/app_colors.dart';
import 'package:cabe/core/providers/user_profile_provider.dart';
import 'package:cabe/features/profile/controllers/edit_profile_controller.dart';

class EditProfileDialog extends ConsumerStatefulWidget {
  const EditProfileDialog({super.key});

  @override
  ConsumerState<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends ConsumerState<EditProfileDialog> {
  late final EditProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EditProfileController();
    _controller.addListener(_onControllerChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dbProfile = ref.read(userProfileProvider).value;
      _controller.loadFromProfile(dbProfile);
    });
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _handlePickFile() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Pilih sumber file",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppColors.blue900),
                title: const Text("Dari Galeri"),
                subtitle: const Text("Pilih gambar dari galeri foto", style: TextStyle(fontSize: 12)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickAndHandleError(() => _controller.pickFromGallery());
                },
              ),
              ListTile(
                leading: const Icon(Icons.folder_outlined, color: AppColors.blue900),
                title: const Text("Dari File"),
                subtitle: const Text("Pilih file JPG, PNG, atau PDF", style: TextStyle(fontSize: 12)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickAndHandleError(() => _controller.pickFromFiles());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _pickAndHandleError(Future<String?> Function() picker) async {
    final error = await picker();
    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  void _handleSave() async {
    final error = await _controller.saveData();
    if (!mounted) return;

    if (error == null) {
      ref.invalidate(userProfileProvider);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  void _handleAddCustomMinat() async {
    final textController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Minat Bakat'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(hintText: 'Masukkan minat/bakat...'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(textController.text.trim()),
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      _controller.addCustomMinatBakat(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── Header ──
            _buildHeader(),
            const SizedBox(height: 20),

            // ── Content ──
            Expanded(
              child: _controller.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : PageView(
                      controller: _controller.pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: _controller.setPage,
                      children: [
                        _buildPage1(),
                        _buildPage2(),
                        _buildPage3(),
                        _buildPage4(),
                      ],
                    ),
            ),
            const SizedBox(height: 16),

            // ── Footer Navigation ──
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // WIDGET BUILDERS 
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Edit Profil", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.close, size: 24),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    final page = _controller.currentPage;
    final loading = _controller.isLoading;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (page > 0 && !loading)
          GestureDetector(
            onTap: _controller.prevPage,
            child: const Text("<- Kembali", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          )
        else
          const SizedBox.shrink(),
        if (!loading)
          GestureDetector(
            onTap: page == 3 ? _handleSave : _controller.nextPage,
            child: Text(
              page == 3 ? "Simpan" : "selanjutnya ->",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
      ],
    );
  }

  // ── PAGE 1: Data Diri ──
  Widget _buildPage1() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField("Nama Lengkap", "Patrick Star", _controller.namaController),
          _buildTextField("Tanggal Lahir", "01/01/2000", _controller.tglLahirController),
          _buildTextField("Jenis Kelamin", "Laki-laki", _controller.jenisKelaminController),
          _buildTextField("Nama Sekolah", "SMA Bikini Bottom", _controller.sekolahController),
        ],
      ),
    );
  }

  // ── PAGE 2: Akademik & Prestasi ──
  Widget _buildPage2() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField("Kelas", "12", _controller.kelasController),
          _buildTextField("Jurusan", "IPS", _controller.jurusanController),
          _buildTextField("Nilai rata - rata Rapor", "87.94", _controller.nilaiRaporController),

          // Label
          RichText(
            text: const TextSpan(
              text: "Prestasi (sertifikat, piagam, hingga piala)",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.blue900),
              children: [TextSpan(text: ' *', style: TextStyle(color: Colors.red))],
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "*Upload maksimum 10 file yang didukung : jpeg, jpg, png. Maks 200kb per file.",
            style: TextStyle(fontSize: 11, color: Colors.black54),
          ),
          const SizedBox(height: 12),

          // File list dari DB
          ..._controller.prestasiFiles.map((name) => _buildFileRow(name)),
          // File baru yang dipilih
          ..._controller.newFiles.map((file) => _buildFileRow(file.name)),

          const SizedBox(height: 12),

          // Tombol upload
          GestureDetector(
            onTap: _handlePickFile,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.file_upload_outlined, size: 18, color: Colors.black),
                  SizedBox(width: 8),
                  Text("Tambahkan file", style: TextStyle(fontSize: 13, color: Colors.black87)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // PAGE 3: Minat & Bakat
  Widget _buildPage3() {
    final filteredOptions = _controller.filteredMinatOptions;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Pilih minat dan bakat kamu", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 16),

          // Search bar
          TextField(
            controller: _controller.minatSearchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Cari minat dan bakatmu disini...',
              prefixIcon: const Icon(Icons.search, size: 20),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.black12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...filteredOptions.map((item) => _buildChip(
                item,
                isSelected: _controller.selectedMinatBakat.contains(item),
                onTap: () => _controller.toggleMinatBakat(item),
              )),
              // +Lainnya chip
              _buildChip("+Lainnya...", isSelected: false, onTap: _handleAddCustomMinat),
            ],
          ),
        ],
      ),
    );
  }

  // PAGE 4: Preferensi Beasiswa
  Widget _buildPage4() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Berdasarkan sumber pendanaan", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildChipGroup(
            options: sumberPendanaanOptions,
            selected: _controller.selectedSumberPendanaan,
            onToggle: _controller.toggleSumberPendanaan,
          ),

          const SizedBox(height: 20),
          const Text("Berdasarkan jenis dan syarat", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildChipGroup(
            options: jenisSyaratOptions,
            selected: _controller.selectedJenisSyarat,
            onToggle: _controller.toggleJenisSyarat,
          ),

          const SizedBox(height: 20),
          const Text("Berdasarkan cakupan biaya", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildChipGroup(
            options: cakupanBiayaOptions,
            selected: _controller.selectedCakupanBiaya,
            onToggle: _controller.toggleCakupanBiaya,
          ),
        ],
      ),
    );
  }

  // REUSABLE MICRO-WIDGETS
  Widget _buildTextField(String label, String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.blue900),
              children: const [TextSpan(text: ' *', style: TextStyle(color: Colors.red))],
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.blue300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.blue300),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileRow(String fileName) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.file_present_outlined, size: 16, color: Colors.black54),
          const SizedBox(width: 8),
          Expanded(
            child: Text(fileName, style: const TextStyle(fontSize: 12, color: Colors.black54), overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _buildChipGroup({
    required List<String> options,
    required List<String> selected,
    required void Function(String) onToggle,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((item) => _buildChip(
        item,
        isSelected: selected.contains(item),
        onTap: () => onToggle(item),
      )).toList(),
    );
  }

  Widget _buildChip(String label, {bool isSelected = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.blue100 : Colors.transparent,
          border: Border.all(color: isSelected ? AppColors.blue300 : Colors.black12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.blue900 : Colors.black54,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
