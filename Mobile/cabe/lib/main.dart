import 'package:flutter/material.dart';
import 'views/splash_screen.dart';
// HAPUS import 'views/home_page.dart'; karena menyebabkan error file not found

void main() {
  runApp(const CaBeApp());
}

class CaBeApp extends StatelessWidget {
  const CaBeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CaBe - Cari Beasiswa',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF001F3F),
      ),
      // Gunakan SplashScreen sebagai awal,
      // jangan panggil HomeScreen di sini karena alurnya: Splash -> Home
      home: const SplashScreen(),
    );
  }
}
