import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cabe/core/theme/app_colors.dart';
import 'package:cabe/core/theme/app_text_styles.dart';
import 'package:cabe/features/checklist/controllers/checklist_controller.dart';
import 'package:cabe/features/checklist/widgets/checklist_item_tile.dart';

class ChecklistScreen extends ConsumerWidget {
  const ChecklistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sections = ref.watch(checklistProvider);
    final notifier = ref.read(checklistProvider.notifier);
    final total = notifier.totalItems;
    final checked = notifier.checkedItems;
    final progress = total == 0 ? 0.0 : checked / total;

    return Scaffold(
      backgroundColor: AppColors.coolGray100,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: AppColors.coolGray100,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
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

            // --- LIST CONTENT ---
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 24),
                itemCount: sections.length,
                itemBuilder: (context, sectionIndex) {
                  final section = sections[sectionIndex];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                        child: Text(
                          section.title,
                          style: AppTextStyles.h3,
                        ),
                      ),
                      // Items
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
}
