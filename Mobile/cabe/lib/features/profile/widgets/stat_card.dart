import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final String count;
  final String label;
  final Color iconColor;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.icon,
    required this.count,
    required this.label,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black12, width: 0.5),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12, 
              blurRadius: 6, 
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 4),
            Text(
              count,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
            ),
            const SizedBox(height: 0),
            Text(
              label,
              style: const TextStyle(color: Colors.black45, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
