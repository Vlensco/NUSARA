import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cabe/core/theme/app_colors.dart';
import 'package:cabe/core/theme/app_text_styles.dart';
import 'package:cabe/shared_widgets/app_chip.dart';
import 'package:cabe/shared_widgets/app_button.dart';
import 'package:cabe/features/progress/controllers/progress_controller.dart';
import 'package:cabe/features/progress/widgets/progress_item_tile.dart';
import 'package:cabe/features/checklist/controllers/checklist_controller.dart';
import 'package:cabe/core/routing/main_navigation.dart';
import 'package:easy_localization/easy_localization.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(progressProvider);

    if (state.items.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.coolGray100,
        body: SafeArea(
          child: _buildEmptyState(context, ref),
        ),
      );
    }

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
                  Text('progress.title'.tr(), style: AppTextStyles.h2),
                  const SizedBox(height: 4),
                  Text(
                    '${state.items.length} ${"progress.count_suffix".tr()}',
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _emptyTitle(state.activeFilter),
                              textAlign: TextAlign.center,
                              style: AppTextStyles.h3,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _emptySubtitle(state.activeFilter),
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.coolGray500,
                              ),
                            ),
                          ],
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

  String _emptyTitle(ProgressFilter filter) {
    switch (filter) {
      case ProgressFilter.tersimpan:
        return 'progress.empty_saved_title'.tr();
      case ProgressFilter.ditinjau:
        return 'progress.empty_review_title'.tr();
      case ProgressFilter.diterima:
        return 'progress.empty_accepted_title'.tr();
      case ProgressFilter.ditolak:
        return 'progress.empty_rejected_title'.tr();
      case ProgressFilter.semua:
        return 'progress.empty_all_title'.tr();
    }
  }

  String _emptySubtitle(ProgressFilter filter) {
    switch (filter) {
      case ProgressFilter.tersimpan:
        return 'progress.empty_saved_desc'.tr();
      case ProgressFilter.ditinjau:
        return 'progress.empty_review_desc'.tr();
      case ProgressFilter.diterima:
        return 'progress.empty_accepted_desc'.tr();
      case ProgressFilter.ditolak:
        return 'progress.empty_rejected_desc'.tr();
      case ProgressFilter.semua:
        return 'progress.empty_all_desc'.tr();
    }
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.trendingUp, size: 64, color: AppColors.coolGray300),
            const SizedBox(height: 24),
            Text(
              'progress.empty_root_title'.tr(),
              style: AppTextStyles.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'progress.empty_root_desc'.tr(),
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.coolGray500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            AppButton(
              label: 'progress.explore_btn'.tr(),
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
