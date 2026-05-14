import 'package:flutter/material.dart';

class Scholarship {
  final String id;
  final String title;
  final String provider;
  final Color providerColor;
  final List<String> tags;
  final int matchPercentage;
  final int daysLeft;
  final bool isSaved;
  
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
    required this.daysLeft,
    this.isSaved = false,
    this.description = 'Belum ada deskripsi untuk beasiswa ini.',
    this.requirements = const [],
    this.criteria = const {},
    this.documents = const [],
  });

  Scholarship copyWith({
    String? id,
    String? title,
    String? provider,
    Color? providerColor,
    List<String>? tags,
    int? matchPercentage,
    int? daysLeft,
    bool? isSaved,
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
      daysLeft: daysLeft ?? this.daysLeft,
      isSaved: isSaved ?? this.isSaved,
      description: description ?? this.description,
      requirements: requirements ?? this.requirements,
      criteria: criteria ?? this.criteria,
      documents: documents ?? this.documents,
    );
  }
}
