import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/pulsa_form_viewmodel.dart';
import '../../../main/viewmodel/main_viewmodel.dart';
import '../../../transaction/viewmodels/transaction_viewmodel.dart';
import '../../../transaction/models/ppob_transaction_model.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/app_error_dialog.dart';

class TransactionStatusModal extends ConsumerStatefulWidget {
  final Future<String?> createFuture;

  const TransactionStatusModal({super.key, required this.createFuture});

  @override
  ConsumerState<TransactionStatusModal> createState() =>
      _TransactionStatusModalState();
}

class _TransactionStatusModalState extends ConsumerState<TransactionStatusModal> {
  Timer? _timer;
  PPOBTransactionModel? _transaction;
  bool _isLoading = true;
  String _errorMessage = '';
  String? _refId;

  @override
  void initState() {
    super.initState();
    _startTransactionCreation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _startTransactionCreation() async {
    try {
      final resolvedRefId = await widget.createFuture;
      if (!mounted) return;
      if (resolvedRefId == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Gagal membuat transaksi. Silakan coba lagi.';
        });
        return;
      }
      setState(() {
        _refId = resolvedRefId;
      });
      // Start polling
      _checkStatus();
      _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
        _checkStatus();
      });
    } catch (e) {
      if (mounted) {
        final errorMsg = e.toString().replaceAll('Exception: ', '');
        setState(() {
          _isLoading = false;
          _errorMessage = errorMsg;
        });
        showErrorToastAlert(context, errorMsg);
      }
    }
  }

  Future<void> _checkStatus() async {
    final currentRefId = _refId;
    if (currentRefId == null) return;
    try {
      final tx = await ref.read(ppobServiceProvider).getTransactionByRef(currentRefId);
      if (mounted) {
        setState(() {
          _transaction = tx;
          _isLoading = false;
        });

        // If transaction completed (Success / Failed), stop polling
        final status = tx.status.toLowerCase();
        if (status == 'success' || status == 'sukses' || status == 'failed' || status == 'gagal') {
          _timer?.cancel();
          if (status == 'failed' || status == 'gagal') {
            showErrorToastAlert(context, tx.message ?? 'Transaksi gagal diproses oleh provider.');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = e.toString().replaceAll('Exception: ', '');
        setState(() {
          _errorMessage = errorMsg;
          _isLoading = false;
        });
        showErrorToastAlert(context, errorMsg);
      }
    }
  }

  String _formatRupiah(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    
    // Determine status UI
    Widget statusIcon;
    String statusTitle = 'Memproses...';
    String statusDesc = 'Mohon tunggu, transaksi Anda sedang diproses oleh sistem.';
    Color statusColor = const Color(0xffF59E0B); // Pending Amber

    if (_isLoading) {
      statusIcon = const CircularProgressIndicator();
    } else if (_errorMessage.isNotEmpty) {
      statusIcon = const Icon(Icons.error_outline_rounded, size: 64, color: Colors.red);
      statusTitle = 'Terjadi Kesalahan';
      statusDesc = _errorMessage;
      statusColor = Colors.red;
    } else if (_transaction != null) {
      final status = _transaction!.status.toLowerCase();
      if (status == 'success' || status == 'sukses') {
        statusIcon = Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(color: Color(0xffE6F4EA), shape: BoxShape.circle),
          child: const Icon(Icons.check_circle_rounded, size: 64, color: Color(0xff137333)),
        );
        statusTitle = 'Transaksi Sukses!';
        statusDesc = 'Pulsa sebesar ${_formatRupiah(_transaction!.sellingPrice)} berhasil dikirim ke nomor ${_transaction!.customerNo}.';
        statusColor = const Color(0xff10B981);
      } else if (status == 'failed' || status == 'gagal') {
        statusIcon = Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(color: Color(0xffFCE8E6), shape: BoxShape.circle),
          child: const Icon(Icons.cancel_rounded, size: 64, color: Color(0xffC5221F)),
        );
        statusTitle = 'Transaksi Gagal';
        statusDesc = _transaction!.message ?? 'Transaksi gagal diproses oleh provider.';
        statusColor = const Color(0xffEF4444);
      } else {
        // Pending
        statusIcon = SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(
            color: primaryColor,
            strokeWidth: 4,
          ),
        );
        statusTitle = 'Menunggu Pembayaran / Diproses';
        statusDesc = 'Transaksi sedang diproses. Status akan diperbarui secara otomatis.';
      }
    } else {
      statusIcon = const CircularProgressIndicator();
    }

    final bool isDone = _errorMessage.isNotEmpty ||
        (_transaction != null &&
            (const ['success', 'sukses', 'failed', 'gagal']
                .contains(_transaction!.status.toLowerCase())));

    return PopScope(
      canPop: true,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, size: 22, color: Color(0xff94A3B8)),
                  onPressed: () {
                    ref.read(transactionViewModelProvider.notifier).loadInitialData();
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                ),
              ),
              statusIcon,
              const SizedBox(height: 16),
              Text(
                statusTitle,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: statusColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                statusDesc,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              if (_transaction != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xffF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xffE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow('Ref ID', _transaction!.refId),
                      const SizedBox(height: 8),
                      _buildDetailRow('Nomor Tujuan', _transaction!.customerNo),
                      const SizedBox(height: 8),
                      _buildDetailRow('Produk', _transaction!.productName),
                      const SizedBox(height: 8),
                      _buildDetailRow('Total Bayar', _formatRupiah(_transaction!.sellingPrice), isBold: true),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              if (isDone) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(transactionViewModelProvider.notifier).loadInitialData();
                      ref.read(mainViewModelProvider.notifier).changeTab(2);
                      Navigator.of(context, rootNavigator: true).pop();
                      context.go(AppRoutes.home);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: statusColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text('Lihat Riwayat', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      ref.read(transactionViewModelProvider.notifier).loadInitialData();
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xff64748B),
                      side: const BorderSide(color: Color(0xffCBD5E1)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xff64748B)),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: const Color(0xff0F172A),
          ),
        ),
      ],
    );
  }
}
