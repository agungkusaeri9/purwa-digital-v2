import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purwa_digital/features/activity/views/activity_page.dart';
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
    final colorScheme = Theme.of(context).colorScheme;

    final pages = [
      const HomePage(),
      const WalletPage(),
      const TransactionPage(),
      const ActivityPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: state.currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: colorScheme.surface,
          indicatorColor: Colors.transparent,
          iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
            (states) {
              if (states.contains(WidgetState.selected)) {
                return IconThemeData(
                  color: Colors.green.shade500,
                  size: 25,
                );
              }

              return IconThemeData(
                color: Colors.grey.shade500,
                size: 25,
              );
            },
          ),
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
            (states) {
              if (states.contains(WidgetState.selected)) {
                return TextStyle(
                  color: Colors.green.shade500,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                );
              }

              return TextStyle(
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              );
            },
          ),
        ),
        child: NavigationBar(
          selectedIndex: state.currentIndex,
          onDestinationSelected: (index) {
            ref.read(mainViewModelProvider.notifier).changeTab(index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.wallet_outlined),
              selectedIcon: Icon(Icons.wallet_outlined),
              label: 'Dompet',
            ),
            NavigationDestination(
              icon: Icon(Icons.shopping_cart_outlined),
              selectedIcon: Icon(Icons.shopping_cart_outlined),
              label: 'Transaksi',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined),
              selectedIcon: Icon(Icons.history_outlined),
              label: 'Aktivitas',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person_outline),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
