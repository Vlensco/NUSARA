import 'package:flutter/material.dart';
import 'package:cabe/core/theme/app_colors.dart';
import 'package:cabe/core/theme/app_text_styles.dart';
import 'package:cabe/features/onboarding/data/onboarding_data.dart';
import 'package:cabe/features/onboarding/widgets/onboarding_widgets.dart';
import 'package:cabe/features/onboarding/controllers/onboarding_controller.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final OnboardingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = OnboardingController();
    _controller.init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              // Layer 1 — Background wave
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Image.asset(
                    onboardingPages[_controller.currentIndex].bgPath,
                    key: ValueKey('bg_${_controller.currentIndex}'),
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),

              // Layer 2 — Content
              SafeArea(
                child: Column(
                  children: [
                    // Logo
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Center(
                        child: Image.asset('assets/logo/logo_cabe_1.png', height: 80),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Illustration (swipeable)
                    Expanded(
                      flex: 4,
                      child: PageView.builder(
                        controller: _controller.pageController,
                        onPageChanged: _controller.setIndex,
                        itemCount: onboardingPages.length,
                        itemBuilder: (_, i) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxHeight: 260),
                                child: Image.asset(onboardingPages[i].imagePath, fit: BoxFit.contain),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Text + Dots + Buttons
                    Expanded(
                      flex: 5,
                      child: GestureDetector(
                        onHorizontalDragEnd: (details) {
                          if (details.primaryVelocity == null) return;
                          if (details.primaryVelocity! < 0 && _controller.currentIndex < onboardingPages.length - 1) {
                            _controller.nextPage();
                          } else if (details.primaryVelocity! > 0 && _controller.currentIndex > 0) {
                            _controller.prevPage();
                          }
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              const Spacer(),
                              // Title
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Text(
                                  onboardingPages[_controller.currentIndex].title,
                                  key: ValueKey('title_${_controller.currentIndex}'),
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.h2.copyWith(
                                    fontWeight: FontWeight.w900,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Description
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Text(
                                  onboardingPages[_controller.currentIndex].description,
                                  key: ValueKey('desc_${_controller.currentIndex}'),
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.gray500,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Dots
                              OnboardingDots(
                                currentIndex: _controller.currentIndex,
                                totalPages: onboardingPages.length,
                              ),
                              const SizedBox(height: 24),
                              // Nav Buttons
                              OnboardingNavButtons(
                                currentIndex: _controller.currentIndex,
                                totalPages: onboardingPages.length,
                                onSkip: () => _controller.goToAuthLanding(context),
                                onBack: _controller.prevPage,
                                onNext: _controller.nextPage,
                                onGetStarted: () => _controller.goToAuthLanding(context),
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
