import 'package:flutter/material.dart';
import 'package:cabe/core/theme/app_colors.dart';
import 'package:cabe/core/theme/app_text_styles.dart';
import 'package:cabe/features/profile_setup/models/profile_setup_data.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Step 3: Minat dan Bakat
class MinatBakatStep extends StatefulWidget {
  final List<String> selectedItems;
  final ValueChanged<String> onToggle;

  const MinatBakatStep({
    super.key,
    required this.selectedItems,
    required this.onToggle,
  });

  @override
  State<MinatBakatStep> createState() => _MinatBakatStepState();
}

class _MinatBakatStepState extends State<MinatBakatStep> {
  bool _isAddingCustom = false;
  final TextEditingController _customController = TextEditingController();

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _submitCustomItem() {
    final text = _customController.text.trim();
    if (text.isNotEmpty && !widget.selectedItems.contains(text)) {
      widget.onToggle(text);
    }
    setState(() {
      _isAddingCustom = false;
      _customController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Gabungkan opsi default dengan opsi custom yang sudah dipilih
    final allOptions = [
      ...minatBakatOptions,
      ...widget.selectedItems.where((item) => !minatBakatOptions.contains(item)),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Minat dan Bakat', style: AppTextStyles.h2),
          const SizedBox(height: 4),
          Text(
            'Apa yang kamu suka dan mahiri ?',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray500),
          ),
          const SizedBox(height: 24),

          Text.rich(
            TextSpan(
              text: 'Pilih minat dan bakat kamu (boleh lebih dari satu)',
              style: AppTextStyles.labelLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.blue900,
              ),
              children: [
                TextSpan(
                  text: ' *',
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Search field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.gray200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.search, size: 18, color: AppColors.gray400),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari minat dan bakatmu disini . . .',
                      hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.gray400),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Chip options
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: allOptions.map((item) {
              final isSelected = widget.selectedItems.contains(item);
              return GestureDetector(
                onTap: () => widget.onToggle(item),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.blue900 : AppColors.white,
                    border: Border.all(
                      color: isSelected ? AppColors.blue900 : AppColors.gray300,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isSelected ? AppColors.white : AppColors.gray700,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // +Lainnya...
          if (_isAddingCustom)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _customController,
                    autofocus: true,
                    style: AppTextStyles.bodySmall,
                    decoration: InputDecoration(
                      hintText: 'Ketik minat & bakat...',
                      hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.gray400),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.gray300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.blue500),
                      ),
                    ),
                    onSubmitted: (_) => _submitCustomItem(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _submitCustomItem,
                  icon: const Icon(LucideIcons.checkCircle2, color: AppColors.blue500),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isAddingCustom = false;
                      _customController.clear();
                    });
                  },
                  icon: const Icon(LucideIcons.xCircle, color: AppColors.gray400),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            )
          else
            GestureDetector(
              onTap: () {
                setState(() {
                  _isAddingCustom = true;
                });
              },
              child: Text(
                '+Lainnya . . .',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.gray400,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
