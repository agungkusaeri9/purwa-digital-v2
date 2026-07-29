import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PPOBConfirmationSheet extends StatelessWidget {
  final String phoneNumber;
  final String provider;
  final String productLabel;
  final String productValue;
  final double basePrice;
  final double markupPrice;
  final double sellingPrice;
  final VoidCallback onConfirm;

  const PPOBConfirmationSheet({
    super.key,
    required this.phoneNumber,
    required this.provider,
    required this.productLabel,
    required this.productValue,
    required this.basePrice,
    required this.markupPrice,
    required this.sellingPrice,
    required this.onConfirm,
  });

  String _formatRupiah(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  Widget _buildConfirmRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xff64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xff0F172A),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
                _buildConfirmRow('Nomor HP', phoneNumber),
                const Divider(height: 20, color: Color(0xffE2E8F0)),
                _buildConfirmRow('Provider', provider.toUpperCase()),
                const Divider(height: 20, color: Color(0xffE2E8F0)),
                _buildConfirmRow(productLabel, productValue),
                const Divider(height: 20, color: Color(0xffE2E8F0)),
                _buildConfirmRow('Harga Dasar', _formatRupiah(basePrice)),
                const Divider(height: 20, color: Color(0xffE2E8F0)),
                _buildConfirmRow('Biaya Admin', _formatRupiah(markupPrice)),
                const Divider(height: 20, color: Color(0xffE2E8F0)),
                _buildConfirmRow('Total Bayar', _formatRupiah(sellingPrice)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onConfirm,
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
  }
}
