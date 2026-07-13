import 'package:flutter/material.dart';
import 'package:purwa_digital/features/profile/widgets/quick_action_item.dart';

class QuickAction extends StatelessWidget {
  const QuickAction({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: const [
        QuickActionItem(
          icon: Icons.person_outline,
          title: "Edit Profil",
          color: Color(0xffDDF8EE),
        ),
        QuickActionItem(
          icon: Icons.shield_outlined,
          title: "Password",
          color: Color(0xffEAF2FF),
        ),
        QuickActionItem(
          icon: Icons.receipt_long_outlined,
          title: "Laporan",
          color: Color(0xffFFF6DD),
        ),
      ],
    );
  }
}
