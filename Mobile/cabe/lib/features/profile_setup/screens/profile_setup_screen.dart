import 'package:flutter/material.dart';
import 'package:cabe/core/theme/app_colors.dart';
import 'package:cabe/shared_widgets/app_button.dart';
import 'package:cabe/features/profile_setup/widgets/step_header.dart';
import 'package:cabe/features/profile_setup/controllers/profile_setup_controller.dart';
import 'package:cabe/features/profile_setup/widgets/profile_setup_content.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  late final ProfileSetupController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ProfileSetupController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final bool isLast = _controller.currentStep == _controller.totalSteps - 1;

          return Column(
            children: [
              // Step header
              StepHeader(
                currentStep: _controller.currentStep + 1,
                totalSteps: _controller.totalSteps,
                onBack: _controller.currentStep > 0 ? _controller.prevStep : null,
              ),

              // Step content
              Expanded(
                child: ProfileSetupContent(controller: _controller),
              ),

              // Bottom buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  child: isLast
                      ? AppButton(
                          label: 'Mulai Jelajahi',
                          variant: _controller.isCurrentStepValid 
                            ? AppButtonVariant.primary 
                            : AppButtonVariant.disabled,
                          isFullWidth: true,
                          suffixIcon: Icon(
                            LucideIcons.arrowRight, 
                            size: 18, 
                            color: _controller.isCurrentStepValid ? AppColors.white : AppColors.coolGray400,
                          ),
                          onPressed: () => _controller.nextStep(context),
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: AppButton(
                                label: 'Lewati',
                                variant: AppButtonVariant.secondary,
                                onPressed: () => _controller.skip(context),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: AppButton(
                                label: 'Lanjut',
                                variant: _controller.isCurrentStepValid 
                                  ? AppButtonVariant.primary 
                                  : AppButtonVariant.disabled,
                                suffixIcon: Icon(
                                  LucideIcons.arrowRight, 
                                  size: 18, 
                                  color: _controller.isCurrentStepValid ? AppColors.white : AppColors.coolGray400,
                                ),
                                onPressed: () => _controller.nextStep(context),
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
