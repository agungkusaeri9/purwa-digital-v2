import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/app_error_dialog.dart';
import '../viewmodels/ewallet_form_viewmodel.dart';
import '../models/ppob_product_model.dart';
import 'widgets/transaction_status_modal.dart';
import 'widgets/ppob_confirmation_sheet.dart';
import 'widgets/pin_input_sheet.dart';
import 'pulsa_form_page.dart'; // For PhoneNumberTextInputFormatter

class EWalletFormPage extends ConsumerStatefulWidget {
  final String? initialBrand;
  const EWalletFormPage({super.key, this.initialBrand});

  @override
  ConsumerState<EWalletFormPage> createState() => _EWalletFormPageState();
}

class _EWalletFormPageState extends ConsumerState<EWalletFormPage> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final brand = widget.initialBrand ?? 'DANA';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ewalletFormViewModelProvider.notifier).setInitialBrand(brand);
    });
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
    final viewModel = ref.read(ewalletFormViewModelProvider.notifier);
    final state = ref.read(ewalletFormViewModelProvider);

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
          provider: state.providerName,
          productLabel: 'Nominal E-Wallet',
          productValue: product.productName,
          basePrice: product.basePrice,
          markupPrice: product.markupPrice,
          sellingPrice: product.sellingPrice,
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

  Widget _buildBrandSvgIcon(String brandName) {
    final nameLower = brandName.toLowerCase();
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

    return const Icon(Icons.account_balance_wallet_rounded, size: 24, color: Color(0xff8B5CF6));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ewalletFormViewModelProvider);
    final viewModel = ref.read(ewalletFormViewModelProvider.notifier);
    final primaryColor = Theme.of(context).primaryColor;

    ref.listen<String?>(
      ewalletFormViewModelProvider.select((s) => s.errorMessage),
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
          'Top Up ${state.providerName}',
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
                  // 1. Account Number Input Card
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
                              width: 24,
                              height: 24,
                              child: _buildBrandSvgIcon(state.providerName),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Nomor Akun ${state.providerName}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff0F172A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [PhoneNumberTextInputFormatter()],
                          onChanged: (val) => viewModel.setPhoneNumber(val),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff0F172A),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Masukkan Nomor HP (cth: 0812...)',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.perm_contact_calendar_outlined, color: primaryColor),
                              onPressed: () async {
                                await viewModel.pickContact();
                                _phoneController.text = ref.read(ewalletFormViewModelProvider).phoneNumber;
                              },
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
                              borderSide: BorderSide(color: primaryColor, width: 1.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 2. Denomination / Product Options
                  const Text(
                    'Pilih Nominal Top Up',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (state.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (state.products.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xffE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text(
                            'Tidak ada produk tersedia untuk ${state.providerName}.',
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.8,
                      ),
                      itemCount: state.products.length,
                      itemBuilder: (context, index) {
                        final product = state.products[index];
                        final isSelected = state.selectedProduct?.skuCode == product.skuCode;

                        return GestureDetector(
                          onTap: () => viewModel.selectProduct(product),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isSelected ? primaryColor.withOpacity(0.05) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? primaryColor : const Color(0xffE2E8F0),
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.12),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  product.productName,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? primaryColor : const Color(0xff0F172A),
                                  ),
                                ),
                                Text(
                                  _formatRupiah(product.sellingPrice),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: isSelected ? primaryColor : const Color(0xff059669),
                                  ),
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
          ),

          // Bottom Bar Action
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
                          state.selectedProduct != null
                              ? _formatRupiah(state.selectedProduct!.sellingPrice)
                              : 'Rp 0',
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
                    onPressed: (state.selectedProduct == null || state.phoneNumber.isEmpty)
                        ? null
                        : () => _showConfirmationSheet(context, state.selectedProduct!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: const Text('Lanjutkan', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
