import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // --- PRIMARY BLUES ---
  static const Color blue100 = Color(0xFFECF1FF);
  static const Color blue200 = Color(0xFFC2D3FF);
  static const Color blue300 = Color(0xFF81ACFF);
  static const Color blue500 = Color(0xFF0086FB); // Base Primary
  static const Color blue600 = Color(0xFF0062BB);
  static const Color blue800 = Color(0xFF00417F);
  static const Color blue900 = Color(0xFF002248);

  // --- NEUTRAL GRAYS ---
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray200 = Color(0xFFD6D6D6);
  static const Color gray300 = Color(0xFFAFAFAF);
  static const Color gray400 = Color(0xFF898989);
  static const Color gray500 = Color(0xFF656565);
  static const Color gray700 = Color(0xFF434343);
  static const Color gray900 = Color(0xFF242424);

  // --- COOL GRAYS ---
  static const Color coolGray100 = Color(0xFFF0F1F1);
  static const Color coolGray200 = Color(0xFFD2D3D6);
  static const Color coolGray300 = Color(0xFFA9ACB1);
  static const Color coolGray400 = Color(0xFF83878D);
  static const Color coolGray500 = Color(0xFF606367);
  static const Color coolGray700 = Color(0xFF3F4144);
  static const Color coolGray900 = Color(0xFF212224);

  // --- STATUS COLORS ---
  // Success (Diterima / Cocok >= 70%)
  static const Color successBg   = Color(0xFFD5F5E3);
  static const Color successText = Color(0xFF1E8449);
  // Warning (Ditinjau / Cocok 40–69%)
  static const Color warningBg   = Color(0xFFFFF3CD);
  static const Color warningText = Color(0xFF856404);
  // Danger (Ditolak / Cocok < 40%)
  static const Color dangerBg    = Color(0xFFFDE8E8);
  static const Color dangerText  = Color(0xFFC0392B);
  // Info (Tersimpan)
  static const Color infoBg      = Color(0xFFD6EAF8);
  static const Color infoText    = Color(0xFF1A5276);
}