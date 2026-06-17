import 'package:flutter/material.dart';

class Scholarship {
  final String id;
  final String title;
  final String provider;
  final Color providerColor;
  final List<String> tags;
  final int matchPercentage;
  final bool isSaved;
  final String logoPath;
  final DateTime deadline;
  
  final String description;
  final List<String> requirements;
  final Map<String, String> criteria;
  final List<String> documents;

  Scholarship({
    required this.id,
    required this.title,
    required this.provider,
    required this.providerColor,
    required this.tags,
    required this.matchPercentage,
    required this.deadline,
    this.isSaved = false,
    this.logoPath = '',
    this.description = 'Belum ada deskripsi untuk beasiswa ini.',
    this.requirements = const [],
    this.criteria = const {},
    this.documents = const [],
  });

  /// Hitung sisa hari dari sekarang ke deadline
  int get daysLeft {
    final now = DateTime.now();
    final diff = deadline.difference(DateTime(now.year, now.month, now.day)).inDays;
    return diff < 0 ? 0 : diff;
  }

  /// Format tanggal deadline (misal: "1 Juli 2026")
  String get deadlineFormatted {
    const months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return '${deadline.day} ${months[deadline.month]} ${deadline.year}';
  }

  Scholarship copyWith({
    String? id,
    String? title,
    String? provider,
    Color? providerColor,
    List<String>? tags,
    int? matchPercentage,
    DateTime? deadline,
    bool? isSaved,
    String? logoPath,
    String? description,
    List<String>? requirements,
    Map<String, String>? criteria,
    List<String>? documents,
  }) {
    return Scholarship(
      id: id ?? this.id,
      title: title ?? this.title,
      provider: provider ?? this.provider,
      providerColor: providerColor ?? this.providerColor,
      tags: tags ?? this.tags,
      matchPercentage: matchPercentage ?? this.matchPercentage,
      deadline: deadline ?? this.deadline,
      isSaved: isSaved ?? this.isSaved,
      logoPath: logoPath ?? this.logoPath,
      description: description ?? this.description,
      requirements: requirements ?? this.requirements,
      criteria: criteria ?? this.criteria,
      documents: documents ?? this.documents,
    );
  }
}
