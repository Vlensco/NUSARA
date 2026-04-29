import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cabe/core/theme/app_text_styles.dart';
import 'package:cabe/core/theme/app_colors.dart';
import 'features/splash/screens/splash_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CaBe - Cari Beasiswa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.blue500),
        textTheme: AppTextStyles.textTheme,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

