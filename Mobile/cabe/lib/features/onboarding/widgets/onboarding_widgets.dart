import 'package:flutter/material.dart';
import 'package:cabe/core/theme/app_colors.dart';
import 'package:cabe/core/theme/app_text_styles.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Dot indicator for onboarding pages.
class OnboardingDots extends StatelessWidget {
  final int currentIndex;
  final int totalPages;

  const OnboardingDots({
    super.key,
    required this.currentIndex,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalPages,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: currentIndex == i ? 24 : 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: currentIndex == i ? AppColors.blue900 : AppColors.gray300,
          ),
        ),
      ),
    );
  }
}

/// Navigation buttons row for onboarding (Skip/Back — Next/Get Start!).
class OnboardingNavButtons extends StatelessWidget {
  final int currentIndex;
  final int totalPages;
  final VoidCallback onSkip;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onGetStarted;

  const OnboardingNavButtons({
    super.key,
    required this.currentIndex,
    required this.totalPages,
    required this.onSkip,
    required this.onBack,
    required this.onNext,
    required this.onGetStarted,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFirst = currentIndex == 0;
    final bool isLast = currentIndex == totalPages - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: isFirst ? onSkip : onBack,
          child: Text(
            isFirst ? 'Skip' : 'Back',
            style: AppTextStyles.labelLarge.copyWith(
              color: const Color(0xFFD36A24),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: isLast ? onGetStarted : onNext,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.blue900,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isLast ? 'Get Start!' : 'Next',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (!isLast) ...[
                const SizedBox(width: 4),
                const Icon(LucideIcons.arrowRight, size: 16),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
