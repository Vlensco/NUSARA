import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cabe/features/onboarding/screens/onboarding_screen.dart';
import 'package:cabe/core/routing/main_navigation.dart';
import 'package:cabe/core/theme/app_colors.dart';
import 'package:cabe/core/services/ai_service.dart';
import 'package:cabe/features/profile_setup/screens/profile_setup_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  int _step = 0;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _startSequence();
  }

  void _startSequence() async {
    // Step 0: Light blue
    await Future.delayed(const Duration(milliseconds: 400));

    // Step 1: Dark blue 
    if (mounted) {
      setState(() => _step = 1);
      _controller.forward(from: 0.0);
    }
    await Future.delayed(const Duration(milliseconds: 1500));

    // Step 2: White background 
    if (mounted) {
      setState(() => _step = 2);
      _controller.forward(from: 0.8);
    }
    await Future.delayed(const Duration(milliseconds: 1500));

    // Cek koneksi ke Server AI (Consume endpoint / dan /health)
    await AiService.checkServerHealth();

    if (mounted) {
      // Check apakah user sudah login
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Cek apakah setup profil sudah selesai
        bool setupCompleted = false;
        try {
          final doc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
          final data = doc.data();
          if (data != null) {
            // Cek explicit flag, atau fallback: jika sudah ada nama_lengkap
            // (untuk kompatibilitas user lama yang tidak punya field setup_completed)
            final hasFlag = data['setup_completed'] == true;
            final hasNama = (data['nama_lengkap'] as String? ?? '').isNotEmpty;
            setupCompleted = hasFlag || (doc.exists && hasNama && !data.containsKey('setup_step'));
          }
        } catch (e) {
          debugPrint('Gagal cek setup status: $e');
          // Jika gagal fetch, amankan user ke home agar tidak terjebak
          setupCompleted = true;
        }

        if (!mounted) return;

        if (setupCompleted) {
          // Setup sudah selesai → langsung ke Home
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainNavigation()),
          );
        } else {
          // Setup belum selesai → lanjutkan dari step terakhir
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => const ProfileSetupScreen(resumeFromDraft: true),
            ),
          );
        }
      } else {
        // Belum login → ke Onboarding/Login
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Widget child;

    if (_step == 0) {
      bgColor = AppColors.blue200;
      child = const SizedBox(key: ValueKey('empty'));
    } else if (_step == 1) {
      bgColor = AppColors.blue900;
      child = AnimatedBuilder(
        key: const ValueKey('logo_white'),
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Image.asset(
          'assets/logo/logo_cabe_0.png',
          width: 220, 
          fit: BoxFit.contain,
        ),
      );
    } else {
      bgColor = AppColors.white;
      child = AnimatedBuilder(
        key: const ValueKey('logo_colored'),
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Image.asset(
          'assets/logo/logo_cabe_1.png',
          width: 320, 
          fit: BoxFit.contain,
        ),
      );
    }

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        color: bgColor,
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: child,
          ),
        ),
      ),
    );
  }
}
