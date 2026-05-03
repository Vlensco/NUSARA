import 'package:flutter/material.dart';
import 'package:cabe/core/routing/main_navigation.dart';
import 'package:cabe/core/theme/app_colors.dart';

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

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
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
