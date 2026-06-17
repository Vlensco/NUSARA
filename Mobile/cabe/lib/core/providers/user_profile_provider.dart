import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// StreamProvider yang mendengarkan perubahan dokumen user secara real-time.
/// Setiap kali data Firestore berubah (misal setelah edit profil atau save skor),
/// semua widget yang watch provider ini akan otomatis rebuild.
///
/// Provider ini juga reaktif terhadap auth state changes — saat user login
/// atau register, stream Firestore akan dimulai ulang secara otomatis.
final userProfileProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final controller = StreamController<Map<String, dynamic>?>();
  StreamSubscription<DocumentSnapshot>? firestoreSub;

  final authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
    // Hentikan subscription Firestore sebelumnya
    firestoreSub?.cancel();

    if (user == null) {
      controller.add(null);
      return;
    }

    // Mulai listen Firestore doc user yang baru
    firestoreSub = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen(
      (snapshot) {
        if (!snapshot.exists) {
          controller.add(null);
        } else {
          controller.add(snapshot.data());
        }
      },
      onError: (e) => controller.addError(e),
    );
  });

  ref.onDispose(() {
    authSub.cancel();
    firestoreSub?.cancel();
    controller.close();
  });

  return controller.stream;
});
