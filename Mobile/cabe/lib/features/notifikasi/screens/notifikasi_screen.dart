import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cabe/core/theme/app_colors.dart';
import 'package:cabe/core/theme/app_text_styles.dart';
import 'package:cabe/features/notifikasi/widgets/notifikasi_card.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cabe/features/notifikasi/controllers/notifikasi_controller.dart';

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
          ? 'Notifikasi sudah bersih!'
          : 'Kotak notifikasimu masih sepi.';
      final emptySubtitle = hasRemovedAny
          ? 'Kamu sudah menghapus semua riwayat pemberitahuan. Kami akan kabari lagi jika ada pembaruan beasiswamu.'
          : 'Nanti, pengingat tenggat waktu dokumen dan status kelulusan beasiswamu akan kami kirimkan ke sini.';
      final emptyIcon = hasRemovedAny ? LucideIcons.checkCircle : LucideIcons.bellOff;

      return Scaffold(
        backgroundColor: const Color(0xFFFBFBFB),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Notifikasi', style: AppTextStyles.h2),
                const SizedBox(height: 4),
                Text(
                  'Tidak ada notifikasi',
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

    // Kondisi 2 & 3: unread atau semua sudah dibaca
    // Pisahkan berdasarkan waktu, unread di atas
    final terbaru = notifications.where((n) => n.time == 'Baru saja').toList()
      ..sort((a, b) => a.isRead == b.isRead ? 0 : (a.isRead ? 1 : -1));
    final sebelumnya = notifications.where((n) => n.time != 'Baru saja').toList()
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
                      const Text(
                        'Notifikasi',
                        style: AppTextStyles.h2,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        unreadCount > 0
                            ? '$unreadCount belum dibaca'
                            : 'Semua sudah dibaca',
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
                          const SnackBar(
                            content: Text('Semua notifikasi berhasil dihapus.'),
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        unreadCount > 0 ? 'Tandai semua dibaca' : 'Hapus semua',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: unreadCount > 0 ? AppColors.blue900 : AppColors.dangerText,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Section: TERBARU
              if (terbaru.isNotEmpty) ...[
                Text(
                  'TERBARU',
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
                SizedBox(height: terbaru.isNotEmpty ? 24 : 0),
                Text(
                  'SEBELUMNYA',
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
              content: const Text('Notifikasi dihapus'),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Urungkan',
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
          child: Icon(LucideIcons.trash2, color: AppColors.white),
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
