import 'package:flutter/material.dart';

class ProfileMenu {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  const ProfileMenu({
    required this.title,
    required this.icon,
    this.onTap,
  });
}
