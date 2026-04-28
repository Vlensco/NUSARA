import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cabe/core/theme/app_colors.dart';

// ─── ENUM STATUS ─────────────────────────────────────────────────────────────
enum ProgressStatus { tersimpan, ditinjau, diterima, ditolak }

// ─── MODEL ───────────────────────────────────────────────────────────────────
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

  ProgressItem copyWith({ProgressStatus? status}) {
    return ProgressItem(
      id: id,
      title: title,
      status: status ?? this.status,
      docsUploaded: docsUploaded,
      docsTotal: docsTotal,
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

  /// Apakah menampilkan chevron (>) di kanan
  bool get showChevron =>
      status == ProgressStatus.diterima || status == ProgressStatus.ditinjau;

  /// Apakah menampilkan ikon alert (!) di kanan
  bool get showAlert => status == ProgressStatus.tersimpan;

  /// Apakah menampilkan ikon X di kanan
  bool get showReject => status == ProgressStatus.ditolak;
}

// ─── FILTER ENUM ─────────────────────────────────────────────────────────────
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

// ─── STATE ───────────────────────────────────────────────────────────────────
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

// ─── DATA DUMMY ──────────────────────────────────────────────────────────────
final _dummyProgress = [
  const ProgressItem(
    id: 'p1',
    title: 'TELADAN - Tanoto Foundation',
    status: ProgressStatus.diterima,
  ),
  const ProgressItem(
    id: 'p2',
    title: 'Beasiswa Unggulan Kemendikbud',
    status: ProgressStatus.diterima,
  ),
  const ProgressItem(
    id: 'p3',
    title: 'Pertamina Foundation Bright',
    status: ProgressStatus.ditinjau,
  ),
  const ProgressItem(
    id: 'p4',
    title: 'Beasiswa Atlet Berprestasi KONI',
    status: ProgressStatus.tersimpan,
    docsUploaded: 0,
    docsTotal: 7,
  ),
  const ProgressItem(
    id: 'p5',
    title: 'Beasiswa Seni Budaya Nusantara',
    status: ProgressStatus.tersimpan,
    docsUploaded: 1,
    docsTotal: 4,
  ),
  const ProgressItem(
    id: 'p6',
    title: 'Paragon Scholarship for Future Leaders',
    status: ProgressStatus.tersimpan,
    docsUploaded: 0,
    docsTotal: 4,
  ),
  const ProgressItem(
    id: 'p7',
    title: 'LPDP Beasiswa Reguler',
    status: ProgressStatus.tersimpan,
    docsUploaded: 0,
    docsTotal: 3,
  ),
  const ProgressItem(
    id: 'p8',
    title: 'Beasiswa Astra 1st',
    status: ProgressStatus.tersimpan,
    docsUploaded: 0,
    docsTotal: 5,
  ),
  const ProgressItem(
    id: 'p9',
    title: 'Beasiswa Bank Indonesia',
    status: ProgressStatus.ditolak,
  ),
  const ProgressItem(
    id: 'p10',
    title: 'Sampoerna Foundation Scholarship',
    status: ProgressStatus.ditolak,
  ),
];

// ─── NOTIFIER ────────────────────────────────────────────────────────────────
class ProgressNotifier extends Notifier<ProgressState> {
  @override
  ProgressState build() => ProgressState(items: _dummyProgress);

  void setFilter(ProgressFilter filter) {
    state = state.copyWith(activeFilter: filter);
  }

  void updateStatus(String itemId, ProgressStatus newStatus) {
    final updatedItems = state.items.map((item) {
      if (item.id == itemId) return item.copyWith(status: newStatus);
      return item;
    }).toList();
    state = state.copyWith(items: updatedItems);
  }
}

final progressProvider = NotifierProvider<ProgressNotifier, ProgressState>(
  ProgressNotifier.new,
);
