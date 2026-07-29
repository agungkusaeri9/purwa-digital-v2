import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../viewmodels/data_form_viewmodel.dart';
import '../models/ppob_product_model.dart';
import 'widgets/transaction_status_modal.dart';
import 'widgets/ppob_confirmation_sheet.dart';
import 'widgets/pin_input_sheet.dart';
import 'pulsa_form_page.dart'; // For PhoneNumberTextInputFormatter

class DataFormPage extends ConsumerStatefulWidget {
  final String? initialBrand;
  const DataFormPage({super.key, this.initialBrand});

  @override
  ConsumerState<DataFormPage> createState() => _DataFormPageState();
}

class _DataFormPageState extends ConsumerState<DataFormPage> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialBrand != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(dataFormViewModelProvider.notifier)
            .setInitialBrand(widget.initialBrand!);
      });
    }
  }

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

  void _showConfirmationSheet(BuildContext context, PPOBProductModel product) {
    final viewModel = ref.read(dataFormViewModelProvider.notifier);
    final state = ref.read(dataFormViewModelProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return PPOBConfirmationSheet(
          phoneNumber: state.phoneNumber,
          provider: product.brand,
          productLabel: 'Paket Data',
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
                builder: (_) =>
                    TransactionStatusModal(createFuture: createFuture),
              );
            }
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dataFormViewModelProvider);
    final viewModel = ref.read(dataFormViewModelProvider.notifier);
    final primaryColor = Theme.of(context).primaryColor;

    ref.listen<String?>(
      dataFormViewModelProvider.select((s) => s.errorMessage),
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
          'Beli Paket Data',
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
                              icon: Icon(Icons.contacts_rounded,
                                  color: primaryColor),
                              onPressed: () async {
                                await viewModel.pickContact();
                                final rawNum = ref
                                    .read(dataFormViewModelProvider)
                                    .phoneNumber;
                                _phoneController.text = rawNum.startsWith('0')
                                    ? '+62 ${rawNum.substring(1)}'
                                    : rawNum;
                              },
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (state.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (state.providerName.isNotEmpty &&
                      state.products.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Text(
                          'Produk tidak ditemukan untuk provider ini.',
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 13),
                        ),
                      ),
                    )
                  else if (state.products.isNotEmpty) ...[
                    const Text(
                      'Pilih Paket Data',
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
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.85,
                      ),
                      itemCount: state.products.length,
                      itemBuilder: (context, index) {
                        final product = state.products[index];
                        final isSelected =
                            state.selectedProduct?.id == product.id;

                        // Formatting descriptions for data packages (remove prefix operator brand names)
                        final title = product.productName.replaceAll(
                            RegExp(
                                r'(telkomsel|indosat|xl|axis|tri|smartfren|paket data|data)\s*',
                                caseSensitive: false),
                            '');

                        return GestureDetector(
                          onTap: () => viewModel.selectProduct(product),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? primaryColor.withOpacity(0.05)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? primaryColor
                                    : const Color(0xffE2E8F0),
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    color: isSelected
                                        ? primaryColor
                                        : const Color(0xff0F172A),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (product.description != null &&
                                    product.description!.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    product.description!,
                                    style: TextStyle(
                                      fontSize: 8.5,
                                      color: Colors.grey.shade500,
                                      height: 1.2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                                const SizedBox(height: 4),
                                Text(
                                  _formatRupiah(product.sellingPrice),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: isSelected
                                        ? primaryColor
                                        : const Color(0xff0F172A),
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
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xff64748B)),
                      ),
                      Text(
                        'Biaya Admin: ${_formatRupiah(state.selectedProduct!.markupPrice)}',
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xff64748B)),
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
                              style: TextStyle(
                                  fontSize: 11, color: Color(0xff64748B)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatRupiah(
                                  state.selectedProduct!.sellingPrice),
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
                        onPressed: state.phoneNumber.length >= 10
                            ? () => _showConfirmationSheet(
                                context, state.selectedProduct!)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 14),
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
