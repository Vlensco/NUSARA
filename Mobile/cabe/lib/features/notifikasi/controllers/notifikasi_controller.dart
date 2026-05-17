import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cabe/features/notifikasi/models/notifikasi_model.dart';
import 'package:cabe/features/progress/controllers/progress_controller.dart';

class NotifikasiNotifier extends Notifier<List<NotifikasiModel>> {
  final Set<String> _removedIds = {};
  final Set<String> _readIds = {};
  bool _hasRemovedAny = false;
  final List<NotifikasiModel> _history = [];
  bool _dbLoaded = false;
  final Set<String> _existingContentKeys = {};

  @override
  List<NotifikasiModel> build() {
    // Load dari database pertama kali
    if (!_dbLoaded) {
      _loadFromDb();
    }

    // Listen perubahan progress — HANYA generate notifikasi untuk status BARU
    ref.listen(
      progressProvider,
      (previous, next) {
        // Skip jika belum ada data sebelumnya (first load)
        if (previous == null) return;

        _handleProgressChanges(previous.items, next.items);
      },
      fireImmediately: false, // JANGAN fire saat pertama kali — data dari DB sudah ada
    );

    return _history.where((n) => !_removedIds.contains(n.id)).toList();
  }

  /// Handle HANYA perubahan status yang benar-benar baru
  void _handleProgressChanges(List<ProgressItem> oldItems, List<ProgressItem> newItems) {
    bool addedNew = false;

    for (final newItem in newItems) {
      // Cari item lama
      final oldItem = oldItems.where((o) => o.id == newItem.id).firstOrNull;

      // Skip jika status tidak berubah
      if (oldItem != null && oldItem.status == newItem.status) continue;
      // Skip jika status 'tersimpan' (tidak perlu notifikasi)
      if (newItem.status == ProgressStatus.tersimpan) continue;

      String? message;
      NotifikasiType? type;
      final contentKey = '${newItem.id}_${newItem.status.name}';

      // Skip jika notifikasi ini sudah pernah dibuat
      if (_existingContentKeys.contains(contentKey)) continue;

      if (newItem.status == ProgressStatus.ditinjau) {
        message = 'Dokumen ${newItem.title} sedang dalam tahap peninjauan. Harap menunggu hasil seleksi.';
        type = NotifikasiType.ditinjau;
      } else if (newItem.status == ProgressStatus.diterima) {
        message = 'Selamat! Pendaftaran ${newItem.title} telah diterima. Segera lakukan pendaftaran ulang!';
        type = NotifikasiType.diterima;
      } else if (newItem.status == ProgressStatus.ditolak) {
        message = '${newItem.title} telah menolak pendaftaran beasiswa yang anda ajukan.';
        type = NotifikasiType.ditolak;
      }

      if (message != null && type != null) {
        final notif = NotifikasiModel(
          id: contentKey, // Temporary ID, akan diupdate setelah insert ke DB
          title: newItem.title,
          message: message,
          time: 'Baru saja',
          isRead: false,
          type: type,
        );

        _history.insert(0, notif);
        _existingContentKeys.add(contentKey);
        addedNew = true;

        // Simpan ke Firestore
        _insertNotifToDb(notif);
      }
    }

    if (addedNew) {
      _updateState();
    }
  }

  /// Load notifikasi dari Firestore
  Future<void> _loadFromDb() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .orderBy('created_at', descending: true)
          .limit(50)
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final id = doc.id;
        final isRead = data['is_read'] as bool? ?? false;
        final title = data['title'] as String? ?? '';
        final message = data['message'] as String? ?? '';
        final createdAt = (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now();

        final notif = NotifikasiModel(
          id: id,
          title: title,
          message: message,
          time: _formatTime(createdAt),
          isRead: isRead,
          type: _parseType(message),
        );

        if (!_history.any((h) => h.id == notif.id)) {
          _history.add(notif);
          if (isRead) _readIds.add(id);
        }

        // Track content key agar tidak generate ulang
        _trackContentKey(title, message);
      }

      _dbLoaded = true;
      _updateState();
    } catch (e) {
      debugPrint('Error loading notifications: $e');
      _dbLoaded = true;
    }
  }

  /// Track content key berdasarkan title + message agar tidak duplikat
  void _trackContentKey(String title, String message) {
    if (message.contains('tahap peninjauan')) {
      final acronym = _findAcronymByTitle(title);
      if (acronym != null) _existingContentKeys.add('${acronym}_ditinjau');
    } else if (message.contains('telah diterima')) {
      final acronym = _findAcronymByTitle(title);
      if (acronym != null) _existingContentKeys.add('${acronym}_diterima');
    } else if (message.contains('telah menolak')) {
      final acronym = _findAcronymByTitle(title);
      if (acronym != null) _existingContentKeys.add('${acronym}_ditolak');
    }
  }

  String? _findAcronymByTitle(String title) {
    const titleToAcronym = {
      'Beasiswa Unggulan Kemendikbud': 'BUK',
      'Beasiswa Atlet Berprestasi KONI': 'BAPK',
      'Beasiswa Seni Budaya Nusantara': 'BSND',
      'Paragon for Future Leaders': 'PPT',
      'LPDP Beasiswa Reguler': 'LPDP',
      'Beasiswa Astra 1st': 'AI',
      'TELADAN - Tanoto Foundation': 'TF',
    };
    return titleToAcronym[title];
  }

  /// Insert notifikasi ke Firestore
  Future<void> _insertNotifToDb(NotifikasiModel notif) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .add({
        'title': notif.title,
        'message': notif.message,
        'is_read': false,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error inserting notification: $e');
    }
  }

  NotifikasiType _parseType(String message) {
    if (message.contains('diterima')) return NotifikasiType.diterima;
    if (message.contains('menolak')) return NotifikasiType.ditolak;
    return NotifikasiType.ditinjau;
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }

  void _updateState() {
    state = _history.where((n) {
      return !_removedIds.contains(n.id);
    }).map((n) => n.copyWith(isRead: _readIds.contains(n.id))).toList();
  }

  bool get hasRemovedAny => _hasRemovedAny;

  Future<void> markAllAsRead() async {
    for (final notif in state) {
      _readIds.add(notif.id);
    }
    _updateState();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'is_read': true});
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Error marking all as read: $e');
    }
  }

  void markAsRead(String id) {
    _readIds.add(id);
    _updateState();
    _updateReadInDb(id, true);
  }

  Future<void> _updateReadInDb(String id, bool isRead) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .doc(id)
          .update({'is_read': isRead});
    } catch (e) {
      debugPrint('Error updating notification read status: $e');
    }
  }

  void removeNotifikasi(String id) {
    _removedIds.add(id);
    _hasRemovedAny = true;
    _updateState();
    _deleteFromDb(id);
  }

  void removeAll() {
    for (final notif in state) {
      _removedIds.add(notif.id);
    }
    _hasRemovedAny = true;
    _updateState();
    _deleteAllFromDb();
  }

  Future<void> _deleteFromDb(String id) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .doc(id)
          .delete();
    } catch (e) {
      debugPrint('Error deleting notification: $e');
    }
  }

  Future<void> _deleteAllFromDb() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Error deleting all notifications: $e');
    }
  }

  void undoRemove(NotifikasiModel notifikasi) {
    _removedIds.remove(notifikasi.id);
    _updateState();
    _insertNotifToDb(notifikasi);
  }

  int get unreadCount {
    return state.where((notif) => !notif.isRead).length;
  }
}

final notifikasiProvider = NotifierProvider<NotifikasiNotifier, List<NotifikasiModel>>(
  NotifikasiNotifier.new,
);
