import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cabe/core/theme/app_colors.dart';
import 'package:cabe/core/theme/app_text_styles.dart';
import 'package:cabe/features/checklist/controllers/checklist_controller.dart';
import 'package:cabe/features/checklist/widgets/checklist_item_tile.dart';
import 'package:cabe/shared_widgets/app_button.dart';
import 'package:cabe/core/routing/main_navigation.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ChecklistScreen extends ConsumerStatefulWidget {
  const ChecklistScreen({super.key});

  @override
  ConsumerState<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends ConsumerState<ChecklistScreen> {

  static const _acronymToFullName = {
    'BUK': 'Beasiswa Unggulan',
    'BAPK': 'Beasiswa Atlet Berprestasi',
    'BSND': 'Beasiswa Seni Budaya',
    'PPT': 'Paragon Future Leaders',
    'LPDP': 'LPDP Beasiswa Reguler',
    'AI': 'Beasiswa Astra 1st',
    'TF': 'TELADAN Tanoto Foundation',
  };

  @override
  Widget build(BuildContext context) {
    final applied = ref.watch(appliedScholarshipsProvider);
    final viewState = ref.watch(checklistViewProvider);
    final notifier = ref.read(checklistProvider.notifier);

    // perubahan pada completedScholarshipsProvider untuk memunculkan toast
    ref.listen(completedScholarshipsProvider, (previous, next) {
      if (previous == null) return;
      
      final newlyCompleted = next.where((acronym) {
        // Cek apakah baru saja selesai dan belum di-toast
        return !previous.contains(acronym) && !notifier.hasBeenToasted(acronym);
      }).toList();

      if (newlyCompleted.isNotEmpty) {
        for (final acronym in newlyCompleted) {
          notifier.markAsToasted(acronym);
        }
        _showCompletionToast(newlyCompleted);
      }

      // Jika ada beasiswa yang statusnya tidak lengkap, hapus dari list toasted
      final unchecked = previous.where((acronym) => !next.contains(acronym));
      for (final acronym in unchecked) {
        notifier.unmarkAsToasted(acronym);
      }
    });

    if (applied.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.coolGray100,
        body: SafeArea(
          child: _buildEmptyState(context),
        ),
      );
    }

    final sections = viewState.sections;
    final total = viewState.total;
    final checked = viewState.checked;
    final progress = viewState.progress;
    final isAllCompleted = viewState.isAllCompleted;

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
                          color: isAllCompleted ? Colors.green.shade700 : AppColors.coolGray500,
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
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isAllCompleted ? Colors.green : AppColors.blue900,
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

  void _showCompletionToast(List<String> acronyms) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    // Buat list teks per beasiswa
    final lines = acronyms.map((acronym) {
      final fullName = _acronymToFullName[acronym] ?? acronym;
      return 'Dokumen $fullName ($acronym) sudah lengkap!';
    }).toList();

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 20,
        left: 24,
        right: 24,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: -100, end: 0),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, value),
                child: child,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A), // Warna hijau success
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      LucideIcons.partyPopper,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...lines.map((line) => Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text(
                                line,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )),
                        const SizedBox(height: 4),
                        const Text(
                          'Cek halaman Progress untuk status peninjauan.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 4), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  Widget _buildEmptyState(BuildContext context) {
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
