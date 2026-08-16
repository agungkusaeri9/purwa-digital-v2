import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/app_error_dialog.dart';
import '../viewmodels/game_form_viewmodel.dart';
import '../models/ppob_product_model.dart';
import 'widgets/transaction_status_modal.dart';
import 'widgets/ppob_confirmation_sheet.dart';
import 'widgets/pin_input_sheet.dart';

class GameFormPage extends ConsumerStatefulWidget {
  final String? initialBrand;
  const GameFormPage({super.key, this.initialBrand});

  @override
  ConsumerState<GameFormPage> createState() => _GameFormPageState();
}

class _GameFormPageState extends ConsumerState<GameFormPage> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _zoneIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final brand = widget.initialBrand ?? 'Free Fire';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameFormViewModelProvider.notifier).setBrand(brand);
    });
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _zoneIdController.dispose();
    super.dispose();
  }

  String _formatRupiah(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  void _showConfirmationSheet(BuildContext context, PPOBProductModel product) {
    final viewModel = ref.read(gameFormViewModelProvider.notifier);
    final state = ref.read(gameFormViewModelProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return PPOBConfirmationSheet(
          phoneNumber: state.customerNo,
          provider: state.brandName,
          productLabel: 'Produk Game',
          productValue: product.productName,
          basePrice: product.basePrice,
          markupPrice: product.markupPrice,
          sellingPrice: product.sellingPrice,
          onConfirm: () async {
            Navigator.pop(sheetContext); // Close Confirmation Sheet
            await Future.delayed(const Duration(milliseconds: 100));
            if (!context.mounted) return;

            final pin = await PinInputSheet.show(context);
            if (pin != null && pin.isNotEmpty && context.mounted) {
              final createFuture = viewModel.submitTransaction(pin: pin);
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => TransactionStatusModal(createFuture: createFuture),
              );
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameFormViewModelProvider);
    final viewModel = ref.read(gameFormViewModelProvider.notifier);
    final primaryColor = Theme.of(context).primaryColor;
    final isMobileLegends = state.brandName.toLowerCase().contains('mobile legend');

    ref.listen<String?>(
      gameFormViewModelProvider.select((s) => s.errorMessage),
      (prev, next) {
        if (next != null && next.isNotEmpty) {
          showErrorToastAlert(context, next);
        }
      },
    );

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xff0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Topup ${state.brandName}',
          style: const TextStyle(
            color: Color(0xff0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Account / User ID Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xffE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 22,
                              height: 22,
                              child: isMobileLegends
                                  ? SvgPicture.asset('assets/svgs/game/mobile_legend.svg', fit: BoxFit.contain)
                                  : SvgPicture.asset('assets/svgs/game/free_fire.svg', fit: BoxFit.contain),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Data Akun ${state.brandName}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff0F172A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (isMobileLegends) ...[
                          // Mobile Legends requires User ID & Zone ID
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'User ID',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff64748B),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    TextField(
                                      controller: _userIdController,
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff0F172A),
                                      ),
                                      onChanged: (val) => viewModel.setUserId(val),
                                      decoration: InputDecoration(
                                        hintText: 'Contoh: 12345678',
                                        hintStyle: TextStyle(
                                          color: Colors.grey.shade400,
                                          fontSize: 13,
                                          fontWeight: FontWeight.normal,
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                        filled: true,
                                        fillColor: const Color(0xffF8FAFC),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(color: Color(0xffE2E8F0)),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(color: Color(0xffE2E8F0)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: primaryColor, width: 1.5),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Zone ID',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff64748B),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    TextField(
                                      controller: _zoneIdController,
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff0F172A),
                                      ),
                                      onChanged: (val) => viewModel.setZoneId(val),
                                      decoration: InputDecoration(
                                        hintText: '(1234)',
                                        hintStyle: TextStyle(
                                          color: Colors.grey.shade400,
                                          fontSize: 13,
                                          fontWeight: FontWeight.normal,
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                        filled: true,
                                        fillColor: const Color(0xffF8FAFC),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(color: Color(0xffE2E8F0)),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(color: Color(0xffE2E8F0)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: primaryColor, width: 1.5),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          // Free Fire / Other games require single User ID
                          const Text(
                            'User ID',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff64748B),
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _userIdController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff0F172A),
                            ),
                            onChanged: (val) => viewModel.setUserId(val),
                            decoration: InputDecoration(
                              hintText: 'Masukkan User ID (Contoh: 123456789)',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 13,
                                fontWeight: FontWeight.normal,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              filled: true,
                              fillColor: const Color(0xffF8FAFC),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xffE2E8F0)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xffE2E8F0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: primaryColor, width: 1.5),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 2. Product Grid Section
                  if (state.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (state.products.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 40, color: Colors.grey.shade300),
                            const SizedBox(height: 8),
                            Text(
                              'Produk belum tersedia untuk ${state.brandName}.',
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    )
                  else ...[
                    const Text(
                      'Pilih Nominal Top Up',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff0F172A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // 2 Columns for game diamonds
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.35, // Adjusted height for multi-line text
                      ),
                      itemCount: state.products.length,
                      itemBuilder: (context, index) {
                        final product = state.products[index];
                        final isSelected = state.selectedProduct?.id == product.id;

                        return GestureDetector(
                          onTap: () => viewModel.selectProduct(product),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? primaryColor.withOpacity(0.05) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? primaryColor : const Color(0xffE2E8F0),
                                width: isSelected ? 1.5 : 1,
                              ),
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Icon(
                                    Icons.diamond_rounded,
                                    size: 16,
                                    color: isSelected ? primaryColor : const Color(0xff0284C7),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        product.productName,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? primaryColor : const Color(0xff0F172A),
                                          height: 1.2,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        _formatRupiah(product.sellingPrice),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: isSelected ? primaryColor : const Color(0xff64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),

          // 3. Sticky Bottom Checkout Bar
          if (state.selectedProduct != null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Harga Dasar: ${_formatRupiah(state.selectedProduct!.basePrice)}',
                        style: const TextStyle(fontSize: 11, color: Color(0xff64748B)),
                      ),
                      Text(
                        'Biaya Admin: ${_formatRupiah(state.selectedProduct!.markupPrice)}',
                        style: const TextStyle(fontSize: 11, color: Color(0xff64748B)),
                      ),
                    ],
                  ),
                  const Divider(height: 16, color: Color(0xffF1F5F9)),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Total Bayar',
                              style: TextStyle(fontSize: 11, color: Color(0xff64748B)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatRupiah(state.selectedProduct!.sellingPrice),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: (state.userId.isNotEmpty && (!isMobileLegends || state.zoneId.isNotEmpty))
                            ? () => _showConfirmationSheet(context, state.selectedProduct!)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Lanjut',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
