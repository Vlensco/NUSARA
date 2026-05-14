import 'package:flutter/material.dart';
import 'package:cabe/core/routing/main_navigation.dart';

class WelcomeController {
  late AnimationController animController;
  late Animation<double> fadeAnimation;
  late Animation<double> scaleAnimation;

  void init(TickerProvider vsync, VoidCallback onComplete) {
    animController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 1200),
    );
    
    fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: animController, curve: Curves.easeIn),
    );
    
    scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: animController, curve: Curves.elasticOut),
    );
    
    animController.forward();

    // Trigger completion callback after delay
    Future.delayed(const Duration(seconds: 3), onComplete);
  }

  void dispose() {
    animController.dispose();
  }

  void goToHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainNavigation()),
      (route) => false,
    );
  }
}
