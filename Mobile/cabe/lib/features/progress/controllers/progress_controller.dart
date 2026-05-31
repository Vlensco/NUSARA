import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cabe/core/theme/app_colors.dart';
import 'package:cabe/core/constants/scholarship_ids.dart';
import 'package:cabe/features/checklist/controllers/checklist_controller.dart';
import 'package:cabe/features/scholarships/providers/scholarship_provider.dart';
import 'package:easy_localization/easy_localization.dart';

// ENUMS & MODELS
enum ProgressStatus { tersimpan, ditinjau, diterima, ditolak }

class ProgressItem {
  final String id; // acronym (BUK, BAPK, etc.)
  final String title;
  final ProgressStatus status;
  final int? docsUploaded;
  final int? docsTotal;
  final bool isApplied;

  const ProgressItem({
    required this.id,
    required this.title,
    required this.status,
    this.docsUploaded,
    this.docsTotal,
    this.isApplied = true,
  });

  ProgressItem copyWith({ProgressStatus? status, int? docsUploaded, int? docsTotal, bool? isApplied}) {
    return ProgressItem(
      id: id,
      title: title,
      status: status ?? this.status,
      docsUploaded: docsUploaded ?? this.docsUploaded,
      docsTotal: docsTotal ?? this.docsTotal,
      isApplied: isApplied ?? this.isApplied,
    );
  }

  String get subtitle {
    switch (status) {
      case ProgressStatus.tersimpan:
        if (!isApplied) return 'progress.sub_saved_unapplied'.tr();
        return 'progress.sub_saved_applied'.tr(args: [
          (docsUploaded ?? 0).toString(),
          (docsTotal ?? 0).toString(),
        ]);
      case ProgressStatus.ditinjau:
        return 'progress.sub_review'.tr();
      case ProgressStatus.diterima:
        return 'progress.sub_accepted'.tr();
      case ProgressStatus.ditolak:
        return 'progress.sub_rejected'.tr();
    }
  }

  Color get subtitleColor {
    switch (status) {
      case ProgressStatus.tersimpan: return AppColors.dangerText;
      case ProgressStatus.ditinjau: return AppColors.warningText;
      case ProgressStatus.diterima: return AppColors.successText;
      case ProgressStatus.ditolak: return AppColors.dangerText;
    }
  }

  bool get showChevron => status == ProgressStatus.diterima || status == ProgressStatus.ditinjau;
  bool get showAlert => status == ProgressStatus.tersimpan;
  bool get showReject => status == ProgressStatus.ditolak;
}

enum ProgressFilter { semua, tersimpan, ditinjau, diterima, ditolak }

extension ProgressFilterLabel on ProgressFilter {
  String get label {
    switch (this) {
      case ProgressFilter.semua: return 'progress.filter_all'.tr();
      case ProgressFilter.tersimpan: return 'progress.filter_saved'.tr();
      case ProgressFilter.ditinjau: return 'progress.filter_under_review'.tr();
      case ProgressFilter.diterima: return 'progress.filter_accepted'.tr();
      case ProgressFilter.ditolak: return 'progress.filter_rejected'.tr();
    }
  }
}

// STATE
class ProgressState {
  final List<ProgressItem> items;
  final ProgressFilter activeFilter;

  const ProgressState({
    required this.items,
    this.activeFilter = ProgressFilter.semua,
  });

  List<ProgressItem> get filteredItems {
    if (activeFilter == ProgressFilter.semua) return items;
    final targetStatus = ProgressStatus.values.firstWhere(
      (s) => s.name == activeFilter.name,
    );
    return items.where((item) => item.status == targetStatus).toList();
  }

  ProgressState copyWith({List<ProgressItem>? items, ProgressFilter? activeFilter}) {
    return ProgressState(
      items: items ?? this.items,
      activeFilter: activeFilter ?? this.activeFilter,
    );
  }
}

// MAPPING
const _acronymToTitle = {
  'BUK': 'Beasiswa Unggulan Kemendikbud',
  'BAPK': 'Beasiswa Atlet Berprestasi KONI',
  'BSND': 'Beasiswa Seni Budaya Nusantara',
  'PPT': 'Paragon for Future Leaders',
  'LPDP': 'LPDP Beasiswa Reguler',
  'AI': 'Beasiswa Astra 1st',
  'TF': 'TELADAN - Tanoto Foundation',
};

ProgressStatus _parseStatus(String? dbStatus) {
  switch (dbStatus) {
    case 'Ditinjau': return ProgressStatus.ditinjau;
    case 'Diterima': return ProgressStatus.diterima;
    case 'Ditolak': return ProgressStatus.ditolak;
    default: return ProgressStatus.tersimpan;
  }
}

String _statusToDb(ProgressStatus status) {
  switch (status) {
    case ProgressStatus.tersimpan: return 'Persiapan';
    case ProgressStatus.ditinjau: return 'Ditinjau';
    case ProgressStatus.diterima: return 'Diterima';
    case ProgressStatus.ditolak: return 'Ditolak';
  }
}

// NOTIFIER (Supabase integrated)
class ProgressNotifier extends Notifier<ProgressState> {
  // Menyimpan status manual + status dari DB
  final Map<String, ProgressStatus> _dbStatuses = {};

  @override
  ProgressState build() {
    final applied = ref.watch(appliedScholarshipsProvider);
    final checklistSections = ref.watch(checklistProvider);
    final allScholarships = ref.watch(scholarshipProvider);

    // Load status dari DB saat pertama kali
    _loadProgressFromDb();

    final Set<String> allAcronyms = {...applied};

    // Tambahkan beasiswa yang isSaved == true
    for (final s in allScholarships) {
      if (s.isSaved) {
        final acronym = ScholarshipIds.getAcronym(s.id);
        if (acronym != null) allAcronyms.add(acronym);
      }
    }

    final items = allAcronyms.map((acronym) {
      final title = _acronymToTitle[acronym] ?? acronym;

      int totalDocs = 0;
      int checkedDocs = 0;
      for (final section in checklistSections) {
        for (final item in section.items) {
          if (item.tags.any((tag) => tag.label == acronym)) {
            totalDocs++;
            if (item.isChecked) checkedDocs++;
          }
        }
      }

      // Gunakan status dari DB jika ada
      if (_dbStatuses.containsKey(acronym)) {
        return ProgressItem(
          id: acronym,
          title: title,
          status: _dbStatuses[acronym]!,
          docsUploaded: checkedDocs,
          docsTotal: totalDocs,
          isApplied: applied.contains(acronym),
        );
      }

      // Auto-determine status
      ProgressStatus status;
      if (totalDocs > 0 && checkedDocs == totalDocs) {
        status = ProgressStatus.ditinjau;
      } else {
        status = ProgressStatus.tersimpan;
      }

      return ProgressItem(
        id: acronym,
        title: title,
        status: status,
        docsUploaded: checkedDocs,
        docsTotal: totalDocs,
        isApplied: applied.contains(acronym),
      );
    }).toList();

    ProgressFilter currentFilter;
    try {
      currentFilter = state.activeFilter;
    } catch (_) {
      currentFilter = ProgressFilter.semua;
    }

    return ProgressState(items: items, activeFilter: currentFilter);
  }

  Future<void> _loadProgressFromDb() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('scholarship_progress')
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final acronym = ScholarshipIds.getAcronym(doc.id);
        if (acronym != null) {
          final status = _parseStatus(data['status'] as String?);
          // Hanya override jika statusnya bukan default (Persiapan)
          if (data['status'] != 'Persiapan') {
            _dbStatuses[acronym] = status;
          }
        }
      }

      // Rebuild state setelah data dimuat
      ref.invalidateSelf();
    } catch (e) {
      debugPrint('Error loading progress from DB: $e');
    }
  }

  void setFilter(ProgressFilter filter) {
    state = state.copyWith(activeFilter: filter);
  }

  Future<void> updateStatus(String itemId, ProgressStatus newStatus) async {
    _dbStatuses[itemId] = newStatus;
    ref.invalidateSelf();

    // Sync ke Firestore
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final scholarshipId = ScholarshipIds.getId(itemId);
      if (scholarshipId == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('scholarship_progress')
          .doc(scholarshipId)
          .update({
            'status': _statusToDb(newStatus),
            'updated_at': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      debugPrint('Error updating progress status: $e');
    }
  }
}

final progressProvider = NotifierProvider<ProgressNotifier, ProgressState>(
  ProgressNotifier.new,
);
