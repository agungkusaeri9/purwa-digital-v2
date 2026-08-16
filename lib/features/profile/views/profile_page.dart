import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purwa_digital/features/home/viewmodels/home_viewmodel.dart';
import 'package:purwa_digital/features/home/viewmodels/home_state.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/widgets/app_error_dialog.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _biometricEnabled = false;
  bool _checkingBiometric = true;

  @override
  void initState() {
    super.initState();
    _loadBiometricStatus();
  }

  Future<void> _loadBiometricStatus() async {
    final biometricService = ref.read(biometricServiceProvider);
    final enabled = await biometricService.isBiometricEnabled();
    if (mounted) {
      setState(() {
        _biometricEnabled = enabled;
        _checkingBiometric = false;
      });
    }
  }

  Future<void> _toggleBiometric(bool value, String? email) async {
    final biometricService = ref.read(biometricServiceProvider);

    if (value) {
      final canUse = await biometricService.canCheckBiometrics();
      if (!canUse) {
        if (mounted) {
          showErrorToastAlert(context, 'Perangkat Anda tidak mendukung biometrik.');
        }
        return;
      }

      final authenticated = await biometricService.authenticate();
      if (!authenticated) {
        if (mounted) {
          showErrorToastAlert(context, 'Verifikasi sidik jari gagal.');
        }
        return;
      }

      if (mounted) {
        await _showCredentialDialog(biometricService, email);
      }
    } else {
      await biometricService.clearCredentials();
      setState(() => _biometricEnabled = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sidik jari berhasil dinonaktifkan.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _showCredentialDialog(BiometricService service, String? prefillEmail) async {
    final emailCtrl = TextEditingController(text: prefillEmail ?? '');
    final passCtrl = TextEditingController();
    bool obscure = true;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Icon(Icons.fingerprint, color: Theme.of(context).primaryColor),
              const SizedBox(width: 10),
              const Text('Simpan Kredensial', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Masukkan username dan password Anda. Kredensial ini akan disimpan secara terenkripsi di perangkat.',
                style: TextStyle(fontSize: 12, color: Color(0xff64748B)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailCtrl,
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passCtrl,
                obscureText: obscure,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    onPressed: () => setD(() => obscure = !obscure),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (emailCtrl.text.trim().isEmpty || passCtrl.text.isEmpty) return;
                await service.saveCredentials(emailCtrl.text.trim(), passCtrl.text);
                await service.setBiometricEnabled(true);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Simpan & Aktifkan'),
            ),
          ],
        ),
      ),
    );

    final enabled = await service.isBiometricEnabled();
    if (mounted) {
      setState(() => _biometricEnabled = enabled);
      if (enabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sidik jari berhasil diaktifkan!'),
            backgroundColor: Color(0xff10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xff14B8A6).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.info_outline_rounded, color: Color(0xff14B8A6), size: 22),
            ),
            const SizedBox(width: 12),
            const Text('Purwa Digital', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aplikasi Layanan Keuangan Digital & PPOB Terlengkap & Terpercaya.',
              style: TextStyle(fontSize: 13, color: Color(0xff475569), height: 1.4),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Versi Aplikasi', style: TextStyle(fontSize: 12, color: Colors.grey)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xffF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('v1.0.0', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xff0F172A))),
                ),
              ],
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff14B8A6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSleekToggle({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 38,
        height: 22,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: value ? const Color(0xff10B981) : const Color(0xffCBD5E1),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeViewModelProvider);

    ref.listen<HomeState>(
      homeViewModelProvider,
      (previous, next) {
        if (next.isLoggedOut) {
          context.go('/login');
        }
      },
    );

    final profile = homeState.profile;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Profil Saya',
          style: TextStyle(
            color: Color(0xff0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Profile Header Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 8, bottom: 24, left: 20, right: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryColor.withOpacity(0.1),
                          border: Border.all(color: primaryColor.withOpacity(0.2), width: 3),
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          size: 36,
                          color: primaryColor,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    profile?.name ?? 'Memuat...',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xffF1F5F9),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      profile?.email ?? 'Memuat...',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff64748B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Menu Utama Tight Group
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: _buildMenuGroup(
                context,
                children: [
                  _buildMenuTile(
                    icon: Icons.person_outline_rounded,
                    title: 'Edit Profil',
                    iconColor: const Color(0xff3B82F6),
                    isSoon: true,
                  ),
                  const Divider(height: 1, color: Color(0xffF1F5F9), indent: 48),
                  _buildMenuTile(
                    icon: Icons.lock_outline_rounded,
                    title: 'Ubah Kata Sandi',
                    iconColor: const Color(0xffF59E0B),
                    isSoon: true,
                  ),
                  const Divider(height: 1, color: Color(0xffF1F5F9), indent: 48),

                  // Biometric Fingerprint (ACTIVE)
                  ListTile(
                    dense: true,
                    visualDensity: const VisualDensity(vertical: -2),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    leading: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xff10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.fingerprint, color: Color(0xff10B981), size: 18),
                    ),
                    title: const Text(
                      'Sidik Jari / Biometrik',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff0F172A),
                      ),
                    ),
                    subtitle: Text(
                      _biometricEnabled ? 'Aktif' : 'Nonaktif',
                      style: TextStyle(
                        fontSize: 10,
                        color: _biometricEnabled ? const Color(0xff10B981) : Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: _checkingBiometric
                        ? const SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : _buildSleekToggle(
                            value: _biometricEnabled,
                            onChanged: (val) => _toggleBiometric(val, profile?.email),
                          ),
                  ),

                  const Divider(height: 1, color: Color(0xffF1F5F9), indent: 48),
                  _buildMenuTile(
                    icon: Icons.help_outline_rounded,
                    title: 'Pusat Bantuan',
                    iconColor: const Color(0xff6366F1),
                    isSoon: true,
                  ),
                  const Divider(height: 1, color: Color(0xffF1F5F9), indent: 48),
                  _buildMenuTile(
                    icon: Icons.gavel_rounded,
                    title: 'Syarat & Ketentuan',
                    iconColor: const Color(0xff8B5CF6),
                    isSoon: true,
                  ),
                  const Divider(height: 1, color: Color(0xffF1F5F9), indent: 48),
                  
                  // Tentang Aplikasi (ACTIVE)
                  _buildMenuTile(
                    icon: Icons.info_outline_rounded,
                    title: 'Tentang Aplikasi',
                    iconColor: const Color(0xff14B8A6),
                    trailing: const Text(
                      'v1.0.0',
                      style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                    onTap: () => _showAboutDialog(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tombol Keluar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  _showLogoutDialog(context, ref);
                },
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text(
                  'Keluar dari Akun',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffFEF2F2),
                  foregroundColor: const Color(0xffEF4444),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  minimumSize: const Size(double.infinity, 46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuGroup(BuildContext context, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required Color iconColor,
    Widget? trailing,
    bool isSoon = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(vertical: -2),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xff0F172A),
            ),
          ),
          if (isSoon) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
              decoration: BoxDecoration(
                color: const Color(0xffF59E0B),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'SOON',
                style: TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ],
      ),
      trailing: trailing ??
          Icon(
            Icons.chevron_right_rounded,
            color: Colors.grey.shade400,
            size: 18,
          ),
      onTap: () {
        if (isSoon) {
          showErrorToastAlert(context, 'Fitur $title akan segera hadir!');
        } else if (onTap != null) {
          onTap();
        }
      },
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Keluar Akun?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Anda yakin ingin keluar dari akun Purwa Digital Anda?',
          style: TextStyle(color: Color(0xff475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(homeViewModelProvider.notifier).logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Ya, Keluar'),
          ),
        ],
      ),
    );
  }
}
