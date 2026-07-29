import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../models/ppob_brand_model.dart';
import '../viewmodels/pulsa_form_viewmodel.dart';
import '../../../../core/router/app_routes.dart';

final gameBrandsProvider = FutureProvider.autoDispose<List<PPOBBrandModel>>((ref) async {
  final service = ref.watch(ppobServiceProvider);
  try {
    final list = await service.getBrands(category: 'games');
    // Ensure Free Fire and Mobile Legends exist in list
    final defaultGames = [
      PPOBBrandModel(id: 1, name: 'Free Fire', slug: 'free-fire', logoUrl: ''),
      PPOBBrandModel(id: 2, name: 'Mobile Legends', slug: 'mobile-legends', logoUrl: ''),
      PPOBBrandModel(id: 3, name: 'PUBG Mobile', slug: 'pubg-mobile', logoUrl: ''),
      PPOBBrandModel(id: 4, name: 'Genshin Impact', slug: 'genshin-impact', logoUrl: ''),
    ];

    final existingNames = list.map((e) => e.name.toLowerCase()).toSet();
    final combined = List<PPOBBrandModel>.from(list);
    for (final def in defaultGames) {
      if (!existingNames.contains(def.name.toLowerCase())) {
        combined.add(def);
      }
    }
    return combined;
  } catch (_) {
    return [
      PPOBBrandModel(id: 1, name: 'Free Fire', slug: 'free-fire', logoUrl: ''),
      PPOBBrandModel(id: 2, name: 'Mobile Legends', slug: 'mobile-legends', logoUrl: ''),
      PPOBBrandModel(id: 3, name: 'PUBG Mobile', slug: 'pubg-mobile', logoUrl: ''),
      PPOBBrandModel(id: 4, name: 'Genshin Impact', slug: 'genshin-impact', logoUrl: ''),
    ];
  }
});

class GameBrandPage extends ConsumerWidget {
  const GameBrandPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brandsAsync = ref.watch(gameBrandsProvider);

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
          'Pilih Game',
          style: TextStyle(
            color: Color(0xff0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: brandsAsync.when(
        data: (brands) {
          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, // 4 Columns as requested
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: brands.length,
            itemBuilder: (context, index) {
              final brand = brands[index];
              final hasLogo = brand.logoUrl != null && brand.logoUrl!.isNotEmpty;

              return GestureDetector(
                onTap: () {
                  context.push('${AppRoutes.gameForm}?brand=${Uri.encodeComponent(brand.name)}');
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
                            child: hasLogo
                                ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.network(
                                      brand.logoUrl!,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) => _buildGameFallback(brand),
                                    ),
                                  )
                                : _buildGameFallback(brand),
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
          child: Text('Gagal memuat game: $err'),
        ),
      ),
    );
  }

  Widget _buildGameFallback(PPOBBrandModel brand) {
    IconData iconData = Icons.sports_esports_rounded;
    Color bgColor = const Color(0xffEFF6FF);
    Color iconColor = const Color(0xff2563EB);

    final nameLower = brand.name.toLowerCase();
    if (nameLower.contains('free fire')) {
      bgColor = const Color(0xffFEF2F2);
      iconColor = const Color(0xffEF4444);
      iconData = Icons.local_fire_department_rounded;
    } else if (nameLower.contains('mobile legend')) {
      bgColor = const Color(0xffF0FDF4);
      iconColor = const Color(0xff10B981);
      iconData = Icons.shield_rounded;
    } else if (nameLower.contains('pubg')) {
      bgColor = const Color(0xffFFFBEB);
      iconColor = const Color(0xffF59E0B);
      iconData = Icons.gps_fixed_rounded;
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: bgColor,
      child: Icon(iconData, size: 28, color: iconColor),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.white,
      child: GridView.builder(
        padding: const EdgeInsets.all(20),
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: 8,
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
