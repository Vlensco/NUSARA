import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cabe/core/theme/app_colors.dart';
import 'package:cabe/core/theme/app_text_styles.dart';
import 'package:cabe/shared_widgets/app_chip.dart';
import 'package:cabe/features/progress/controllers/progress_controller.dart';
import 'package:cabe/features/progress/widgets/progress_item_tile.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(progressProvider);
    final notifier = ref.read(progressProvider.notifier);
    final filtered = state.filteredItems;

    return Scaffold(
      backgroundColor: AppColors.coolGray100,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Progress Pendaftaran', style: AppTextStyles.h2),
                  const SizedBox(height: 4),
                  Text(
                    '${filtered.length} beasiswa tercatat',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.coolGray500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            const Divider(height: 1, thickness: 1, color: AppColors.coolGray200),

            const SizedBox(height: 14),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: ProgressFilter.values.map((filter) {
                  final isActive = state.activeFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: AppChip(
                      label: filter.label,
                      variant: isActive
                          ? AppChipVariant.filled
                          : AppChipVariant.outline,
                      onTap: () => notifier.setFilter(filter),
                      borderRadius: 10,
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 12),


            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        'Tidak ada beasiswa\ndengan status ini.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.coolGray400,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        return ProgressItemTile(item: filtered[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
