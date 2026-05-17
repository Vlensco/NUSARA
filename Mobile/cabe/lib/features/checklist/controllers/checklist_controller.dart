import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cabe/core/theme/app_colors.dart';
import 'package:cabe/core/constants/scholarship_ids.dart';

class ChecklistItem {
  final String id;
  final String title;
  final List<ScholarshipTag> tags;
  final String deadline;
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
  FontWeight get titleWeight => isChecked ? FontWeight.w600 : FontWeight.w400;
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

class ChecklistSection {
  final String title;
  final List<ChecklistItem> items;

  const ChecklistSection({required this.title, required this.items});
}

// TEMPLATE DATA (UI-only)
final _dummyChecklist = [
  ChecklistSection(
    title: 'Esai',
    items: [
      ChecklistItem(id: 'e1', title: 'Esai motivasi (500 kata)', tags: [ScholarshipTag(label: 'BUK', colorHex: 0xFF00A47D)], deadline: '24 Juni 2026'),
      ChecklistItem(id: 'e2', title: 'Esai tentang visi pelestarian budaya', tags: [ScholarshipTag(label: 'BSND', colorHex: 0xFF68417E)], deadline: '11 Juni 2026'),
      ChecklistItem(id: 'e3', title: 'Esai tentang semangat inovasi', tags: [ScholarshipTag(label: 'PPT', colorHex: 0xFFB7962A)], deadline: '8 Juni 2026'),
      ChecklistItem(id: 'e4', title: 'Esai rencana studi', tags: [ScholarshipTag(label: 'LPDP', colorHex: 0xFFE63333)], deadline: '14 Juni 2026'),
      ChecklistItem(id: 'e5', title: 'Esai tentang minat di bidang teknologi', tags: [ScholarshipTag(label: 'AI', colorHex: 0xFFA729B3)], deadline: '2 Juni 2026'),
      ChecklistItem(id: 'e6', title: 'Esai kepemimpinan dan kontribusi sosial', tags: [ScholarshipTag(label: 'TF', colorHex: 0xFF4AD743)], deadline: '8 Juni 2026'),
    ],
  ),
  ChecklistSection(
    title: 'Video / Foto Dokumentasi',
    items: [
      ChecklistItem(id: 'v1', title: 'Pas foto 3x4', tags: [ScholarshipTag(label: 'BUK', colorHex: 0xFF00A47D)], deadline: '23 Juni 2026'),
      ChecklistItem(id: 'v2', title: 'Foto aksi olahraga', tags: [ScholarshipTag(label: 'BAPK', colorHex: 0xFFFE4820)], deadline: '27 Juni 2026'),
      ChecklistItem(id: 'v3', title: 'Video penampilan seni (5 menit)', tags: [ScholarshipTag(label: 'BSND', colorHex: 0xFF68417E)], deadline: '11 Juni 2026'),
      ChecklistItem(id: 'v4', title: 'Dokumentasi proyek / usaha (jika ada)', tags: [ScholarshipTag(label: 'PPT', colorHex: 0xFFB7962A)], deadline: '8 Juni 2026'),
      ChecklistItem(id: 'v5', title: 'Video perkenalan (3 menit)', tags: [ScholarshipTag(label: 'TF', colorHex: 0xFF4AD743)], deadline: '8 Juni 2026'),
    ],
  ),
  ChecklistSection(
    title: 'Dokumen',
    items: [
      ChecklistItem(id: 'd1', title: 'Fotokopi Rapor / Transkrip Nilai', tags: [
        ScholarshipTag(label: 'BUK', colorHex: 0xFF00A47D), ScholarshipTag(label: 'BAPK', colorHex: 0xFFFE4820),
        ScholarshipTag(label: 'BSND', colorHex: 0xFF68417E), ScholarshipTag(label: 'PPT', colorHex: 0xFFB7962A),
        ScholarshipTag(label: 'LPDP', colorHex: 0xFFE63333), ScholarshipTag(label: 'AI', colorHex: 0xFFA729B3),
        ScholarshipTag(label: 'TF', colorHex: 0xFF4AD743),
      ], deadline: '2 Mei 2026'),
      ChecklistItem(id: 'd2', title: 'Fotokopi KTP / Kartu Pelajar', tags: [
        ScholarshipTag(label: 'BUK', colorHex: 0xFF00A47D), ScholarshipTag(label: 'LPDP', colorHex: 0xFFE63333),
        ScholarshipTag(label: 'AI', colorHex: 0xFFA729B3),
      ], deadline: '9 Juni 2026'),
      ChecklistItem(id: 'd3', title: 'Surat rekomendasi kepala sekolah', tags: [
        ScholarshipTag(label: 'BUK', colorHex: 0xFF00A47D), ScholarshipTag(label: 'AI', colorHex: 0xFFA729B3),
      ], deadline: '17 Juni 2026'),
      ChecklistItem(id: 'd4', title: 'Surat rekomendasi umum / dosen', tags: [
        ScholarshipTag(label: 'PPT', colorHex: 0xFFB7962A), ScholarshipTag(label: 'TF', colorHex: 0xFF4AD743),
      ], deadline: '17 Juni 2026'),
      ChecklistItem(id: 'd5', title: 'Surat rekomendasi KONI daerah', tags: [ScholarshipTag(label: 'BAPK', colorHex: 0xFFFE4820)], deadline: '17 Juni 2026'),
      ChecklistItem(id: 'd6', title: 'Sertifikat Prestasi / Medali Kejuaraan', tags: [
        ScholarshipTag(label: 'BUK', colorHex: 0xFF00A47D), ScholarshipTag(label: 'BAPK', colorHex: 0xFFFE4820),
        ScholarshipTag(label: 'BSND', colorHex: 0xFF68417E),
      ], deadline: '18 Juni 2026'),
      ChecklistItem(id: 'd7', title: 'CV / daftar riwayat hidup', tags: [
        ScholarshipTag(label: 'LPDP', colorHex: 0xFFE63333), ScholarshipTag(label: 'AI', colorHex: 0xFFA729B3),
      ], deadline: '16 Juni 2026'),
      ChecklistItem(id: 'd8', title: 'Surat keterangan sehat', tags: [ScholarshipTag(label: 'LPDP', colorHex: 0xFFE63333)], deadline: '7 Juni 2026'),
      ChecklistItem(id: 'd9', title: 'SKCK', tags: [ScholarshipTag(label: 'LPDP', colorHex: 0xFFE63333)], deadline: '7 Juni 2026'),
      ChecklistItem(id: 'd10', title: 'Riwayat prestasi olahraga', tags: [ScholarshipTag(label: 'BAPK', colorHex: 0xFFFE4820)], deadline: '31 Juni 2026'),
      ChecklistItem(id: 'd11', title: 'Portofolio karya seni', tags: [ScholarshipTag(label: 'BSND', colorHex: 0xFF68417E)], deadline: '11 Juni 2026'),
      ChecklistItem(id: 'd12', title: 'Proposal ide bisnis / proyek', tags: [ScholarshipTag(label: 'PPT', colorHex: 0xFFB7962A)], deadline: '8 Juni 2026'),
      ChecklistItem(id: 'd13', title: 'Formulir pendaftaran', tags: [ScholarshipTag(label: 'TF', colorHex: 0xFF4AD743)], deadline: '8 Juni 2026'),
    ],
  ),
];

// CHECKLIST NOTIFIER (Firestore sync)
class ChecklistNotifier extends Notifier<List<ChecklistSection>> {
  final Set<String> _toastedAcronyms = {};

  @override
  List<ChecklistSection> build() {
    _loadCheckedStateFromDb();
    return _dummyChecklist;
  }

  bool hasBeenToasted(String acronym) => _toastedAcronyms.contains(acronym);
  void markAsToasted(String acronym) { _toastedAcronyms.add(acronym); }
  void unmarkAsToasted(String acronym) { _toastedAcronyms.remove(acronym); }

  /// Load checked state 
  Future<void> _loadCheckedStateFromDb() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      // Ambil semua progress user
      final progressSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('scholarship_progress')
          .get();

      if (progressSnapshot.docs.isEmpty) return;

      final Set<String> completedDocs = {};

      // Untuk setiap progress, ambil checklists yang completed
      for (final progressDoc in progressSnapshot.docs) {
        final checklistSnapshot = await progressDoc.reference
            .collection('checklists')
            .where('is_completed', isEqualTo: true)
            .get();

        for (final doc in checklistSnapshot.docs) {
          final docName = doc.data()['document_name'] as String?;
          if (docName != null) completedDocs.add(docName);
        }
      }

      if (completedDocs.isEmpty) return;

      // Update local state
      state = state.map((section) {
        return ChecklistSection(
          title: section.title,
          items: section.items.map((item) {
            if (completedDocs.contains(item.title)) {
              return item.copyWith(isChecked: true);
            }
            return item;
          }).toList(),
        );
      }).toList();
    } catch (e) {
      debugPrint('Error loading checklist from DB: $e');
    }
  }

  void toggleItem(String itemId) {
    // Find the item first
    ChecklistItem? targetItem;
    for (final section in state) {
      for (final item in section.items) {
        if (item.id == itemId) {
          targetItem = item;
          break;
        }
      }
    }

    if (targetItem == null) return;
    final newChecked = !targetItem.isChecked;

    // Update local state
    state = state.map((section) {
      return ChecklistSection(
        title: section.title,
        items: section.items.map((item) {
          if (item.id == itemId) return item.copyWith(isChecked: newChecked);
          return item;
        }).toList(),
      );
    }).toList();

    // Sync ke Firestore
    _syncChecklistToDb(targetItem.title, newChecked, targetItem.tags);
  }

  Future<void> _syncChecklistToDb(String documentName, bool isCompleted, List<ScholarshipTag> tags) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Untuk setiap scholarship yang terkait (via tag acronym)
      for (final tag in tags) {
        final scholarshipId = ScholarshipIds.getId(tag.label);
        if (scholarshipId == null) continue;

        final progressRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('scholarship_progress')
            .doc(scholarshipId);

        // Cek apakah progress ada
        final progressDoc = await progressRef.get();
        if (!progressDoc.exists) continue;

        // Gunakan document_name yang di-encode sebagai document ID
        final checklistDocId = documentName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
        final checklistRef = progressRef.collection('checklists').doc(checklistDocId);

        await checklistRef.set({
          'document_name': documentName,
          'is_completed': isCompleted,
          'updated_at': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Error syncing checklist to DB: $e');
    }
  }

  int get totalItems => state.fold(0, (sum, s) => sum + s.items.length);
  int get checkedItems =>
      state.fold(0, (sum, s) => sum + s.items.where((i) => i.isChecked).length);
}

final checklistProvider =
    NotifierProvider<ChecklistNotifier, List<ChecklistSection>>(
  ChecklistNotifier.new,
);

// FILTER & APPLIED PROVIDERS
class ChecklistFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setFilter(String? acronym) { state = acronym; }
}

final checklistFilterProvider = NotifierProvider<ChecklistFilterNotifier, String?>(
  ChecklistFilterNotifier.new,
);

class AppliedScholarshipsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    _loadFromDb();
    return {};
  }

  /// Load applied scholarships dari Firestore scholarship_progress subcollection
  Future<void> _loadFromDb() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('scholarship_progress')
          .get();

      final appliedAcronyms = <String>{};
      for (final doc in snapshot.docs) {
        final acronym = ScholarshipIds.getAcronym(doc.id);
        if (acronym != null) {
          appliedAcronyms.add(acronym);
        }
      }

      if (appliedAcronyms.isNotEmpty) {
        state = appliedAcronyms;
      }
    } catch (e) {
      debugPrint('Error loading applied scholarships: $e');
    }
  }

  Future<void> add(String acronym) async {
    state = {...state, acronym};

    // Insert ke Firestore scholarship_progress
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final scholarshipId = ScholarshipIds.getId(acronym);
      if (scholarshipId == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('scholarship_progress')
          .doc(scholarshipId)
          .set({
        'scholarship_id': scholarshipId,
        'status': 'Persiapan',
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving applied scholarship: $e');
    }
  }
}

final appliedScholarshipsProvider = NotifierProvider<AppliedScholarshipsNotifier, Set<String>>(
  AppliedScholarshipsNotifier.new,
);

/// Mendapatkan acronym dari scholarship ID (UUID)
String? getAcronymForScholarshipId(String id) => ScholarshipIds.getAcronym(id);

// VIEW STATE PROVIDERS
class ChecklistViewState {
  final List<ChecklistSection> sections;
  final int total;
  final int checked;
  final double progress;
  final bool isAllCompleted;

  ChecklistViewState({
    required this.sections,
    required this.total,
    required this.checked,
    required this.progress,
    required this.isAllCompleted,
  });
}

final checklistViewProvider = Provider<ChecklistViewState>((ref) {
  final rawSections = ref.watch(checklistProvider);
  final filter = ref.watch(checklistFilterProvider);
  final applied = ref.watch(appliedScholarshipsProvider);

  List<ChecklistSection> sections = rawSections;
  if (filter != null) {
    sections = rawSections.map((section) {
      return ChecklistSection(
        title: section.title,
        items: section.items
            .where((item) => item.tags.any((tag) => tag.label == filter))
            .map((item) => item.copyWith(
                  tags: item.tags.where((tag) => applied.contains(tag.label)).toList(),
                ))
            .toList(),
      );
    }).where((section) => section.items.isNotEmpty).toList();
  } else {
    sections = rawSections.map((section) {
      return ChecklistSection(
        title: section.title,
        items: section.items
            .where((item) => item.tags.any((tag) => applied.contains(tag.label)))
            .map((item) => item.copyWith(
                  tags: item.tags.where((tag) => applied.contains(tag.label)).toList(),
                ))
            .toList(),
      );
    }).where((section) => section.items.isNotEmpty).toList();
  }

  final total = sections.fold(0, (sum, s) => sum + s.items.length);
  final checked = sections.fold(0, (sum, s) => sum + s.items.where((i) => i.isChecked).length);
  final progress = total == 0 ? 0.0 : checked / total;
  final isAllCompleted = total > 0 && progress >= 1.0;

  return ChecklistViewState(
    sections: sections,
    total: total,
    checked: checked,
    progress: progress,
    isAllCompleted: isAllCompleted,
  );
});

final completedScholarshipsProvider = Provider<List<String>>((ref) {
  final rawSections = ref.watch(checklistProvider);
  final applied = ref.watch(appliedScholarshipsProvider);
  final completed = <String>[];

  for (final acronym in applied) {
    int total = 0;
    int checked = 0;
    
    for (final section in rawSections) {
      for (final item in section.items) {
        if (item.tags.any((tag) => tag.label == acronym)) {
          total++;
          if (item.isChecked) checked++;
        }
      }
    }
    
    if (total > 0 && checked == total) {
      completed.add(acronym);
    }
  }
  
  return completed;
});
