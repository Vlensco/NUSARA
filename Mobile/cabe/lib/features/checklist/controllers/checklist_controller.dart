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

  ChecklistItem copyWith({bool? isChecked, List<ScholarshipTag>? tags}) {
    return ChecklistItem(
      id: id,
      title: title,
      tags: tags ?? this.tags,
      deadline: deadline,
      isChecked: isChecked ?? this.isChecked,
    );
  }
  Color get titleColor => isChecked ? AppColors.gray900 : AppColors.gray500;

  FontWeight get titleWeight =>
      isChecked ? FontWeight.w600 : FontWeight.w400;

  Border? get cardBorder => isChecked
      ? null
      : Border.all(color: AppColors.coolGray200, width: 1);
}

class ScholarshipTag {
  final String label;
  final int colorHex;

  const ScholarshipTag({required this.label, required this.colorHex});

  Color get vividColor => Color(colorHex | 0xFF000000);

  Color tagColor({required bool isItemChecked}) => vividColor;
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
        title: 'Esai motivasi (500 kata)',
        tags: [ScholarshipTag(label: 'BUK', colorHex: 0xFF00A47D)],
        deadline: '24 Juni 2026',
      ),
      ChecklistItem(
        id: 'e2',
        title: 'Esai tentang visi pelestarian budaya',
        tags: [ScholarshipTag(label: 'BSND', colorHex: 0xFF68417E)],
        deadline: '11 Juni 2026',
      ),
      ChecklistItem(
        id: 'e3',
        title: 'Esai tentang semangat inovasi',
        tags: [ScholarshipTag(label: 'PPT', colorHex: 0xFFB7962A)],
        deadline: '8 Juni 2026',
      ),
      ChecklistItem(
        id: 'e4',
        title: 'Esai rencana studi',
        tags: [ScholarshipTag(label: 'LPDP', colorHex: 0xFFE63333)],
        deadline: '14 Juni 2026',
      ),
      ChecklistItem(
        id: 'e5',
        title: 'Esai tentang minat di bidang teknologi',
        tags: [ScholarshipTag(label: 'AI', colorHex: 0xFFA729B3)],
        deadline: '2 Juni 2026',
      ),
      ChecklistItem(
        id: 'e6',
        title: 'Esai kepemimpinan dan kontribusi sosial',
        tags: [ScholarshipTag(label: 'TF', colorHex: 0xFF4AD743)],
        deadline: '8 Juni 2026',
      ),
    ],
  ),
  ChecklistSection(
    title: 'Video / Foto Dokumentasi',
    items: [
      ChecklistItem(
        id: 'v1',
        title: 'Pas foto 3x4',
        tags: [ScholarshipTag(label: 'BUK', colorHex: 0xFF00A47D)],
        deadline: '23 Juni 2026',
      ),
      ChecklistItem(
        id: 'v2',
        title: 'Foto aksi olahraga',
        tags: [ScholarshipTag(label: 'BAPK', colorHex: 0xFFFE4820)],
        deadline: '27 Juni 2026',
      ),
      ChecklistItem(
        id: 'v3',
        title: 'Video penampilan seni (5 menit)',
        tags: [ScholarshipTag(label: 'BSND', colorHex: 0xFF68417E)],
        deadline: '11 Juni 2026',
      ),
      ChecklistItem(
        id: 'v4',
        title: 'Dokumentasi proyek / usaha (jika ada)',
        tags: [ScholarshipTag(label: 'PPT', colorHex: 0xFFB7962A)],
        deadline: '8 Juni 2026',
      ),
      ChecklistItem(
        id: 'v5',
        title: 'Video perkenalan (3 menit)',
        tags: [ScholarshipTag(label: 'TF', colorHex: 0xFF4AD743)],
        deadline: '8 Juni 2026',
      ),
    ],
  ),
  ChecklistSection(
    title: 'Dokumen',
    items: [
      ChecklistItem(
        id: 'd1',
        title: 'Fotokopi Rapor / Transkrip Nilai',
        tags: [
          ScholarshipTag(label: 'BUK', colorHex: 0xFF00A47D),
          ScholarshipTag(label: 'BAPK', colorHex: 0xFFFE4820),
          ScholarshipTag(label: 'BSND', colorHex: 0xFF68417E),
          ScholarshipTag(label: 'PPT', colorHex: 0xFFB7962A),
          ScholarshipTag(label: 'LPDP', colorHex: 0xFFE63333),
          ScholarshipTag(label: 'AI', colorHex: 0xFFA729B3),
          ScholarshipTag(label: 'TF', colorHex: 0xFF4AD743),
        ],
        deadline: '2 Mei 2026',
      ),
      ChecklistItem(
        id: 'd2',
        title: 'Fotokopi KTP / Kartu Pelajar',
        tags: [
          ScholarshipTag(label: 'BUK', colorHex: 0xFF00A47D),
          ScholarshipTag(label: 'LPDP', colorHex: 0xFFE63333),
          ScholarshipTag(label: 'AI', colorHex: 0xFFA729B3),
        ],
        deadline: '9 Juni 2026',
      ),
      ChecklistItem(
        id: 'd3',
        title: 'Surat rekomendasi kepala sekolah',
        tags: [
          ScholarshipTag(label: 'BUK', colorHex: 0xFF00A47D),
          ScholarshipTag(label: 'AI', colorHex: 0xFFA729B3),
        ],
        deadline: '17 Juni 2026',
      ),
      ChecklistItem(
        id: 'd4',
        title: 'Surat rekomendasi umum / dosen',
        tags: [
          ScholarshipTag(label: 'PPT', colorHex: 0xFFB7962A),
          ScholarshipTag(label: 'TF', colorHex: 0xFF4AD743),
        ],
        deadline: '17 Juni 2026',
      ),
      ChecklistItem(
        id: 'd5',
        title: 'Surat rekomendasi KONI daerah',
        tags: [ScholarshipTag(label: 'BAPK', colorHex: 0xFFFE4820)],
        deadline: '17 Juni 2026',
      ),
      ChecklistItem(
        id: 'd6',
        title: 'Sertifikat Prestasi / Medali Kejuaraan',
        tags: [
          ScholarshipTag(label: 'BUK', colorHex: 0xFF00A47D),
          ScholarshipTag(label: 'BAPK', colorHex: 0xFFFE4820),
          ScholarshipTag(label: 'BSND', colorHex: 0xFF68417E),
        ],
        deadline: '18 Juni 2026',
      ),
      ChecklistItem(
        id: 'd7',
        title: 'CV / daftar riwayat hidup',
        tags: [
          ScholarshipTag(label: 'LPDP', colorHex: 0xFFE63333),
          ScholarshipTag(label: 'AI', colorHex: 0xFFA729B3),
        ],
        deadline: '16 Juni 2026',
      ),
      ChecklistItem(
        id: 'd8',
        title: 'Surat keterangan sehat',
        tags: [ScholarshipTag(label: 'LPDP', colorHex: 0xFFE63333)],
        deadline: '7 Juni 2026',
      ),
      ChecklistItem(
        id: 'd9',
        title: 'SKCK',
        tags: [ScholarshipTag(label: 'LPDP', colorHex: 0xFFE63333)],
        deadline: '7 Juni 2026',
      ),
      ChecklistItem(
        id: 'd10',
        title: 'Riwayat prestasi olahraga',
        tags: [ScholarshipTag(label: 'BAPK', colorHex: 0xFFFE4820)],
        deadline: '31 Juni 2026',
      ),
      ChecklistItem(
        id: 'd11',
        title: 'Portofolio karya seni',
        tags: [ScholarshipTag(label: 'BSND', colorHex: 0xFF68417E)],
        deadline: '11 Juni 2026',
      ),
      ChecklistItem(
        id: 'd12',
        title: 'Proposal ide bisnis / proyek',
        tags: [ScholarshipTag(label: 'PPT', colorHex: 0xFFB7962A)],
        deadline: '8 Juni 2026',
      ),
      ChecklistItem(
        id: 'd13',
        title: 'Formulir pendaftaran',
        tags: [ScholarshipTag(label: 'TF', colorHex: 0xFF4AD743)],
        deadline: '8 Juni 2026',
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

class ChecklistFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setFilter(String? acronym) {
    state = acronym;
  }
}

final checklistFilterProvider = NotifierProvider<ChecklistFilterNotifier, String?>(
  ChecklistFilterNotifier.new,
);

class AppliedScholarshipsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void add(String acronym) {
    state = {...state, acronym};
  }
}

final appliedScholarshipsProvider = NotifierProvider<AppliedScholarshipsNotifier, Set<String>>(
  AppliedScholarshipsNotifier.new,
);

String? getAcronymForScholarshipId(String id) {
  switch (id) {
    case '1': return 'BUK';
    case '2': return 'BAPK';
    case '3': return 'BSND';
    case '4': return 'PPT';
    case '5': return 'LPDP';
    case '6': return 'AI';
    case '7': return 'TF';
    default: return null;
  }
}
