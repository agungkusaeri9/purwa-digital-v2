import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../viewmodels/pln_pasca_form_viewmodel.dart';
import 'widgets/transaction_status_modal.dart';
import 'widgets/ppob_confirmation_sheet.dart';
import 'widgets/pin_input_sheet.dart';

class PlnPascaFormPage extends ConsumerStatefulWidget {
  const PlnPascaFormPage({super.key});

  @override
  ConsumerState<PlnPascaFormPage> createState() => _PlnPascaFormPageState();
}

class _PlnPascaFormPageState extends ConsumerState<PlnPascaFormPage> {
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

  void _showConfirmationSheet(BuildContext context) {
    final viewModel = ref.read(plnPascaFormViewModelProvider.notifier);
    final state = ref.read(plnPascaFormViewModelProvider);
    final inquiry = state.inquiryResult;
    if (inquiry == null || state.product == null) return;

    final customerName = inquiry['customer_name']?.toString() ?? '-';
    final priceNum = (inquiry['price'] is num) ? (inquiry['price'] as num).toDouble() : 0.0;
    final adminNum = (inquiry['admin'] is num) ? (inquiry['admin'] as num).toDouble() : 0.0;
    final sellingPriceNum = (inquiry['selling_price'] is num)
        ? (inquiry['selling_price'] as num).toDouble()
        : (priceNum + adminNum + state.product!.markupPrice);

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
          provider: 'PLN PASCABAYAR',
          productLabel: 'Nama Pelanggan',
          productValue: customerName,
          basePrice: priceNum,
          markupPrice: adminNum + state.product!.markupPrice,
          sellingPrice: sellingPriceNum,
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
    final state = ref.watch(plnPascaFormViewModelProvider);
    final viewModel = ref.read(plnPascaFormViewModelProvider.notifier);
    final primaryColor = Theme.of(context).primaryColor;

    ref.listen<String?>(
      plnPascaFormViewModelProvider.select((s) => s.errorMessage),
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

    final inquiry = state.inquiryResult;
    final customerName = inquiry?['customer_name']?.toString() ?? '-';
    final priceNum = (inquiry?['price'] is num) ? (inquiry!['price'] as num).toDouble() : 0.0;
    final adminNum = (inquiry?['admin'] is num) ? (inquiry!['admin'] as num).toDouble() : 0.0;
    final markupPrice = state.product?.markupPrice ?? 0.0;
    final totalPrice = (inquiry?['selling_price'] is num)
        ? (inquiry!['selling_price'] as num).toDouble()
        : (priceNum + adminNum + markupPrice);

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
          'PLN Pascabayar',
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
                  // Input ID Pelanggan
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
                          'ID Pelanggan PLN',
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
                            hintText: 'Masukkan 11-12 digit ID Pelanggan',
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
                  const SizedBox(height: 16),

                  // Button Cek Tagihan
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: (state.customerNumber.length >= 10 && !state.isInquiring)
                          ? () => viewModel.performInquiry()
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      icon: state.isInquiring
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.search_rounded, size: 20),
                      label: Text(
                        state.isInquiring ? 'Mengecek Tagihan...' : 'Cek Tagihan',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Display Hasil Inquiry
                  if (inquiry != null) ...[
                    const Text(
                      'Rincian Tagihan Listrik',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff0F172A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: primaryColor.withOpacity(0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow('Nama Pelanggan', customerName, isBold: true),
                          const Divider(height: 20, color: Color(0xffF1F5F9)),
                          _buildDetailRow('ID Pelanggan', state.customerNumber),
                          const Divider(height: 20, color: Color(0xffF1F5F9)),
                          _buildDetailRow('Tagihan Listrik', _formatRupiah(priceNum)),
                          const Divider(height: 20, color: Color(0xffF1F5F9)),
                          _buildDetailRow('Biaya Admin', _formatRupiah(adminNum + markupPrice)),
                          const Divider(height: 20, color: Color(0xffF1F5F9)),
                          _buildDetailRow(
                            'Total Pembayaran',
                            _formatRupiah(totalPrice),
                            valueColor: primaryColor,
                            isBold: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Bottom Sheet / Action Bar
          if (inquiry != null)
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
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Total Tagihan',
                          style: TextStyle(fontSize: 11, color: Color(0xff64748B)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatRupiah(totalPrice),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () => _showConfirmationSheet(context),
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
                      'Bayar Sekarang',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xff64748B),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor ?? const Color(0xff0F172A),
            ),
          ),
        ),
      ],
    );
  }
}
