import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// StreamProvider yang mendengarkan perubahan dokumen user secara real-time.
/// Setiap kali data Firestore berubah (misal setelah edit profil atau save skor),
/// semua widget yang watch provider ini akan otomatis rebuild.
final userProfileProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    return Stream.value(null);
  }

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((snapshot) {
    if (!snapshot.exists) return null;
    return snapshot.data();
  });
});
