import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purwa_digital/features/home/viewmodels/home_state.dart';
import 'package:purwa_digital/features/home/viewmodels/home_viewmodel.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:purwa_digital/features/notification/viewmodels/notification_viewmodel.dart';
import 'package:purwa_digital/features/notification/views/notification_page.dart';
import 'package:shimmer/shimmer.dart';
import '../../transaction/views/transaction_detail_page.dart';
import '../../transaction/models/ppob_transaction_model.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/app_error_dialog.dart';
import '../../ppob/models/ppob_category_model.dart';
import '../../ppob/viewmodels/pulsa_form_viewmodel.dart';

final ppobCategoriesProvider =
    FutureProvider.autoDispose<List<PPOBCategoryModel>>((ref) async {
  final service = ref.watch(ppobServiceProvider);
  return service.getCategoriesList();
});

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
      case 'sukses':
      case 'success':
        return const Color(0xff10B981); // Emerald Green
      case 'gagal':
      case 'failed':
        return const Color(0xffEF4444); // Crimson Red
      case 'processing':
      case 'proses':
      case 'pending':
      default:
        return const Color(0xffF59E0B); // Amber Yellow
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeViewModelProvider);
    final notificationState = ref.watch(notificationViewModelProvider);
    final categoriesAsync = ref.watch(ppobCategoriesProvider);
    final categoriesList = categoriesAsync.value ?? [];

    String? getLogo(String label) {
      final labelLower = label.toLowerCase();
      for (final cat in categoriesList) {
        final catNameLower = cat.name.toLowerCase();
        final catSlugLower = cat.slug.toLowerCase();
        if (catNameLower == labelLower ||
            catSlugLower == labelLower ||
            (labelLower == 'paket data' &&
                (catNameLower == 'data' || catSlugLower == 'data')) ||
            (labelLower == 'token pln' &&
                (catNameLower == 'pln' || catSlugLower == 'pln')) ||
            (labelLower == 'game' &&
                (catNameLower == 'games' || catSlugLower == 'games'))) {
          return cat.logoUrl;
        }
      }
      return null;
    }

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

    final primaryColor = Theme.of(context).primaryColor;
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
        onRefresh: () =>
            ref.read(homeViewModelProvider.notifier).loadHomeData(),
        child: homeState.isLoading && profile == null
            ? _buildSkeleton(context)
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 12.0),
                children: [
                  // 1. PPOB Style Custom Top Area (Greeting & Logout Button)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: const Color(0xffE2E8F0)),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                'assets/images/logo.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Purwa Digital',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                profile?.name ?? 'Pengguna',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff0F172A),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context, rootNavigator: true).push(
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
                                        : notificationState.unreadCount
                                            .toString(),
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
                        colors: [
                          Color(0xff1E3A8A),
                          Color(0xff3B82F6)
                        ], // Dark Blue to Light Blue
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
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
                        // Menampilkan Saldo Kas operasional (sesuai menu Uang Kas)
                        Text(
                          stats != null
                              ? _formatRupiah(stats.cashBalance)
                              : 'Rp 0',
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
                            _buildWalletInfo(
                                'Saldo Digiflazz',
                                stats != null
                                    ? _formatRupiah(stats.digiflazzBalance)
                                    : 'Rp 0'),
                            _buildWalletInfo(
                                'Transaksi',
                                stats != null
                                    ? stats.totalTransactions.toString()
                                    : '0'),
                            _buildWalletInfo('Status Server', 'ONLINE',
                                isSuccess: true),
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
                        logoUrl: getLogo('Pulsa'),
                        onTap: () => context.push('/pulsa-brand'),
                      ),
                      _buildPPOBItem(
                        context: context,
                        icon: Icons.wifi_tethering_rounded,
                        label: 'Paket Data',
                        color: const Color(0xff06B6D4),
                        logoUrl: getLogo('Paket Data'),
                        onTap: () => context.push('/data-brand'),
                      ),
                      _buildPPOBItem(
                        context: context,
                        icon: Icons.bolt_rounded,
                        label: 'Token PLN',
                        color: const Color(0xffF59E0B),
                        logoUrl: getLogo('Token PLN'),
                        onTap: () => context.push('/pln-menu'),
                      ),
                      _buildPPOBItem(
                        context: context,
                        icon: Icons.sports_esports_rounded,
                        label: 'Game',
                        color: const Color(0xff10B981),
                        logoUrl: getLogo('Game'),
                        onTap: () => context.push('/game-brand'),
                      ),
                      _buildPPOBItem(
                        context: context,
                        icon: Icons.account_balance_wallet_rounded,
                        label: 'E-Wallet',
                        color: const Color(0xff8B5CF6),
                        logoUrl: getLogo('E-Wallet'),
                        onTap: () => context.push('/ewallet-brand'),
                      ),
                      _buildPPOBItem(
                        context: context,
                        icon: Icons.monitor_heart_rounded,
                        label: 'BPJS',
                        color: const Color(0xff14B8A6),
                        logoUrl: getLogo('BPJS'),
                        onTap: () => context.push('/bpjs-menu'),
                      ),
                      _buildPPOBItem(
                        context: context,
                        icon: Icons.water_drop_rounded,
                        label: 'PDAM',
                        color: const Color(0xff06B6D4),
                        logoUrl: getLogo('PDAM'),
                        onTap: () => context.push('/pdam-brand'),
                      ),
                      _buildPPOBItem(
                        context: context,
                        icon: Icons.wifi_rounded,
                        label: 'Internet Pasca',
                        color: const Color(0xff8B5CF6),
                        logoUrl: getLogo('Internet Pasca'),
                        onTap: () => context.push('/internet-brand'),
                      ),
                      _buildPPOBItem(
                        context: context,
                        icon: Icons.receipt_long_rounded,
                        label: 'Angsuran',
                        color: const Color(0xffF59E0B),
                        logoUrl: getLogo('Angsuran'),
                        onTap: () {},
                        isSoon: true,
                      ),
                      _buildPPOBItem(
                        context: context,
                        icon: Icons.grid_view_rounded,
                        label: 'Lainnya',
                        color: const Color(0xff64748B),
                        logoUrl: getLogo('Lainnya'),
                        onTap: () {},
                        isSoon: true,
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
                        onTap: () => context.go(AppRoutes.transactions),
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
                          Icon(Icons.history_rounded,
                              size: 40, color: Colors.grey.shade300),
                          const SizedBox(height: 8),
                          Text(
                            'Belum ada riwayat transaksi.',
                            style: TextStyle(
                                color: Colors.grey.shade400, fontSize: 12),
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
                        return GestureDetector(
                          onTap: () {
                            context.push(
                              AppRoutes.transactionDetail,
                              extra: PPOBTransactionModel(
                                id: tx.id,
                                refId: tx.refId,
                                buyerSkuCode: tx.buyerSkuCode,
                                productName: tx.productName,
                                customerNo: tx.customerNo,
                                price: tx.price,
                                markupPrice: tx.sellingPrice - tx.price,
                                sellingPrice: tx.sellingPrice,
                                status: tx.status,
                                createdAt: tx.createdAt,
                                category: tx.category,
                                brand: tx.brand,
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: const Color(0xffF8FAFC), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xff0F172A).withOpacity(0.02),
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
                                    color: _getStatusColor(tx.status)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    tx.status.toLowerCase() == 'success' ||
                                            tx.status.toLowerCase() == 'sukses'
                                        ? Icons.check_circle_rounded
                                        : tx.status.toLowerCase() == 'failed' ||
                                                tx.status.toLowerCase() ==
                                                    'gagal'
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (tx.category != null &&
                                          tx.category!.isNotEmpty) ...[
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
                                          fontSize: 13,
                                          color: Color(0xff1E293B),
                                          letterSpacing: 0.1,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        tx.customerNo,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xff64748B),
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
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(tx.status)
                                            .withOpacity(0.1),
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
                          ),
                        );
                      },
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildWalletInfo(String label, String value,
      {bool isSuccess = false}) {
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
    bool isSoon = false,
    String? logoUrl,
  }) {
    final hasLogo = logoUrl != null && logoUrl.isNotEmpty;
    return GestureDetector(
      onTap: isSoon
          ? () {
              showErrorToastAlert(context, 'Fitur $label akan segera hadir!');
            }
          : onTap,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 46,
                height: 46,
                padding: hasLogo
                    ? const EdgeInsets.all(8)
                    : const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      isSoon ? Colors.grey.shade100 : color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: isSoon
                          ? Colors.grey.shade200
                          : color.withOpacity(0.15)),
                ),
                child: hasLogo
                    ? Image.network(
                        logoUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          icon,
                          color: isSoon ? Colors.grey.shade400 : color,
                          size: 22,
                        ),
                      )
                    : Icon(
                        icon,
                        color: isSoon ? Colors.grey.shade400 : color,
                        size: 22,
                      ),
              ),
              if (isSoon)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xffF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: const Color(0xffCBD5E1), width: 0.5),
                    ),
                    child: const Text(
                      'SOON',
                      style: TextStyle(
                        fontSize: 6,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: isSoon ? Colors.grey.shade400 : const Color(0xff334155),
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
                  Container(
                      width: 100,
                      height: 12,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 8),
                  Container(
                      width: 150,
                      height: 18,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4))),
                ],
              ),
              Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle)),
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
          Container(
              width: 100,
              height: 12,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
            children: List.generate(
                10,
                (index) => Column(
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
                        Container(
                            width: 40,
                            height: 8,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4))),
                      ],
                    )),
          ),
          const SizedBox(height: 32),

          // Riwayat Transaksi Skeleton
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  width: 120,
                  height: 12,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4))),
              Container(
                  width: 60,
                  height: 12,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4))),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(
              3,
              (index) => Container(
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
