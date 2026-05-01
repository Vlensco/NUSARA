import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cabe/core/theme/app_colors.dart';
import 'package:cabe/features/checklist/controllers/checklist_controller.dart';

// ENUM STATUS 
enum ProgressStatus { tersimpan, ditinjau, diterima, ditolak }

// MODEL
class ProgressItem {
  final String id;
  final String title;
  final ProgressStatus status;
  // Khusus status tersimpan: berapa dokumen kurang
  final int? docsUploaded;
  final int? docsTotal;

  const ProgressItem({
    required this.id,
    required this.title,
    required this.status,
    this.docsUploaded,
    this.docsTotal,
  });

  ProgressItem copyWith({ProgressStatus? status, int? docsUploaded, int? docsTotal}) {
    return ProgressItem(
      id: id,
      title: title,
      status: status ?? this.status,
      docsUploaded: docsUploaded ?? this.docsUploaded,
      docsTotal: docsTotal ?? this.docsTotal,
    );
  }

  // ─── COMPUTED DISPLAY PROPERTIES ───────────────────────────────────────────

  /// Teks subtitle sesuai status
  String get subtitle {
    switch (status) {
      case ProgressStatus.tersimpan:
        return 'Dokumen masih kurang ${docsUploaded ?? 0}/${docsTotal ?? 0}! Segera lengkapi';
      case ProgressStatus.ditinjau:
        return 'Dokumen dalam tahap peninjauan!';
      case ProgressStatus.diterima:
        return 'Selamat, pendaftaran atas beasiswa ini telah diterima segera lakukan pendaftaran ulang!';
      case ProgressStatus.ditolak:
        return 'Maaf, pendaftaran atas beasiswa ini telah ditolak karena tidak memenuhi syarat!';
    }
  }

  /// Warna teks subtitle
  Color get subtitleColor {
    switch (status) {
      case ProgressStatus.tersimpan:
        return AppColors.dangerText;
      case ProgressStatus.ditinjau:
        return AppColors.warningText;
      case ProgressStatus.diterima:
        return AppColors.successText;
      case ProgressStatus.ditolak:
        return AppColors.dangerText;
    }
  }

  /// Apakah menampilkan chevron (>) 
  bool get showChevron =>
      status == ProgressStatus.diterima || status == ProgressStatus.ditinjau;

  /// Apakah menampilkan ikon alert (!)
  bool get showAlert => status == ProgressStatus.tersimpan;

  /// Apakah menampilkan ikon X
  bool get showReject => status == ProgressStatus.ditolak;
}

// FILTER ENUM 
enum ProgressFilter { semua, tersimpan, ditinjau, diterima, ditolak }

extension ProgressFilterLabel on ProgressFilter {
  String get label {
    switch (this) {
      case ProgressFilter.semua:
        return 'Semua';
      case ProgressFilter.tersimpan:
        return 'Tersimpan';
      case ProgressFilter.ditinjau:
        return 'Ditinjau';
      case ProgressFilter.diterima:
        return 'Diterima';
      case ProgressFilter.ditolak:
        return 'Ditolak';
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

// MAPPING ACRONYM KE DATA BEASISWA 
const _acronymToTitle = {
  'BUK': 'Beasiswa Unggulan Kemendikbud',
  'BAPK': 'Beasiswa Atlet Berprestasi KONI',
  'BSND': 'Beasiswa Seni Budaya Nusantara',
  'PPT': 'Paragon for Future Leaders',
  'LPDP': 'LPDP Beasiswa Reguler',
  'AI': 'Beasiswa Astra 1st',
  'TF': 'TELADAN - Tanoto Foundation',
};

// NOTIFIER 
class ProgressNotifier extends Notifier<ProgressState> {
  // Menyimpan status yang sudah diubah manual oleh user
  final Map<String, ProgressStatus> _manualStatuses = {};

  @override
  ProgressState build() {
    final applied = ref.watch(appliedScholarshipsProvider);
    final checklistSections = ref.watch(checklistProvider);

    final items = applied.map((acronym) {
      final title = _acronymToTitle[acronym] ?? acronym;

      // Hitung total & checked dokumen per acronym
      int totalDocs = 0;
      int checkedDocs = 0;
      for (final section in checklistSections) {
        for (final item in section.items) {
          if (item.tags.any((tag) => tag.label == acronym)) {
            totalDocs++;
            if (item.isChecked) {
              checkedDocs++;
            }
          }
        }
      }

      // Cek apakah user sudah mengubah statusnya secara manual
      if (_manualStatuses.containsKey(acronym)) {
        return ProgressItem(
          id: acronym,
          title: title,
          status: _manualStatuses[acronym]!,
          docsUploaded: checkedDocs,
          docsTotal: totalDocs,
        );
      }

      // Tentukan status otomatis berdasarkan kelengkapan dokumen
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

  void setFilter(ProgressFilter filter) {
    state = state.copyWith(activeFilter: filter);
  }

  void updateStatus(String itemId, ProgressStatus newStatus) {
    _manualStatuses[itemId] = newStatus;
    ref.invalidateSelf();
  }
}

final progressProvider = NotifierProvider<ProgressNotifier, ProgressState>(
  ProgressNotifier.new,
);
