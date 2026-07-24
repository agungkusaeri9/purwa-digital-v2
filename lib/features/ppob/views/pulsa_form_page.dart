import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../viewmodels/pulsa_form_viewmodel.dart';
import '../models/ppob_product_model.dart';
import 'widgets/transaction_status_modal.dart';

class PulsaFormPage extends ConsumerStatefulWidget {
  const PulsaFormPage({super.key});

  @override
  ConsumerState<PulsaFormPage> createState() => _PulsaFormPageState();
}

class _PulsaFormPageState extends ConsumerState<PulsaFormPage> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String _formatRupiah(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  String _formatPhoneNumber(String val) {
    var digits = val.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('62')) {
      digits = digits.substring(2);
    } else if (digits.startsWith('0')) {
      digits = digits.substring(1);
    }
    if (digits.length > 13) {
      digits = digits.substring(0, 13);
    }
    if (digits.isEmpty) {
      return '';
    }
    const part1 = '+62';
    final part2 = digits.length > 3 ? digits.substring(0, 3) : digits;
    final part3 = digits.length > 7 ? digits.substring(3, 7) : (digits.length > 3 ? digits.substring(3) : '');
    final part4 = digits.length > 7 ? digits.substring(7) : '';

    var formatted = part1;
    if (part2.isNotEmpty) formatted += ' $part2';
    if (part3.isNotEmpty) formatted += ' $part3';
    if (part4.isNotEmpty) formatted += ' $part4';
    return formatted;
  }

  void _showConfirmationSheet(BuildContext context, PPOBProductModel product) {
    final viewModel = ref.read(pulsaFormViewModelProvider.notifier);
    final state = ref.read(pulsaFormViewModelProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Konfirmasi Transaksi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff0F172A),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xffF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xffE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildConfirmRow('Nomor HP', state.phoneNumber),
                    const Divider(height: 20, color: Color(0xffE2E8F0)),
                    _buildConfirmRow('Provider', product.brand.toUpperCase()),
                    const Divider(height: 20, color: Color(0xffE2E8F0)),
                    _buildConfirmRow('Nominal Pulsa', product.productName),
                    const Divider(height: 20, color: Color(0xffE2E8F0)),
                    _buildConfirmRow('Harga', _formatRupiah(product.sellingPrice)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context); // Close Confirmation Sheet
                  
                  // Show Polling Modal Immediately when submitting
                  final refId = await viewModel.submitTransaction();
                  if (refId != null && context.mounted) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => TransactionStatusModal(refId: refId),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Bayar Sekarang',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConfirmRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Color(0xff64748B), fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 13, color: Color(0xff0F172A), fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pulsaFormViewModelProvider);
    final viewModel = ref.read(pulsaFormViewModelProvider.notifier);
    final primaryColor = Theme.of(context).primaryColor;

    // Listen for error messages
    ref.listen<String?>(
      pulsaFormViewModelProvider.select((s) => s.errorMessage),
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
          'Beli Pulsa',
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
                  // 1. Phone Number Input Container
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
                          'Nomor Handphone',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff64748B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff0F172A),
                            letterSpacing: 1.0,
                          ),
                          onChanged: (value) {
                            viewModel.setPhoneNumber(value);
                          },
                          inputFormatters: [
                            PhoneNumberTextInputFormatter(),
                          ],
                          decoration: InputDecoration(
                            hintText: 'Contoh: 081234567890',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                              letterSpacing: 0,
                            ),
                            border: InputBorder.none,
                            suffixIcon: IconButton(
                              icon: Icon(Icons.contacts_rounded, color: primaryColor),
                              onPressed: () async {
                                await viewModel.pickContact();
                                final rawNum = ref.read(pulsaFormViewModelProvider).phoneNumber;
                                _phoneController.text = _formatPhoneNumber(rawNum);
                              },
                            ),
                          ),
                        ),
                        if (state.providerName.isNotEmpty) ...[
                          const Divider(height: 20, color: Color(0xffF1F5F9)),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  state.providerName.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: primaryColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Provider Terdeteksi',
                                style: TextStyle(fontSize: 11, color: Color(0xff64748B)),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 2. Product Grid
                  if (state.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (state.phoneNumber.length >= 4 && state.products.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Text(
                          'Produk tidak ditemukan untuk provider ini.',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                        ),
                      ),
                    )
                  else if (state.products.isNotEmpty) ...[
                    const Text(
                      'Pilih Nominal Pulsa',
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
                        crossAxisCount: 3, // 3 Columns
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.1,
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
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.productName.replaceAll(RegExp(r'(telkomsel|indosat|xl|axis|tri|smartfren|pulsa)\s*', caseSensitive: false), ''),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: isSelected ? primaryColor : const Color(0xff0F172A),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _formatRupiah(product.sellingPrice),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? primaryColor : const Color(0xff64748B),
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
          
          // 3. Sticky Bottom Button
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
              child: Row(
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
                    onPressed: () => _showConfirmationSheet(context, state.selectedProduct!),
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
            ),
        ],
      ),
    );
  }
}

class PhoneNumberTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    
    if (text.isEmpty) {
      return newValue;
    }

    var digits = text.replaceAll(RegExp(r'\D'), '');

    // Auto prepend 8 if typing 0
    if (digits == '0') {
      digits = '8';
    }

    if (digits.startsWith('62')) {
      digits = digits.substring(2);
    } else if (digits.startsWith('0')) {
      digits = digits.substring(1);
    }

    if (digits.length > 13) {
      digits = digits.substring(0, 13);
    }

    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '+62',
        selection: TextSelection.collapsed(offset: 3),
      );
    }

    final part1 = digits.length > 3 ? digits.substring(0, 3) : digits;
    final part2 = digits.length > 7 ? digits.substring(3, 7) : (digits.length > 3 ? digits.substring(3) : '');
    final part3 = digits.length > 7 ? digits.substring(7) : '';

    var formatted = '+62';
    if (part1.isNotEmpty) formatted += ' $part1';
    if (part2.isNotEmpty) formatted += ' $part2';
    if (part3.isNotEmpty) formatted += ' $part3';

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
