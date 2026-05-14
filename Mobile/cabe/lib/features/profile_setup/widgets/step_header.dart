import 'package:flutter/material.dart';
import 'package:cabe/core/theme/app_colors.dart';
import 'package:cabe/core/theme/app_text_styles.dart';

/// Header untuk setiap step profile setup dengan progress bar.
class StepHeader extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onBack;

  const StepHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step text + Kembali
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Langkah $currentStep dari $totalSteps',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.gray500,
                  ),
                ),
                if (onBack != null)
                  GestureDetector(
                    onTap: onBack,
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_back_ios, size: 12, color: AppColors.blue900),
                        const SizedBox(width: 2),
                        Text(
                          'Kembali',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.blue900,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: currentStep / totalSteps,
                minHeight: 6,
                backgroundColor: AppColors.gray200,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.blue900),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
