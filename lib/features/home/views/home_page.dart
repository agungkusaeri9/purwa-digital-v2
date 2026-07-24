import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purwa_digital/features/home/viewmodels/home_state.dart';
import 'package:purwa_digital/features/home/viewmodels/home_viewmodel.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:purwa_digital/features/notification/viewmodels/notification_viewmodel.dart';
import 'package:purwa_digital/features/notification/views/notification_page.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  String _formatRupiah(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return const Color(0xff10B981); // Emerald Green
      case 'failed':
        return const Color(0xffEF4444); // Crimson Red
      default:
        return const Color(0xffF59E0B); // Amber Yellow
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeViewModelProvider);
    final notificationState = ref.watch(notificationViewModelProvider);

    ref.listen<HomeState>(
      homeViewModelProvider,
      (previous, next) {
        if (next.isLoggedOut) {
          context.go('/login');
        }
        if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.errorMessage!),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );

    final profile = homeState.profile;
    final stats = homeState.dashboardData?.stats;
    final recentTx = homeState.dashboardData?.recentTransactions ?? [];

    return Scaffold(
      backgroundColor: Colors.white, // Putih bersih sesuai permintaan
      appBar: AppBar(
        toolbarHeight: 0, // Hapus Appbar, hanya sisakan status bar padding
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(homeViewModelProvider.notifier).loadHomeData(),
        child: homeState.isLoading && profile == null
            ? _buildSkeleton(context)
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                children: [
                  // 1. PPOB Style Custom Top Area (Greeting & Logout Button)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat Datang,',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            profile?.name ?? 'Pengguna',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff0F172A),
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationPage(),
                            ),
                          );
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(
                              Icons.notifications_none_rounded,
                              color: Color(0xff0F172A),
                              size: 26,
                            ),
                            if (notificationState.unreadCount > 0)
                              Positioned(
                                right: -2,
                                top: -2,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Color(0xffEF4444),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    notificationState.unreadCount > 99
                                        ? '99+'
                                        : notificationState.unreadCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      height: 1,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 2. Saldo Agen Card (OVO/Dana Style Wallet Card)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xff1E3A8A), Color(0xff3B82F6)], // Dark Blue to Light Blue
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xff3B82F6).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'SALDO KAS',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                (profile?.role ?? 'User').toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Menampilkan revenue sebagai representasi saldo agen
                        Text(
                          stats != null ? _formatRupiah(stats.totalRevenue) : 'Rp 0',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 1,
                          color: Colors.white.withOpacity(0.1),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildWalletInfo('Transaksi Hari Ini', stats != null ? stats.totalTransactions.toString() : '0'),
                            _buildWalletInfo('Status Server', 'ONLINE', isSuccess: true),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 3. PPOB Services Grid (Pulsa, Data, Game, Lainnya)
                  const Text(
                    'QUICK ACTION',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 5,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                    children: [
                      _buildPPOBItem(
                        context: context,
                        icon: Icons.phone_android_rounded,
                        label: 'Pulsa',
                        color: const Color(0xff3B82F6),
                        onTap: () => context.push('/pulsa-form'),
                      ),
                      _buildPPOBItem(
                        context: context,
                        icon: Icons.wifi_tethering_rounded,
                        label: 'Paket Data',
                        color: const Color(0xff06B6D4),
                        onTap: () => context.push('/transaction'),
                      ),
                      _buildPPOBItem(
                        context: context,
                        icon: Icons.bolt_rounded,
                        label: 'Token PLN',
                        color: const Color(0xffF59E0B),
                        onTap: () => context.push('/transaction'),
                      ),
                      _buildPPOBItem(
                        context: context,
                        icon: Icons.sports_esports_rounded,
                        label: 'Voucher',
                        color: const Color(0xff10B981),
                        onTap: () => context.push('/transaction'),
                      ),
                      _buildPPOBItem(
                        context: context,
                        icon: Icons.account_balance_wallet_rounded,
                        label: 'E-Wallet',
                        color: const Color(0xff8B5CF6),
                        onTap: () => context.push('/transaction'),
                      ),
                      _buildPPOBItem(
                        context: context,
                        icon: Icons.monitor_heart_rounded,
                        label: 'BPJS',
                        color: const Color(0xff14B8A6),
                        onTap: () => context.push('/transaction'),
                      ),
                      _buildPPOBItem(
                        context: context,
                        icon: Icons.water_drop_rounded,
                        label: 'PDAM',
                        color: const Color(0xff3B82F6),
                        onTap: () => context.push('/transaction'),
                      ),
                      _buildPPOBItem(
                        context: context,
                        icon: Icons.tv_rounded,
                        label: 'Internet & TV',
                        color: const Color(0xffF43F5E),
                        onTap: () => context.push('/transaction'),
                      ),
                      _buildPPOBItem(
                        context: context,
                        icon: Icons.receipt_long_rounded,
                        label: 'Angsuran',
                        color: const Color(0xffF59E0B),
                        onTap: () => context.push('/transaction'),
                      ),
                      _buildPPOBItem(
                        context: context,
                        icon: Icons.grid_view_rounded,
                        label: 'Lainnya',
                        color: const Color(0xff64748B),
                        onTap: () => context.push('/transaction'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // 4. Riwayat Transaksi (History Transaction)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'RIWAYAT TRANSAKSI',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: Colors.grey,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.push('/transaction'),
                        child: Text(
                          'Lihat Semua',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (recentTx.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 36),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Icon(Icons.history_rounded, size: 40, color: Colors.grey.shade300),
                          const SizedBox(height: 8),
                          Text(
                            'Belum ada riwayat transaksi.',
                            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recentTx.length > 5 ? 5 : recentTx.length,
                      itemBuilder: (context, index) {
                        final tx = recentTx[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xffF8FAFC), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xff0F172A).withOpacity(0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // 1. Icon Status / Kategori
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(tx.status).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  tx.status.toLowerCase() == 'success'
                                      ? Icons.check_circle_rounded
                                      : tx.status.toLowerCase() == 'failed'
                                          ? Icons.cancel_rounded
                                          : Icons.schedule_rounded,
                                  size: 20,
                                  color: _getStatusColor(tx.status),
                                ),
                              ),
                              const SizedBox(width: 12),
                              
                              // 2. Info Transaksi (Title & Subtitle)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (tx.category != null && tx.category!.isNotEmpty) ...[
                                      Text(
                                        tx.category!.toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xff3B82F6),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                    ],
                                    Text(
                                      tx.productName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13, // Diperkecil agar lebih elegan
                                        color: Color(0xff1E293B),
                                        letterSpacing: 0.1,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      tx.customerNo,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xff64748B), // Slate 500
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),

                              // 3. Nominal & Status Badge
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _formatRupiah(tx.sellingPrice),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                      color: Color(0xff0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(tx.status).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      tx.status.toUpperCase(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 9,
                                        letterSpacing: 0.5,
                                        color: _getStatusColor(tx.status),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildWalletInfo(String label, String value, {bool isSuccess = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: isSuccess ? const Color(0xff34D399) : Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPPOBItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.15)),
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Color(0xff334155),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.white,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        children: [
          // Greeting & Notification Skeleton
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 100, height: 12, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 8),
                  Container(width: 150, height: 18, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                ],
              ),
              Container(width: 32, height: 32, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
            ],
          ),
          const SizedBox(height: 20),
          
          // Saldo Card Skeleton
          Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          const SizedBox(height: 28),

          // Quick Action Skeleton
          Container(width: 100, height: 12, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
            children: List.generate(10, (index) => Column(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                const SizedBox(height: 8),
                Container(width: 40, height: 8, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
              ],
            )),
          ),
          const SizedBox(height: 32),

          // Riwayat Transaksi Skeleton
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(width: 120, height: 12, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
              Container(width: 60, height: 12, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(3, (index) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          )),
        ],
      ),
    );
  }
}
