import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../models/ppob_product_model.dart';
import '../viewmodels/pulsa_form_viewmodel.dart'; // ppobServiceProvider

final internetProductsProvider = FutureProvider<List<PPOBProductModel>>((ref) async {
  final service = ref.watch(ppobServiceProvider);
  try {
    final list = await service.getProducts(category: 'Pascabayar', brand: 'INTERNET PASCABAYAR');
    if (list.isNotEmpty) return list;
  } catch (_) {}

  // Fallback defaults if DB returns empty
  return [
    PPOBProductModel(id: 2498, productName: 'SPEEDY & INDIHOME', skuCode: 'post726952', basePrice: 0, markupPrice: 2500, sellingPrice: 2500, category: 'Pascabayar', brand: 'INTERNET PASCABAYAR'),
    PPOBProductModel(id: 2503, productName: 'BIZNET HOME', skuCode: 'post726957', basePrice: 0, markupPrice: 2500, sellingPrice: 2500, category: 'Pascabayar', brand: 'INTERNET PASCABAYAR'),
    PPOBProductModel(id: 2501, productName: 'First Media', skuCode: 'post726955', basePrice: 0, markupPrice: 2500, sellingPrice: 2500, category: 'Pascabayar', brand: 'INTERNET PASCABAYAR'),
    PPOBProductModel(id: 2500, productName: 'MyRepublic', skuCode: 'post726954', basePrice: 0, markupPrice: 2500, sellingPrice: 2500, category: 'Pascabayar', brand: 'INTERNET PASCABAYAR'),
    PPOBProductModel(id: 2502, productName: 'XL HOME', skuCode: 'post726956', basePrice: 0, markupPrice: 2500, sellingPrice: 2500, category: 'Pascabayar', brand: 'INTERNET PASCABAYAR'),
    PPOBProductModel(id: 2505, productName: 'Oxygen', skuCode: 'post726959', basePrice: 0, markupPrice: 2500, sellingPrice: 2500, category: 'Pascabayar', brand: 'INTERNET PASCABAYAR'),
    PPOBProductModel(id: 2497, productName: 'CBN', skuCode: 'post726951', basePrice: 0, markupPrice: 2500, sellingPrice: 2500, category: 'Pascabayar', brand: 'INTERNET PASCABAYAR'),
    PPOBProductModel(id: 2504, productName: 'BNETFIT', skuCode: 'post726958', basePrice: 0, markupPrice: 2500, sellingPrice: 2500, category: 'Pascabayar', brand: 'INTERNET PASCABAYAR'),
  ];
});

class InternetBrandPage extends ConsumerWidget {
  const InternetBrandPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(internetProductsProvider);
    const primaryColor = Color(0xff8B5CF6); // Purple for Internet

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
          'Internet Pascabayar',
          style: TextStyle(
            color: Color(0xff0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih Penyedia Internet',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xff0F172A),
              ),
            ),
            const SizedBox(height: 16),
            productsAsync.when(
              data: (products) {
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.70,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final item = products[index];
                    return GestureDetector(
                      onTap: () {
                        context.push(
                          '${AppRoutes.internetForm}?sku=${item.skuCode}&name=${Uri.encodeComponent(item.productName)}',
                        );
                      },
                      child: Column(
                        children: [
                          AspectRatio(
                            aspectRatio: 1.0,
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
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.wifi_rounded,
                                    size: 24,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.productName,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff334155),
                              height: 1.15,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Gagal memuat layanan: $err')),
            ),
          ],
        ),
      ),
    );
  }
}
