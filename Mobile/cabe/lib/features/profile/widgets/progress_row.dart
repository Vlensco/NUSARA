import 'package:flutter/material.dart';

class ProgressRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String score;
  final double progress;

  const ProgressRow({
    super.key,
    required this.icon,
    required this.title,
    required this.score,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey.shade600),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title, 
                  style: TextStyle(
                    fontSize: 13, 
                    color: Colors.grey.shade600, 
                    fontWeight: FontWeight.w500
                  )
                ),
              ),
              Text(
                score,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFE6EBF0),
              color: const Color(0xFF002147),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
