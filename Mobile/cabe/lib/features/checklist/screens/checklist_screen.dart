import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cabe/core/theme/app_colors.dart';
import 'package:cabe/core/theme/app_text_styles.dart';
import 'package:cabe/features/checklist/controllers/checklist_controller.dart';
import 'package:cabe/features/checklist/widgets/checklist_item_tile.dart';
import 'package:cabe/shared_widgets/app_button.dart';
import 'package:cabe/core/routing/main_navigation.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ChecklistScreen extends ConsumerWidget {
  const ChecklistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rawSections = ref.watch(checklistProvider);
    final filter = ref.watch(checklistFilterProvider);
    final applied = ref.watch(appliedScholarshipsProvider);
    final notifier = ref.read(checklistProvider.notifier);

    if (applied.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.coolGray100,
        body: SafeArea(
          child: _buildEmptyState(context, ref),
        ),
      );
    }

    List<ChecklistSection> sections = rawSections;
    if (filter != null) {
      sections = rawSections.map((section) {
        return ChecklistSection(
          title: section.title,
          items: section.items
              .where((item) => item.tags.any((tag) => tag.label == filter))
              .map((item) => item.copyWith(
                    tags: item.tags.where((tag) => applied.contains(tag.label)).toList(),
                  ))
              .toList(),
        );
      }).where((section) => section.items.isNotEmpty).toList();
    } else {
      sections = rawSections.map((section) {
        return ChecklistSection(
          title: section.title,
          items: section.items
              .where((item) => item.tags.any((tag) => applied.contains(tag.label)))
              .map((item) => item.copyWith(
                    tags: item.tags.where((tag) => applied.contains(tag.label)).toList(),
                  ))
              .toList(),
        );
      }).where((section) => section.items.isNotEmpty).toList();
    }

    final total = sections.fold(0, (sum, s) => sum + s.items.length);
    final checked = sections.fold(0, (sum, s) => sum + s.items.where((i) => i.isChecked).length);
    final progress = total == 0 ? 0.0 : checked / total;

    return Scaffold(
      backgroundColor: AppColors.coolGray100,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: AppColors.coolGray100,
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Checklist Beasiswa', style: AppTextStyles.h2),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'File tercatat $checked / $total',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.coolGray500,
                        ),
                      ),
                      Text(
                        '${(progress * 100).round()}%',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.coolGray500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: AppColors.coolGray200,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.blue900,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                itemCount: sections.length,
                itemBuilder: (context, sectionIndex) {
                  final section = sections[sectionIndex];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 8),
                        child: Text(
                          section.title,
                          style: AppTextStyles.h3,
                        ),
                      ),
                      ...section.items.map((item) => ChecklistItemTile(
                            item: item,
                            onToggle: () => notifier.toggleItem(item.id),
                          )),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.clipboardList, size: 64, color: AppColors.coolGray300),
            const SizedBox(height: 24),
            Text(
              'Belum ada beasiswa yang didaftar',
              style: AppTextStyles.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Daftar beasiswa pilihanmu terlebih dahulu untuk melihat daftar tugas dan dokumen yang perlu disiapkan di sini.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.coolGray500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            AppButton(
              label: 'Jelajahi Beasiswa',
              isFullWidth: true,
              onPressed: () {
                ref.read(bottomNavIndexProvider.notifier).setIndex(0);
              },
            ),
          ],
        ),
      ),
    );
  }
}
