import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Image.asset(
            'assets/login/headerlogin.png',
            width: double.infinity,
            fit: BoxFit.fitWidth,
          ),
          Positioned(
            bottom: 0,
            child: Image.asset(
              'assets/logo/logo_cabe_1.png',
              height: 100,
            ),
          ),
        ],
      ),
    );
  }
}
