import 'package:flutter/material.dart';

class QuickActionItem extends StatelessWidget {
  const QuickActionItem({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
  });

  final IconData icon;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Icon(icon),
        ),
        const SizedBox(height: 10),
        Text(title),
      ],
    );
  }
}
