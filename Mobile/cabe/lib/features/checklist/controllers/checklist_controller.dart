import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cabe/core/theme/app_colors.dart';

// Model untuk setiap item checklist
class ChecklistItem {
  final String id;
  final String title;
  final List<ScholarshipTag> tags;
  final String deadline; // Format: "2 Juni 2026"
  final bool isChecked;

  const ChecklistItem({
    required this.id,
    required this.title,
    required this.tags,
    required this.deadline,
    this.isChecked = false,
  });

  ChecklistItem copyWith({bool? isChecked}) {
    return ChecklistItem(
      id: id,
      title: title,
      tags: tags,
      deadline: deadline,
      isChecked: isChecked ?? this.isChecked,
    );
  }

  // ─── COMPUTED DISPLAY PROPERTIES ────────────────────────────────────────────
  // Semua logika tampilan ada di sini, widget cukup pakai properti ini.

  /// Warna teks judul item
  Color get titleColor => isChecked ? AppColors.gray900 : AppColors.gray500;

  /// Ketebalan teks judul item
  FontWeight get titleWeight =>
      isChecked ? FontWeight.w600 : FontWeight.w400;

  /// Warna border card
  Border? get cardBorder => isChecked
      ? null
      : Border.all(color: AppColors.coolGray200, width: 1);
}

// Model untuk tag beasiswa (label singkatan berwarna)
class ScholarshipTag {
  final String label;
  final int colorHex; // Hex warna background tag

  const ScholarshipTag({required this.label, required this.colorHex});

  // ─── COMPUTED DISPLAY PROPERTIES ────────────────────────────────────────────

  /// Warna vivid penuh (alpha selalu 0xFF)
  Color get vividColor => Color(colorHex | 0xFF000000);

  /// Warna tag: vivid saat item sudah dicentang, abu-abu saat belum
  Color tagColor({required bool isItemChecked}) =>
      isItemChecked ? vividColor : AppColors.coolGray400;
}

// Model untuk satu grup/section (misal: Esai, Dokumen, Video)
class ChecklistSection {
  final String title;
  final List<ChecklistItem> items;

  const ChecklistSection({required this.title, required this.items});
}

// --- DATA DUMMY ---
final _dummyChecklist = [
  ChecklistSection(
    title: 'Esai',
    items: [
      ChecklistItem(
        id: 'e1',
        title: 'Esai Kepemimpinan',
        tags: [ScholarshipTag(label: 'AI', colorHex: 0xFF6C63FF)],
        deadline: '2 Juni 2026',
        isChecked: true,
      ),
      ChecklistItem(
        id: 'e2',
        title: 'Esai tentang semangat Inovasi',
        tags: [ScholarshipTag(label: 'TF', colorHex: 0xFF2196F3)],
        deadline: '8 Juni 2026',
        isChecked: false,
      ),
      ChecklistItem(
        id: 'e3',
        title: 'Esai tentang literasi keuangan',
        tags: [ScholarshipTag(label: 'AI', colorHex: 0xFF6C63FF)],
        deadline: '14 Juni 2026',
        isChecked: true,
      ),
      ChecklistItem(
        id: 'e4',
        title: 'Esai Motivasi',
        tags: [ScholarshipTag(label: 'LPDP', colorHex: 0xFF607D8B)],
        deadline: '24 Juni 2026',
        isChecked: false,
      ),
    ],
  ),
  ChecklistSection(
    title: 'Video / Foto Dokumentasi',
    items: [
      ChecklistItem(
        id: 'v1',
        title: 'Dokumentasi Kegiatan Sosial',
        tags: [ScholarshipTag(label: 'BSND', colorHex: 0xFF009688)],
        deadline: '6 Juni 2026',
        isChecked: false,
      ),
      ChecklistItem(
        id: 'v2',
        title: 'Video Perkenalan (3 menit)',
        tags: [ScholarshipTag(label: 'BSND', colorHex: 0xFF009688)],
        deadline: '11 Juni 2026',
        isChecked: false,
      ),
      ChecklistItem(
        id: 'v3',
        title: 'Pas Foto',
        tags: [
          ScholarshipTag(label: 'BSND', colorHex: 0xFF009688),
          ScholarshipTag(label: 'TF', colorHex: 0xFF2196F3),
          ScholarshipTag(label: 'AI', colorHex: 0xFF6C63FF),
        ],
        deadline: '23 Juni 2026',
        isChecked: true,
      ),
      ChecklistItem(
        id: 'v4',
        title: 'Foto Aksi Olahraga',
        tags: [ScholarshipTag(label: 'BAPK', colorHex: 0xFFE53935)],
        deadline: '27 Juni 2026',
        isChecked: true,
      ),
    ],
  ),
  ChecklistSection(
    title: 'Dokumen',
    items: [
      ChecklistItem(
        id: 'd1',
        title: 'Surat Keterangan Tidak Mampu',
        tags: [
          ScholarshipTag(label: 'LPDP', colorHex: 0xFF607D8B),
          ScholarshipTag(label: 'TF', colorHex: 0xFF2196F3),
        ],
        deadline: '7 Juni 2026',
        isChecked: false,
      ),
      ChecklistItem(
        id: 'd2',
        title: 'Portofolio Kegiatan Sosial',
        tags: [ScholarshipTag(label: 'TF', colorHex: 0xFF2196F3)],
        deadline: '7 Juni 2026',
        isChecked: false,
      ),
      ChecklistItem(
        id: 'd3',
        title: 'Fotokopi Kartu Pelajar',
        tags: [ScholarshipTag(label: 'BAPK', colorHex: 0xFFE53935)],
        deadline: '9 Juni 2026',
        isChecked: false,
      ),
      ChecklistItem(
        id: 'd4',
        title: 'Fotokopi Kartu Keluarga',
        tags: [ScholarshipTag(label: 'BLK', colorHex: 0xFF795548)],
        deadline: '9 Juni 2026',
        isChecked: false,
      ),
      ChecklistItem(
        id: 'd5',
        title: 'Sertifikasi IELTS',
        tags: [
          ScholarshipTag(label: 'BLK', colorHex: 0xFF795548),
          ScholarshipTag(label: 'AI', colorHex: 0xFF6C63FF),
          ScholarshipTag(label: 'PPT', colorHex: 0xFFFF9800),
        ],
        deadline: '16 Juni 2026',
        isChecked: false,
      ),
      ChecklistItem(
        id: 'd6',
        title: 'Surat Rekomendasi KONI Daerah',
        tags: [ScholarshipTag(label: 'BAPK', colorHex: 0xFFE53935)],
        deadline: '17 Juni 2026',
        isChecked: false,
      ),
      ChecklistItem(
        id: 'd7',
        title: 'Sertifikat / Medali Juara',
        tags: [ScholarshipTag(label: 'BAPK', colorHex: 0xFFE53935)],
        deadline: '18 Juni 2026',
        isChecked: false,
      ),
      ChecklistItem(
        id: 'd8',
        title: 'Riwayat Prestasi Olahraga',
        tags: [
          ScholarshipTag(label: 'BAPK', colorHex: 0xFFE53935),
          ScholarshipTag(label: 'PPT', colorHex: 0xFFFF9800),
        ],
        deadline: '31 Juni 2026',
        isChecked: false,
      ),
      ChecklistItem(
        id: 'd9',
        title: 'Fotokopi Rapor',
        tags: [
          ScholarshipTag(label: 'LPDP', colorHex: 0xFF607D8B),
          ScholarshipTag(label: 'BLK', colorHex: 0xFF795548),
        ],
        deadline: '2 Mei 2026',
        isChecked: false,
      ),
    ],
  ),
];

class ChecklistNotifier extends Notifier<List<ChecklistSection>> {
  @override
  List<ChecklistSection> build() => _dummyChecklist;

  void toggleItem(String itemId) {
    state = state.map((section) {
      return ChecklistSection(
        title: section.title,
        items: section.items.map((item) {
          if (item.id == itemId) return item.copyWith(isChecked: !item.isChecked);
          return item;
        }).toList(),
      );
    }).toList();
  }

  int get totalItems => state.fold(0, (sum, s) => sum + s.items.length);
  int get checkedItems =>
      state.fold(0, (sum, s) => sum + s.items.where((i) => i.isChecked).length);
}

final checklistProvider =
    NotifierProvider<ChecklistNotifier, List<ChecklistSection>>(
  ChecklistNotifier.new,
);
