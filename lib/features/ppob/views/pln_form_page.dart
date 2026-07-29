import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../viewmodels/pln_form_viewmodel.dart';
import '../models/ppob_product_model.dart';
import 'widgets/transaction_status_modal.dart';
import 'widgets/ppob_confirmation_sheet.dart';
import 'widgets/pin_input_sheet.dart';

class PlnFormPage extends ConsumerStatefulWidget {
  const PlnFormPage({super.key});

  @override
  ConsumerState<PlnFormPage> createState() => _PlnFormPageState();
}

class _PlnFormPageState extends ConsumerState<PlnFormPage> {
  final TextEditingController _idController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
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
    final viewModel = ref.read(plnFormViewModelProvider.notifier);
    final state = ref.read(plnFormViewModelProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return PPOBConfirmationSheet(
          phoneNumber: state.customerNumber,
          provider: 'PLN PRABAYAR',
          productLabel: 'Nominal Token',
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
    final state = ref.watch(plnFormViewModelProvider);
    final viewModel = ref.read(plnFormViewModelProvider.notifier);
    final primaryColor = Theme.of(context).primaryColor;

    ref.listen<String?>(
      plnFormViewModelProvider.select((s) => s.errorMessage),
      (prev, next) {
        if (next != null && next.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
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
        title: const Text(
          'Token Listrik PLN',
          style: TextStyle(
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
                  // ID Pelanggan Input
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
                        const Text(
                          'No. Meter / ID Pelanggan',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff64748B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _idController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff0F172A),
                            letterSpacing: 1.0,
                          ),
                          onChanged: (value) {
                            viewModel.setCustomerNumber(value);
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(12),
                          ],
                          decoration: InputDecoration(
                            hintText: 'Contoh: 12345678901',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                              letterSpacing: 0,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Nominall Grid / Loading
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
                        child: Text(
                          'Produk PLN tidak tersedia.',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                        ),
                      ),
                    )
                  else ...[
                    const Text(
                      'Pilih Nominal Token',
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
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.6,
                      ),
                      itemCount: state.products.length,
                      itemBuilder: (context, index) {
                        final product = state.products[index];
                        final isSelected = state.selectedProduct?.id == product.id;

                        // Display nominal string cleanly (e.g. "PLN 50.000" -> "50.000")
                        final nominal = product.productName.replaceAll(RegExp(r'PLN\s*', caseSensitive: false), '');

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
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  nominal,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: isSelected ? primaryColor : const Color(0xff0F172A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _formatRupiah(product.sellingPrice),
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? primaryColor : Colors.grey.shade500,
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
                        onPressed: state.customerNumber.length >= 10
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
