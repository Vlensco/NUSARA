import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cabe/core/theme/app_colors.dart';
import 'package:cabe/core/providers/user_profile_provider.dart';
import 'package:cabe/features/profile/controllers/edit_profile_controller.dart';
import 'package:cabe/features/profile_setup/models/profile_setup_data.dart';

class EditProfileDialog extends ConsumerStatefulWidget {
  const EditProfileDialog({super.key});

  @override
  ConsumerState<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends ConsumerState<EditProfileDialog> {
  late final EditProfileController _controller;
  static const int _totalPages = 7;

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
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── Header ──
            _buildHeader(),
            const SizedBox(height: 12),

            // ── Page Indicator ──
            _buildPageIndicator(),
            const SizedBox(height: 16),

            // ── Content ──
            Expanded(
              child: _controller.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : PageView(
                      controller: _controller.pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: _controller.setPage,
                      children: [
                        _buildPageDataDiri(),
                        _buildPageAkademik(),
                        _buildPageFinansial(),
                        _buildPagePrestasiNonAkademik(),
                        _buildPageMinatBakat(),
                        _buildPageDokumenMotivasi(),
                        _buildPagePreferensi(),
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

  // ─── HEADER ───
  Widget _buildHeader() {
    const pageTitles = [
      'Data Diri',
      'Info Akademik',
      'Kondisi Finansial',
      'Prestasi & Kegiatan',
      'Minat & Bakat',
      'Dokumen & Rencana',
      'Preferensi Beasiswa',
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Edit Profil", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(
              pageTitles[_controller.currentPage],
              style: const TextStyle(fontSize: 12, color: AppColors.gray500),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.close, size: 24),
        ),
      ],
    );
  }

  // ─── PAGE INDICATOR ───
  Widget _buildPageIndicator() {
    return Row(
      children: List.generate(_totalPages, (i) {
        final isActive = i <= _controller.currentPage;
        return Expanded(
          child: Container(
            height: 3,
            margin: EdgeInsets.only(right: i < _totalPages - 1 ? 4 : 0),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF003875) : AppColors.gray200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  // ─── FOOTER ───
  Widget _buildFooter() {
    final page = _controller.currentPage;
    final loading = _controller.isLoading;
    final isLast = page == _totalPages - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (page > 0 && !loading)
          GestureDetector(
            onTap: _controller.prevPage,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.gray200),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back_ios, size: 14, color: AppColors.gray700),
                  SizedBox(width: 4),
                  Text("Kembali", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.gray700)),
                ],
              ),
            ),
          )
        else
          const SizedBox.shrink(),
        if (!loading)
          GestureDetector(
            onTap: isLast ? _handleSave : _controller.nextPage,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.blue900,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isLast ? "Simpan" : "Selanjutnya",
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white),
                  ),
                  if (!isLast) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ═══════════════════════════════════
  // PAGE 1: Data Diri
  // ═══════════════════════════════════
  Widget _buildPageDataDiri() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField("Nama Lengkap", "Patrick Star", _controller.namaController),
          _buildTextField("Tanggal Lahir", "01/01/2000", _controller.tglLahirController),
          _buildTextField("Jenis Kelamin", "Laki-laki", _controller.jenisKelaminController),

          // ─── Jenjang Pendidikan Dropdown ───
          _buildLabel("Jenjang Pendidikan"),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(
                color: _controller.jenjang.isNotEmpty ? AppColors.blue900 : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(12),
              color: _controller.jenjang.isNotEmpty
                  ? AppColors.blue900.withValues(alpha: 0.04)
                  : Colors.white,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _controller.jenjang.isEmpty ? null : _controller.jenjang,
                hint: const Text("Pilih jenjang pendidikanmu"),
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                items: const [
                  DropdownMenuItem(value: 'SMA/SMK/MA', child: Text('SMA/SMK/MA')),
                  DropdownMenuItem(value: 'D3 (Diploma)', child: Text('D3 (Diploma)')),
                  DropdownMenuItem(value: 'D4/S1 (Sarjana)', child: Text('D4/S1 (Sarjana)')),
                  DropdownMenuItem(value: 'S2 (Magister)', child: Text('S2 (Magister)')),
                ],
                onChanged: (val) {
                  if (val != null) _controller.setJenjang(val);
                },
              ),
            ),
          ),
          const SizedBox(height: 12),

          _buildTextField("Asal Sekolah / Kampus", "Contoh: SMAN 1 Semarang / Universitas Diponegoro", _controller.sekolahController),
        ],
      ),
    );
  }

  // ═══════════════════════════════════
  // PAGE 2: Akademik + Tipe Nilai Toggle
  // ═══════════════════════════════════
  Widget _buildPageAkademik() {
    final isRapor = _controller.tipeNilai == 'rapor';
    final isSMA = _controller.isSekolahMenengah;
    final kelasLabel = isSMA ? 'Kelas' : 'Semester';
    final kelasOptions = isSMA ? ['10', '11', '12'] : ['1', '2', '3', '4', '5', '6', '7', '8+'];
    final currentKelas = _controller.kelasController.text;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Kelas / Semester Dropdown ───
          _buildLabel(kelasLabel),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(
                color: currentKelas.isNotEmpty ? AppColors.blue900 : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(12),
              color: currentKelas.isNotEmpty
                  ? AppColors.blue900.withValues(alpha: 0.04)
                  : Colors.white,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: kelasOptions.contains(currentKelas) ? currentKelas : null,
                hint: Text(isSMA ? 'Pilih kelasmu' : 'Pilih semestermu'),
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                items: kelasOptions.map((opt) => DropdownMenuItem(
                  value: opt,
                  child: Text(isSMA ? 'Kelas $opt' : 'Semester $opt'),
                )).toList(),
                onChanged: (val) {
                  if (val != null) {
                    _controller.kelasController.text = val;
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildTextField("Jurusan / Program Studi", "IPA", _controller.jurusanController),

          // ─── Tipe Nilai Toggle ───
          _buildLabel("Nilai Akademik"),
          const SizedBox(height: 8),
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
                  onTap: () => _controller.setTipeNilai('rapor'),
                ),
                const SizedBox(width: 4),
                _buildToggleOption(
                  label: 'IPK (Skala 4.0)',
                  isActive: !isRapor,
                  onTap: () => _controller.setTipeNilai('ipk'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            isRapor ? "Nilai Rapor (0-100)" : "IPK (0-4.0)",
            isRapor ? "Contoh: 85" : "Contoh: 3.75",
            _controller.nilaiRaporController,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════
  // PAGE 3: Kondisi Finansial
  // ═══════════════════════════════════
  Widget _buildPageFinansial() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel("Penghasilan orang tua/wali per bulan"),
          const SizedBox(height: 8),
          _buildDropdown(
            value: _controller.penghasilanOrtu,
            hint: 'Pilih rentang penghasilan...',
            options: penghasilanOrtuOptions,
            onChanged: _controller.setPenghasilanOrtu,
          ),
          const SizedBox(height: 20),

          _buildLabel("Menerima bantuan sosial?"),
          const SizedBox(height: 4),
          const Text('Contoh: KIP, PKH, BLT', style: TextStyle(fontSize: 11, color: Colors.black54)),
          const SizedBox(height: 8),
          _buildRadioGroup(
            options: bantuanSosialOptions,
            selectedValue: _controller.bantuanSosial,
            onChanged: _controller.setBantuanSosial,
          ),
          const SizedBox(height: 20),

          _buildLabel("Jumlah tanggungan orang tua/wali"),
          const SizedBox(height: 8),
          _buildRadioGroup(
            options: tanggunganOptions,
            selectedValue: _controller.tanggungan,
            onChanged: _controller.setTanggungan,
          ),
          const SizedBox(height: 20),

          _buildLabel("Status pekerjaan orang tua/wali"),
          const SizedBox(height: 8),
          _buildRadioGroup(
            options: pekerjaanOrtuOptions,
            selectedValue: _controller.pekerjaanOrtu,
            onChanged: _controller.setPekerjaanOrtu,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════
  // PAGE 4: Prestasi Non-Akademik
  // ═══════════════════════════════════
  Widget _buildPagePrestasiNonAkademik() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel("Tingkat prestasi tertinggi"),
          const SizedBox(height: 8),
          _buildRadioGroup(
            options: levelPrestasiOptions,
            selectedValue: _controller.levelPrestasi,
            onChanged: _controller.setLevelPrestasi,
          ),
          const SizedBox(height: 20),

          _buildLabel("Jumlah prestasi yang diraih"),
          const SizedBox(height: 8),
          _buildRadioGroup(
            options: jumlahPrestasiOptions,
            selectedValue: _controller.jumlahPrestasi,
            onChanged: _controller.setJumlahPrestasi,
          ),
          const SizedBox(height: 20),

          _buildLabel("Peran di organisasi/ekstrakurikuler"),
          const SizedBox(height: 8),
          _buildRadioGroup(
            options: organisasiOptions,
            selectedValue: _controller.organisasi,
            onChanged: _controller.setOrganisasi,
          ),
          const SizedBox(height: 20),

          _buildLabel("Aktif di kegiatan tambahan?"),
          const SizedBox(height: 8),
          _buildRadioGroup(
            options: aktivitasTambahanOptions,
            selectedValue: _controller.aktivitasTambahan,
            onChanged: _controller.setAktivitasTambahan,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════
  // PAGE 5: Minat & Bakat
  // ═══════════════════════════════════
  Widget _buildPageMinatBakat() {
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
              _buildChip("+Lainnya...", isSelected: false, onTap: _handleAddCustomMinat),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════
  // PAGE 6: Dokumen & Motivasi/Rencana
  // ═══════════════════════════════════
  Widget _buildPageDokumenMotivasi() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel("Dokumen Pendukung"),
          const SizedBox(height: 8),
          ...dokumenPendukungOptions.map((item) {
            final isSelected = _controller.dokumenPendukung.contains(item);
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Material(
                color: isSelected ? AppColors.blue900 : Colors.white,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _controller.toggleDokumenPendukung(item),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: isSelected ? AppColors.blue900 : AppColors.gray200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CheckboxListTile(
                      value: isSelected,
                      onChanged: (_) => _controller.toggleDokumenPendukung(item),
                      title: Text(
                        item,
                        style: TextStyle(
                          fontSize: 13,
                          color: isSelected ? Colors.white : AppColors.gray700,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      activeColor: Colors.white,
                      checkColor: AppColors.blue900,
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 20),

          _buildLabel("Sudah tahu jurusan/bidang yang ingin diambil?"),
          const SizedBox(height: 8),
          _buildRadioGroup(
            options: kejelasanTujuanOptions,
            selectedValue: _controller.kejelasanTujuan,
            onChanged: _controller.setKejelasanTujuan,
          ),
          const SizedBox(height: 20),

          _buildLabel("Punya rencana karir setelah lulus?"),
          const SizedBox(height: 8),
          _buildRadioGroup(
            options: tujuanKarirOptions,
            selectedValue: _controller.tujuanKarir,
            onChanged: _controller.setTujuanKarir,
          ),
          const SizedBox(height: 20),

          _buildLabel("Pilihan studi sesuai rencana karir?"),
          const SizedBox(height: 8),
          _buildRadioGroup(
            options: keterkaitanOptions,
            selectedValue: _controller.keterkaitan,
            onChanged: _controller.setKeterkaitan,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════
  // PAGE 7: Preferensi Beasiswa
  // ═══════════════════════════════════
  Widget _buildPagePreferensi() {
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
            options: jenisBeasiswaOptions,
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

  // ═══════════════════════════════════
  // REUSABLE MICRO-WIDGETS
  // ═══════════════════════════════════

  Widget _buildLabel(String text) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.blue900),
        children: const [TextSpan(text: ' *', style: TextStyle(color: Colors.red))],
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(label),
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
                width: 16,
                height: 16,
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
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
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

  Widget _buildDropdown({
    required String value,
    required String hint,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.blue300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value.isEmpty ? null : value,
          hint: Text(hint, style: const TextStyle(color: Colors.black38, fontSize: 13)),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.gray400),
          items: options.map((opt) => DropdownMenuItem(
            value: opt,
            child: Text(opt, style: const TextStyle(fontSize: 13)),
          )).toList(),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
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
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Material(
            color: isSelected ? AppColors.blue900 : Colors.white,
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
                    style: TextStyle(
                      fontSize: 13,
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
          color: isSelected ? AppColors.blue900 : Colors.transparent,
          border: Border.all(color: isSelected ? AppColors.blue900 : Colors.black12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
