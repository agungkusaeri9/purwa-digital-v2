import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/ppob_transaction_model.dart';

class TransactionDetailPage extends StatelessWidget {
  const TransactionDetailPage({super.key, required this.transaction});

  final PPOBTransactionModel transaction;

  String _formatRupiah(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'sukses':
      case 'success':
        return const Color(0xff10B981);
      case 'gagal':
      case 'failed':
        return const Color(0xffEF4444);
      default:
        return const Color(0xffF59E0B);
    }
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label berhasil disalin!'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(transaction.status);

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xff0F172A), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Transaksi',
          style: TextStyle(
            color: Color(0xff0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          // 1. Status Banner Card
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xffE2E8F0)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    transaction.status.toLowerCase() == 'sukses' || transaction.status.toLowerCase() == 'success'
                        ? Icons.check_circle_rounded
                        : transaction.status.toLowerCase() == 'gagal' || transaction.status.toLowerCase() == 'failed'
                            ? Icons.cancel_rounded
                            : Icons.pending_actions_rounded,
                    size: 36,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Transaksi ${transaction.status}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatRupiah(transaction.sellingPrice),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xff0F172A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 2. Transaksi Detail Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xffE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'RINCIAN TRANSAKSI',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),

                _buildDetailRow('Layanan / Produk', transaction.productName),
                const Divider(height: 24, color: Color(0xffF1F5F9)),

                _buildDetailRow('No Pelanggan', transaction.customerNo),
                const Divider(height: 24, color: Color(0xffF1F5F9)),

                _buildDetailRowWithCopy(
                  context: context,
                  label: 'Ref ID',
                  value: transaction.refId,
                  onCopy: () => _copyToClipboard(context, transaction.refId, 'Ref ID'),
                ),
                const Divider(height: 24, color: Color(0xffF1F5F9)),

                if (transaction.sn != null && transaction.sn!.isNotEmpty) ...[
                  _buildDetailRowWithCopy(
                    context: context,
                    label: 'Serial Number (SN)',
                    value: transaction.sn!,
                    onCopy: () => _copyToClipboard(context, transaction.sn!, 'Serial Number'),
                  ),
                  const Divider(height: 24, color: Color(0xffF1F5F9)),
                ],

                _buildDetailRow('Waktu Transaksi', transaction.createdAt),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 3. Rincian Pembayaran Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xffE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'RINCIAN PEMBAYARAN',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                _buildPriceRow('Harga Produk', _formatRupiah(transaction.price)),
                const SizedBox(height: 8),
                _buildPriceRow('Biaya Admin / Markup', _formatRupiah(transaction.markupPrice)),
                const Divider(height: 24, color: Color(0xffF1F5F9)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Pembayaran',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff0F172A),
                      ),
                    ),
                    Text(
                      _formatRupiah(transaction.sellingPrice),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Color(0xff0F172A),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // 4. Action Buttons
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Menyiapkan cetak / bagikan struk...'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.share_rounded, size: 18),
            label: const Text(
              'Bagikan Struk / Resi',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 12, color: Color(0xff0F172A), fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRowWithCopy({
    required BuildContext context,
    required String label,
    required String value,
    required VoidCallback onCopy,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
        ),
        Row(
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 12, color: Color(0xff0F172A), fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onCopy,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.copy_rounded, size: 14, color: Colors.grey),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 12, color: Color(0xff475569), fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
