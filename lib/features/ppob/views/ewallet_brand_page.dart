import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../models/ppob_brand_model.dart';
import '../viewmodels/pulsa_form_viewmodel.dart';
import '../../../../core/router/app_routes.dart';

final ewalletBrandsProvider = FutureProvider.autoDispose<List<PPOBBrandModel>>((ref) async {
  final service = ref.watch(ppobServiceProvider);
  final defaultEWallets = [
    PPOBBrandModel(id: 1, name: 'DANA', slug: 'dana', logoUrl: ''),
    PPOBBrandModel(id: 2, name: 'GO PAY', slug: 'go-pay', logoUrl: ''),
    PPOBBrandModel(id: 3, name: 'OVO', slug: 'ovo', logoUrl: ''),
    PPOBBrandModel(id: 4, name: 'SHOPEE PAY', slug: 'shopee-pay', logoUrl: ''),
  ];

  try {
    var list = await service.getBrands(category: 'e-money');
    if (list.isEmpty) {
      list = await service.getBrands(category: 'emoney');
    }

    if (list.isNotEmpty) {
      final targets = ['dana', 'gopay', 'go-pay', 'go pay', 'ovo', 'shopee', 'linkaja', 'link aja'];
      final Map<String, PPOBBrandModel> uniqueBrands = {};

      for (final b in list) {
        final lower = b.name.toLowerCase();
        for (final t in targets) {
          if (lower.contains(t)) {
            final key = (t == 'go-pay' || t == 'gopay' || t == 'go pay')
                ? 'gopay'
                : (t == 'shopee' ? 'shopee' : (t == 'linkaja' || t == 'link aja' ? 'linkaja' : t));
            if (!uniqueBrands.containsKey(key)) {
              uniqueBrands[key] = b;
            }
            break;
          }
        }
      }

      if (uniqueBrands.isNotEmpty) {
        return uniqueBrands.values.toList();
      }
      return list;
    }
  } catch (_) {}

  return defaultEWallets;
});

class EWalletBrandPage extends ConsumerWidget {
  const EWalletBrandPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brandsAsync = ref.watch(ewalletBrandsProvider);

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xff0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Top Up E-Wallet',
          style: TextStyle(
            color: Color(0xff0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih Dompet Digital',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xff0F172A),
              ),
            ),
            const SizedBox(height: 16),
            brandsAsync.when(
              data: (brands) {
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: brands.length,
                  itemBuilder: (context, index) {
                    final brand = brands[index];

                    return GestureDetector(
                      onTap: () {
                        context.push('${AppRoutes.ewalletForm}?brand=${Uri.encodeComponent(brand.name)}');
                      },
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xffE2E8F0)),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xff0F172A).withOpacity(0.02),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: _buildEWalletIcon(brand),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            brand.name,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff334155),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => _buildSkeleton(context),
              error: (err, stack) => Center(
                child: Text('Gagal memuat e-wallet: $err'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEWalletIcon(PPOBBrandModel brand) {
    final nameLower = brand.name.toLowerCase();
    String? svgPath;

    if (nameLower.contains('dana')) {
      svgPath = 'assets/svgs/e-wallet/dana.svg';
    } else if (nameLower.contains('gopay') || nameLower.contains('go-pay') || nameLower.contains('go pay') || nameLower.contains('go')) {
      svgPath = 'assets/svgs/e-wallet/gopay.svg';
    } else if (nameLower.contains('ovo')) {
      svgPath = 'assets/svgs/e-wallet/ovo.svg';
    } else if (nameLower.contains('shopee') || nameLower.contains('shopeepay')) {
      svgPath = 'assets/svgs/e-wallet/shopee_pay.svg';
    }

    if (svgPath != null) {
      return SvgPicture.asset(
        svgPath,
        fit: BoxFit.contain,
      );
    }

    if (brand.logoUrl != null && brand.logoUrl!.isNotEmpty) {
      return Image.network(
        brand.logoUrl!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.account_balance_wallet_rounded, size: 28, color: Color(0xff8B5CF6)),
      );
    }

    return const Icon(Icons.account_balance_wallet_rounded, size: 28, color: Color(0xff8B5CF6));
  }

  Widget _buildSkeleton(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.white,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: 4,
        itemBuilder: (context, index) {
          return Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 40,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
