import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cabe/core/theme/app_colors.dart';
import 'package:cabe/core/theme/app_text_styles.dart';
import 'package:cabe/shared_widgets/app_chip.dart';
import 'package:cabe/shared_widgets/scholarship_card.dart';
import 'package:cabe/features/scholarships/providers/scholarship_provider.dart';
import 'package:cabe/features/scholarships/screens/detail_beasiswa_page.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int selectedCategoryIndex = ref.watch(homeCategoryFilterProvider);
    final allScholarships = ref.watch(scholarshipProvider);

    final List<String> categories = [
      'Semua',
      'Personalisasi',
      'Pemerintah',
      'Swasta/Cooperate',
      'Penuh',
      'Parsial',
    ];

    final selectedCategory = categories[selectedCategoryIndex];

    final scholarships = allScholarships.where((s) {
      if (selectedCategory == 'Semua') return true;
      if (selectedCategory == 'Personalisasi') return s.matchPercentage >= 70;
      if (selectedCategory == 'Swasta/Cooperate') {
        return s.tags.contains('Swasta') || s.tags.contains('Cooperate');
      }
      return s.tags.contains(selectedCategory);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.coolGray100,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 60),
                  decoration: const BoxDecoration(
                    color: AppColors.blue900,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat datang,',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.coolGray300,
                            ),
                          ),
                          Text(
                            'Patrick Star !',
                            style: AppTextStyles.h3.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                      const CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(
                          'https://i.pravatar.cc/150?u=patrick',
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: -25,
                  left: 20,
                  right: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextField(
                      style: AppTextStyles.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'Cari beasiswa...',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.coolGray400,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.coolGray400,
                        ),
                        fillColor: AppColors.white,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Category chips
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 40, bottom: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: List.generate(
                    categories.length,
                    (i) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: AppChip(
                        label: categories[i],
                        variant: selectedCategoryIndex == i
                            ? AppChipVariant.filled
                            : AppChipVariant.outline,
                        onTap: () => ref.read(homeCategoryFilterProvider.notifier).setCategory(i),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Section title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedCategory == 'Semua'
                        ? 'Semua Beasiswa'
                        : 'Beasiswa $selectedCategory',
                    style: AppTextStyles.h4,
                  ),
                  Text(
                    '${scholarships.length} Beasiswa',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
          ),

          // Scholarship list
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final s = scholarships[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ScholarshipCard(
                      title: s.title,
                      provider: s.provider,
                      providerColor: s.providerColor,
                      tags: List<String>.from(s.tags),
                      matchPercentage: s.matchPercentage,
                      daysLeft: s.daysLeft,
                      isSaved: s.isSaved,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailBeasiswaPage(scholarship: s),
                          ),
                        );
                      },
                      onSaved: () {
                        ref.read(scholarshipProvider.notifier).toggleSave(s.id);
                      },
                    ),
                  );
                },
                childCount: scholarships.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
