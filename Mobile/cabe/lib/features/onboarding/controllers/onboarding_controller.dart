import 'package:flutter/material.dart';
import 'package:cabe/features/auth/screens/auth_landing_screen.dart';

class OnboardingController extends ChangeNotifier {
  int currentIndex = 0;
  late final PageController pageController;

  void init() {
    pageController = PageController();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void goToAuthLanding(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AuthLandingScreen()),
    );
  }

  void nextPage() {
    pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void prevPage() {
    pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void setIndex(int index) {
    currentIndex = index;
    notifyListeners();
  }
}
