import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/app_error_dialog.dart';
import '../viewmodels/bpjs_form_viewmodel.dart';
import 'widgets/transaction_status_modal.dart';
import 'widgets/ppob_confirmation_sheet.dart';
import 'widgets/pin_input_sheet.dart';

class BpjsFormPage extends ConsumerStatefulWidget {
  final String? initialType;
  const BpjsFormPage({super.key, this.initialType});

  @override
  ConsumerState<BpjsFormPage> createState() => _BpjsFormPageState();
}

class _BpjsFormPageState extends ConsumerState<BpjsFormPage> {
  final TextEditingController _idController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final type = widget.initialType ?? 'kesehatan';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bpjsFormViewModelProvider.notifier).setBpjsType(type);
    });
  }

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
    final viewModel = ref.read(bpjsFormViewModelProvider.notifier);
    final state = ref.read(bpjsFormViewModelProvider);
    final inquiry = state.inquiryResult;
    if (inquiry == null || state.product == null) return;

    final customerName = inquiry['customer_name']?.toString() ?? '-';
    final priceNum = (inquiry['price'] is num) ? (inquiry['price'] as num).toDouble() : 0.0;
    final adminNum = (inquiry['admin'] is num) ? (inquiry['admin'] as num).toDouble() : 0.0;
    final sellingPriceNum = (inquiry['selling_price'] is num)
        ? (inquiry['selling_price'] as num).toDouble()
        : (priceNum + adminNum + state.product!.markupPrice);

    final providerName = state.bpjsType.toLowerCase().contains('ketenaga')
        ? 'BPJS KETENAGAKERJAAN'
        : 'BPJS KESEHATAN';

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
          provider: providerName,
          productLabel: 'Nama Peserta BPJS',
          productValue: customerName,
          basePrice: priceNum,
          markupPrice: adminNum + state.product!.markupPrice,
          sellingPrice: sellingPriceNum,
          onConfirm: () async {
            Navigator.pop(sheetContext);
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
    final state = ref.watch(bpjsFormViewModelProvider);
    final viewModel = ref.read(bpjsFormViewModelProvider.notifier);
    const primaryColor = Color(0xff14B8A6);

    ref.listen<String?>(
      bpjsFormViewModelProvider.select((s) => s.errorMessage),
      (prev, next) {
        if (next != null && next.isNotEmpty) {
          showErrorToastAlert(context, next);
        }
      },
    );

    final isKetenagakerjaan = state.bpjsType.toLowerCase().contains('ketenaga');
    final titleText = isKetenagakerjaan ? 'BPJS Ketenagakerjaan' : 'BPJS Kesehatan';

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
        title: Text(
          titleText,
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
                  // 1. Input No. Peserta / VA BPJS Card
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
                            Container(
                              width: 32,
                              height: 32,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xffE2E8F0)),
                              ),
                              child: SvgPicture.asset(
                                isKetenagakerjaan
                                    ? 'assets/svgs/bpjs/ketenagakerjaan.svg'
                                    : 'assets/svgs/bpjs/kesehatan.svg',
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Nomor VA / No. Peserta $titleText',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff0F172A),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _idController,
                          keyboardType: TextInputType.number,
                          onChanged: (val) => viewModel.setCustomerNumber(val),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff0F172A),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Masukkan Nomor VA / Peserta BPJS',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            filled: true,
                            fillColor: const Color(0xffF8FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: Color(0xffE2E8F0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: Color(0xffE2E8F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: primaryColor, width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: (state.customerNumber.isEmpty || state.isInquiring)
                                ? null
                                : () => viewModel.inquireBill(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                            child: state.isInquiring
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text('Cek Tagihan', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 2. Inquiry Result Card
                  if (inquiry != null) ...[
                    const Text(
                      'Rincian Tagihan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff0F172A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xffE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow('Layanan', titleText),
                          const Divider(height: 20, color: Color(0xffF1F5F9)),
                          _buildDetailRow('Nama Peserta', customerName),
                          const Divider(height: 20, color: Color(0xffF1F5F9)),
                          _buildDetailRow('No. VA / Peserta', state.customerNumber),
                          const Divider(height: 20, color: Color(0xffF1F5F9)),
                          _buildDetailRow('Tagihan', _formatRupiah(priceNum)),
                          const Divider(height: 20, color: Color(0xffF1F5F9)),
                          _buildDetailRow('Biaya Admin', _formatRupiah(adminNum + markupPrice)),
                          const Divider(height: 20, color: Color(0xffF1F5F9)),
                          _buildDetailRow('Total Bayar', _formatRupiah(totalPrice), isBold: true, valueColor: primaryColor),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Bottom Bar Action
          if (inquiry != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xffE2E8F0))),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Total Pembayaran',
                            style: TextStyle(fontSize: 11, color: Color(0xff64748B)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatRupiah(totalPrice),
                            style: const TextStyle(
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
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: const Text('Bayar Sekarang', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Color(0xff64748B)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: valueColor ?? const Color(0xff0F172A),
            ),
          ),
        ),
      ],
    );
  }
}
