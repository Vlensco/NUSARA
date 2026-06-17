import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cabe/core/theme/app_colors.dart';
import 'package:cabe/core/theme/app_text_styles.dart';
import 'package:cabe/shared_widgets/app_chip.dart';
import 'package:cabe/shared_widgets/scholarship_card.dart';
import 'package:cabe/features/scholarships/providers/scholarship_provider.dart';
import 'package:cabe/features/scholarships/screens/detail_beasiswa_page.dart';
import 'package:cabe/core/providers/user_profile_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:lucide_icons/lucide_icons.dart';

// ── Provider untuk search query ──
class _SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void set(String v) => state = v;
}
final homeSearchQueryProvider = NotifierProvider<_SearchQueryNotifier, String>(_SearchQueryNotifier.new);

// ── Provider untuk filter tags yang aktif ──
class _TagFiltersNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};
  void set(Set<String> v) => state = v;
}
final homeTagFiltersProvider = NotifierProvider<_TagFiltersNotifier, Set<String>>(_TagFiltersNotifier.new);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      ref.read(homeSearchQueryProvider.notifier).set(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int selectedCategoryIndex = ref.watch(homeCategoryFilterProvider);
    final allScholarships = ref.watch(scholarshipProvider);
    final userProfileAsync = ref.watch(userProfileProvider);
    final searchQuery = ref.watch(homeSearchQueryProvider);
    final activeTagFilters = ref.watch(homeTagFiltersProvider);

    final userName = userProfileAsync.maybeWhen(
      data: (data) {
        final name = data?['nama_lengkap'] as String?;
        return (name != null && name.isNotEmpty) ? name : 'Pelajar';
      },
      orElse: () => '...',
    );

    final List<String> categories = [
      'Semua',
      'Personalisasi',
      'Pemerintah',
      'Swasta/Cooperate',
      'Penuh',
      'Parsial',
    ];

    final List<String> categoryKeys = [
      'home.cat_all',
      'home.cat_personalized',
      'home.cat_government',
      'home.cat_private',
      'home.cat_full',
      'home.cat_partial',
    ];

    final selectedCategory = categories[selectedCategoryIndex];

    // Kumpulkan semua tag unik dari semua beasiswa
    final allTags = <String>{};
    for (final s in allScholarships) {
      allTags.addAll(s.tags);
    }
    final sortedTags = allTags.toList()..sort();

    var scholarships = allScholarships.where((s) {
      // Filter kategori
      if (selectedCategory != 'Semua') {
        if (selectedCategory == 'Personalisasi') {
          if (s.matchPercentage < 70) return false;
        } else if (selectedCategory == 'Swasta/Cooperate') {
          if (!s.tags.contains('Swasta') && !s.tags.contains('Cooperate')) return false;
        } else {
          if (!s.tags.contains(selectedCategory)) return false;
        }
      }

      // Filter tag tambahan
      if (activeTagFilters.isNotEmpty) {
        final hasAllTags = activeTagFilters.every((tag) => s.tags.contains(tag));
        if (!hasAllTags) return false;
      }

      // Filter search query
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final matchTitle = s.title.toLowerCase().contains(q);
        final matchProvider = s.provider.toLowerCase().contains(q);
        final matchTags = s.tags.any((t) => t.toLowerCase().contains(q));
        if (!matchTitle && !matchProvider && !matchTags) return false;
      }

      return true;
    }).toList()
      ..sort((a, b) => b.matchPercentage.compareTo(a.matchPercentage));

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
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
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
                            'home.welcome'.tr(),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.coolGray300,
                            ),
                          ),
                          Text(
                            '$userName !',
                            style: AppTextStyles.h3.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(
                          'https://ui-avatars.com/api/?name=$userName&background=E5E7EB&color=1F2937',
                        ),
                      ),
                    ],
                  ),
                ),
                // ── SearchBar + Filter Button ──
                Positioned(
                  bottom: -25,
                  left: 24,
                  right: 24,
                  child: Row(
                    children: [
                      // SearchBar
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 2,
                                spreadRadius: 0,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: AppTextStyles.bodyMedium,
                            decoration: InputDecoration(
                              hintText: 'home.search_hint'.tr(),
                              hintStyle: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.coolGray400,
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: AppColors.coolGray400,
                              ),
                              suffixIcon: searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.close, size: 18, color: AppColors.coolGray400),
                                      onPressed: () {
                                        _searchController.clear();
                                        ref.read(homeSearchQueryProvider.notifier).set('');
                                      },
                                    )
                                  : null,
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
                      const SizedBox(width: 10),
                      // Filter Button
                      GestureDetector(
                        onTap: () => _showFilterSheet(context, sortedTags),
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: activeTagFilters.isNotEmpty
                                ? AppColors.blue600
                                : AppColors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 2,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                LucideIcons.slidersHorizontal,
                                size: 20,
                                color: activeTagFilters.isNotEmpty
                                    ? Colors.white
                                    : AppColors.coolGray500,
                              ),
                              if (activeTagFilters.isNotEmpty)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: Colors.amber,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${activeTagFilters.length}',
                                        style: const TextStyle(fontSize: 6, color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: List.generate(
                    categories.length,
                    (i) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: AppChip(
                        label: categoryKeys[i].tr(),
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

          // Active tag filters indicator
          if (activeTagFilters.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 4),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Text(
                        'Filter: ',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.coolGray500),
                      ),
                      ...activeTagFilters.map((tag) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: GestureDetector(
                              onTap: () {
                                ref.read(homeTagFiltersProvider.notifier).set(
                                    Set<String>.from(activeTagFilters)..remove(tag));
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.blue100,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.blue300),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      tag,
                                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.blue600),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.close, size: 12, color: AppColors.blue500),
                                  ],
                                ),
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ),

          // Section title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedCategory == 'Semua'
                        ? 'home.all_scholarships'.tr()
                        : '${"home.scholarship".tr()} ${categoryKeys[selectedCategoryIndex].tr()}',
                    style: AppTextStyles.h4,
                  ),
                  Text(
                    '${scholarships.length} ${"home.scholarship_count".tr()}',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
          ),

          // Scholarship list or empty state
          scholarships.isEmpty
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                    child: Column(
                      children: [
                        Icon(LucideIcons.searchX, size: 56, color: AppColors.coolGray300),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada beasiswa ditemukan',
                          style: AppTextStyles.h4.copyWith(color: AppColors.coolGray500),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Coba ubah kata kunci atau filter pencarianmu',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.coolGray400),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
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
                            logoPath: s.logoPath,
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

  void _showFilterSheet(BuildContext context, List<String> allTags) {
    final activeFilters = ref.read(homeTagFiltersProvider);
    final tempSelected = Set<String>.from(activeFilters);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                top: 20,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.coolGray300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Filter Beasiswa', style: AppTextStyles.h4),
                      if (tempSelected.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            setSheetState(() => tempSelected.clear());
                          },
                          child: Text(
                            'Reset',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.dangerText),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pilih tag untuk menyaring beasiswa',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.coolGray500),
                  ),
                  const SizedBox(height: 16),

                  // Tag grid
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: allTags.map((tag) {
                      final isSelected = tempSelected.contains(tag);
                      return GestureDetector(
                        onTap: () {
                          setSheetState(() {
                            if (isSelected) {
                              tempSelected.remove(tag);
                            } else {
                              tempSelected.add(tag);
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.blue900 : AppColors.coolGray100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppColors.blue900 : AppColors.coolGray300,
                            ),
                          ),
                          child: Text(
                            tag,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isSelected ? Colors.white : AppColors.coolGray700,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Apply button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ref.read(homeTagFiltersProvider.notifier).set(
                            Set<String>.from(tempSelected));
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue900,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        tempSelected.isEmpty
                            ? 'Tampilkan Semua'
                            : 'Terapkan Filter (${tempSelected.length})',
                        style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
