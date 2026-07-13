import 'package:flutter/material.dart';
import 'package:purwa_digital/features/profile/widgets/logout_button.dart';
import 'package:purwa_digital/features/profile/widgets/profile_header.dart';
import 'package:purwa_digital/features/profile/widgets/profile_section.dart';
import 'package:purwa_digital/features/profile/widgets/profile_tile.dart';
import 'package:purwa_digital/features/profile/widgets/quick_action.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: const [
            ProfileHeader(),
            SizedBox(height: 24),
            QuickAction(),
            SizedBox(height: 32),
            ProfileSection(
              title: "AKUN",
              children: [
                ProfileTile(
                  icon: Icons.person_outline,
                  title: "Edit Profil",
                ),
                ProfileTile(
                  icon: Icons.lock_outline,
                  title: "Ubah Password",
                ),
                ProfileTile(
                  icon: Icons.photo_camera_outlined,
                  title: "Ubah Foto Profil",
                ),
              ],
            ),
            SizedBox(height: 24),
            ProfileSection(
              title: "LAPORAN",
              children: [
                ProfileTile(
                  icon: Icons.calendar_today_outlined,
                  title: "Laporan Harian",
                ),
                ProfileTile(
                  icon: Icons.bar_chart_outlined,
                  title: "Laporan Bulanan",
                ),
                ProfileTile(
                  icon: Icons.receipt_long_outlined,
                  title: "Laporan Transaksi",
                ),
                ProfileTile(
                  icon: Icons.account_balance_wallet_outlined,
                  title: "Laporan Dompet",
                ),
              ],
            ),
            SizedBox(height: 24),
            ProfileSection(
              title: "PENGATURAN",
              children: [
                ProfileTile(
                  icon: Icons.settings_outlined,
                  title: "Pengaturan",
                ),
                ProfileTile(
                  icon: Icons.notifications_outlined,
                  title: "Notifikasi",
                ),
              ],
            ),
            SizedBox(height: 30),
            LogoutButton(),
            SizedBox(height: 20),
            Center(
              child: Text("Versi 1.0.0"),
            ),
          ],
        ),
      ),
    );
  }
}
