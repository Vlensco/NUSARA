import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cabe/core/theme/app_colors.dart';
import 'package:cabe/core/theme/app_text_styles.dart';
import 'package:cabe/features/notifikasi/widgets/notifikasi_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cabe/features/notifikasi/controllers/notifikasi_controller.dart';
import 'package:cabe/features/notifikasi/models/notifikasi_model.dart';
import 'package:easy_localization/easy_localization.dart';

class NotifikasiScreen extends ConsumerWidget {
  const NotifikasiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notifikasiProvider);
    final unreadCount = ref.read(notifikasiProvider.notifier).unreadCount;
    final hasRemovedAny = ref.read(notifikasiProvider.notifier).hasRemovedAny;

    // Kondisi: Tidak ada notifikasi
    if (notifications.isEmpty) {
      final emptyTitle = hasRemovedAny
          ? 'notification.empty_cleaned_title'.tr()
          : 'notification.empty_default_title'.tr();
      final emptySubtitle = hasRemovedAny
          ? 'notification.empty_cleaned_subtitle'.tr()
          : 'notification.empty_default_subtitle'.tr();
      final emptyIcon = hasRemovedAny ? LucideIcons.checkCircle : LucideIcons.bellOff;

      return Scaffold(
        backgroundColor: const Color(0xFFFBFBFB),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('notification.title'.tr(), style: AppTextStyles.h2),
                const SizedBox(height: 4),
                Text(
                  'notification.no_notifications'.tr(),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.gray400,
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            color: AppColors.blue100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            emptyIcon,
                            size: 48,
                            color: AppColors.blue600,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          emptyTitle,
                          style: AppTextStyles.h3,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            emptySubtitle,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.gray500,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Pisahkan notifikasi berdasarkan tipe
    final deadlineNotifs = notifications
        .where((n) => n.type == NotifikasiType.deadline)
        .toList()
      ..sort((a, b) => (a.daysLeft ?? 999).compareTo(b.daysLeft ?? 999));

    final progressNotifs = notifications
        .where((n) => n.type != NotifikasiType.deadline)
        .toList();

    final terbaru = progressNotifs
        .where((n) => n.time.contains('Baru saja') || n.time.contains('Just now'))
        .toList()
      ..sort((a, b) => a.isRead == b.isRead ? 0 : (a.isRead ? 1 : -1));
    final sebelumnya = progressNotifs
        .where((n) => !n.time.contains('Baru saja') && !n.time.contains('Just now'))
        .toList()
      ..sort((a, b) => a.isRead == b.isRead ? 0 : (a.isRead ? 1 : -1));

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'notification.title'.tr(),
                        style: AppTextStyles.h2,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        unreadCount > 0
                            ? '$unreadCount ${"notification.unread".tr()}'
                            : 'notification.all_read'.tr(),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.gray400,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      if (unreadCount > 0) {
                        ref.read(notifikasiProvider.notifier).markAllAsRead();
                      } else {
                        ref.read(notifikasiProvider.notifier).removeAll();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('notification.toast_all_deleted'.tr()),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        unreadCount > 0 ? 'notification.mark_all_read'.tr() : 'notification.clear_all'.tr(),
                        style: AppTextStyles.labelLarge.copyWith(
                          color: unreadCount > 0 ? AppColors.blue900 : AppColors.dangerText,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Section: DEADLINE BEASISWA
              if (deadlineNotifs.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(LucideIcons.calendarClock, size: 16, color: AppColors.blue600),
                    const SizedBox(width: 6),
                    Text(
                      'DEADLINE BEASISWA',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.blue600,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.blue100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${deadlineNotifs.length}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.blue600,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...deadlineNotifs.asMap().entries.map(
                  (entry) => _buildNotifItem(context, ref, entry.value,
                      isLast: entry.key == deadlineNotifs.length - 1 &&
                          terbaru.isEmpty &&
                          sebelumnya.isEmpty),
                ),
              ],

              // Section: TERBARU
              if (terbaru.isNotEmpty) ...[
                SizedBox(height: deadlineNotifs.isNotEmpty ? 24 : 0),
                Text(
                  'notification.sec_recent'.tr(),
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.gray500,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
                ...terbaru.asMap().entries.map(
                  (entry) => _buildNotifItem(context, ref, entry.value,
                      isLast: entry.key == terbaru.length - 1 && sebelumnya.isEmpty),
                ),
              ],

              // Section: SEBELUMNYA
              if (sebelumnya.isNotEmpty) ...[
                SizedBox(height: (terbaru.isNotEmpty || deadlineNotifs.isNotEmpty) ? 24 : 0),
                Text(
                  'notification.sec_previous'.tr(),
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.gray500,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
                ...sebelumnya.asMap().entries.map(
                  (entry) => _buildNotifItem(context, ref, entry.value,
                      isLast: entry.key == sebelumnya.length - 1),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotifItem(BuildContext context, WidgetRef ref, dynamic notif, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16.0),
      child: Dismissible(
        key: Key(notif.id),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          ref.read(notifikasiProvider.notifier).removeNotifikasi(notif.id);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('notification.toast_deleted'.tr()),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'notification.toast_undo'.tr(),
                textColor: AppColors.blue200,
                onPressed: () {
                  ref.read(notifikasiProvider.notifier).undoRemove(notif);
                },
              ),
            ),
          );
        },
        background: Container(
          decoration: BoxDecoration(
            color: AppColors.dangerText,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: const Icon(LucideIcons.trash2, color: AppColors.white),
        ),
        child: GestureDetector(
          onTap: () {
            if (!notif.isRead) {
              ref.read(notifikasiProvider.notifier).markAsRead(notif.id);
            }
          },
          child: NotifikasiCard(notifikasi: notif),
        ),
      ),
    );
  }
}
