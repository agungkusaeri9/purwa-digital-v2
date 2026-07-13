import 'package:flutter/material.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.logout),
      label: const Text("Keluar"),
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
      ),
    );
  }
}
