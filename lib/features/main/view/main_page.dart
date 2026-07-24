import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purwa_digital/features/favorite/views/favorite_page.dart';
import 'package:purwa_digital/features/home/views/home_page.dart';
import 'package:purwa_digital/features/main/viewmodel/main_viewmodel.dart';
import 'package:purwa_digital/features/profile/views/profile_page.dart';
import 'package:purwa_digital/features/transaction/views/transaction_page.dart';
import 'package:purwa_digital/features/wallet/views/wallet_page.dart';

class MainPage extends ConsumerWidget {
  const MainPage({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mainViewModelProvider);
    final primaryColor = Theme.of(context).primaryColor;

    final pages = [
      const HomePage(),
      const FavoritePage(),
      const TransactionPage(),
      const WalletPage(),
      const ProfilePage(),
    ];

    final navItems = [
      _NavItemData(
        label: 'Beranda',
        activeIcon: Icons.home_rounded,
        inactiveIcon: Icons.home_outlined,
      ),
      _NavItemData(
        label: 'Favorit',
        activeIcon: Icons.favorite_rounded,
        inactiveIcon: Icons.favorite_border_rounded,
      ),
      _NavItemData(
        label: 'Transaksi',
        activeIcon: Icons.receipt_long_rounded,
        inactiveIcon: Icons.receipt_long_outlined,
      ),
      _NavItemData(
        label: 'Uang Kas',
        activeIcon: Icons.account_balance_wallet_rounded,
        inactiveIcon: Icons.account_balance_wallet_outlined,
      ),
      _NavItemData(
        label: 'Profil',
        activeIcon: Icons.person_rounded,
        inactiveIcon: Icons.person_outline,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: state.currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(navItems.length, (index) {
                final item = navItems[index];
                final isSelected = state.currentIndex == index;

                return Expanded(
                  child: InkWell(
                    onTap: () {
                      ref.read(mainViewModelProvider.notifier).changeTab(index);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Icon Container dengan Highlight lembut saat aktif
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              isSelected ? item.activeIcon : item.inactiveIcon,
                              color: isSelected ? primaryColor : const Color(0xff94A3B8),
                              size: 22,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Label Selalu Berada di Bawah Icon
                          Text(
                            item.label,
                            style: TextStyle(
                              color: isSelected ? primaryColor : const Color(0xff94A3B8),
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final String label;
  final IconData activeIcon;
  final IconData inactiveIcon;

  _NavItemData({
    required this.label,
    required this.activeIcon,
    required this.inactiveIcon,
  });
}
