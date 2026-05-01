import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cabe/features/notifikasi/models/notifikasi_model.dart';
import 'package:cabe/features/progress/controllers/progress_controller.dart';

class NotifikasiNotifier extends Notifier<List<NotifikasiModel>> {
  // Menyimpan ID notifikasi yang sudah dihapus oleh user
  final Set<String> _removedIds = {};
  // Menyimpan ID notifikasi yang sudah dibaca
  final Set<String> _readIds = {};
  // Track apakah user pernah menghapus notifikasi
  bool _hasRemovedAny = false;
  // History of notifications
  final List<NotifikasiModel> _history = [];

  @override
  List<NotifikasiModel> build() {
    // Listen for progress changes and append to history
    ref.listen(
      progressProvider,
      (previous, next) {
        bool addedNew = false;
        for (final item in next.items) {
          String? notifId;
          String? message;
          NotifikasiType? type;

          if (item.status == ProgressStatus.ditinjau) {
            notifId = '${item.id}_ditinjau';
            message = 'Dokumen ${item.title} sedang dalam tahap peninjauan. Harap menunggu hasil seleksi.';
            type = NotifikasiType.ditinjau;
          } else if (item.status == ProgressStatus.diterima) {
            notifId = '${item.id}_diterima';
            message = 'Selamat! Pendaftaran ${item.title} telah diterima. Segera lakukan pendaftaran ulang!';
            type = NotifikasiType.diterima;
          } else if (item.status == ProgressStatus.ditolak) {
            notifId = '${item.id}_ditolak';
            message = '${item.title} telah menolak pendaftaran beasiswa yang anda ajukan.';
            type = NotifikasiType.ditolak;
          }

          if (notifId != null) {
            // Check if this specific status change is already in history
            final exists = _history.any((n) => n.id == notifId);
            if (!exists) {
              _history.insert(0, NotifikasiModel(
                id: notifId,
                title: item.title,
                message: message!,
                time: 'Baru saja',
                isRead: false,
                type: type!,
              ));
              addedNew = true;
            }
          }
        }
        
        if (addedNew) {
          _updateState();
        }
      },
      fireImmediately: true,
    );

    return _history.where((n) => !_removedIds.contains(n.id)).toList();
  }

  void _updateState() {
    state = _history.where((n) {
      // Sync read state
      if (_readIds.contains(n.id)) {
        return !_removedIds.contains(n.id);
      }
      return !_removedIds.contains(n.id);
    }).map((n) => n.copyWith(isRead: _readIds.contains(n.id))).toList();
  }

  bool get hasRemovedAny => _hasRemovedAny;

  void markAllAsRead() {
    for (final notif in state) {
      _readIds.add(notif.id);
    }
    _updateState();
  }

  void markAsRead(String id) {
    _readIds.add(id);
    _updateState();
  }

  void removeNotifikasi(String id) {
    _removedIds.add(id);
    _hasRemovedAny = true;
    _updateState();
  }

  void removeAll() {
    for (final notif in state) {
      _removedIds.add(notif.id);
    }
    _hasRemovedAny = true;
    _updateState();
  }

  void undoRemove(NotifikasiModel notifikasi) {
    _removedIds.remove(notifikasi.id);
    _updateState();
  }

  int get unreadCount {
    return state.where((notif) => !notif.isRead).length;
  }
}

final notifikasiProvider = NotifierProvider<NotifikasiNotifier, List<NotifikasiModel>>(
  NotifikasiNotifier.new,
);
