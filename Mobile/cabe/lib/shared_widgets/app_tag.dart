import 'package:flutter/material.dart';
import 'package:cabe/core/theme/app_colors.dart';

enum AppTagVariant { dark, lightBlue }

class AppTag extends StatelessWidget {
  final String label;
  final AppTagVariant variant;

  const AppTag({
    super.key,
    required this.label,
    this.variant = AppTagVariant.dark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: _padding,
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: _textColor,
          fontSize: _fontSize,
          fontWeight: _fontWeight,
        ),
      ),
    );
  }

  EdgeInsets get _padding {
    switch (variant) {
      case AppTagVariant.dark:
        return const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
      case AppTagVariant.lightBlue:
        return const EdgeInsets.symmetric(horizontal: 14, vertical: 8);
    }
  }

  Color get _backgroundColor {
    switch (variant) {
      case AppTagVariant.dark:
        return Colors.black;
      case AppTagVariant.lightBlue:
        return const Color(0xFFE6F0FA);
    }
  }

  Color get _textColor {
    switch (variant) {
      case AppTagVariant.dark:
        return Colors.white;
      case AppTagVariant.lightBlue:
        return AppColors.blue900;
    }
  }

  double get _fontSize {
    switch (variant) {
      case AppTagVariant.dark:
        return 10.0;
      case AppTagVariant.lightBlue:
        return 12.0;
    }
  }

  FontWeight get _fontWeight {
    switch (variant) {
      case AppTagVariant.dark:
        return FontWeight.normal;
      case AppTagVariant.lightBlue:
        return FontWeight.w600;
    }
  }
}
