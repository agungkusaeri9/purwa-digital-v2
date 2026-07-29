import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/ppob_transaction_model.dart';
import '../../ppob/viewmodels/pulsa_form_viewmodel.dart';
import '../viewmodels/transaction_viewmodel.dart';

class TransactionDetailPage extends ConsumerStatefulWidget {
  const TransactionDetailPage({super.key, required this.transaction});

  final PPOBTransactionModel transaction;

  @override
  ConsumerState<TransactionDetailPage> createState() =>
      _TransactionDetailPageState();
}

class _TransactionDetailPageState
    extends ConsumerState<TransactionDetailPage> {
  late PPOBTransactionModel _transaction;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _transaction = widget.transaction;
  }

  Future<void> _refreshStatus() async {
    if (_isRefreshing) return;
    setState(() {
      _isRefreshing = true;
    });

    try {
      final updatedTx = await ref
          .read(ppobServiceProvider)
          .getTransactionByRef(_transaction.refId);
      ref.read(transactionViewModelProvider.notifier).loadInitialData();
      if (mounted) {
        setState(() {
          _transaction = updatedTx;
          _isRefreshing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status transaksi diperbarui: ${_transaction.status}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xff10B981),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Gagal memperbarui status: ${e.toString().replaceAll('Exception: ', '')}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
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

  String _formatIndonesianDateTime(String utcString) {
    final dateTime = DateTime.tryParse(utcString);
    if (dateTime == null) return utcString;
    final local = dateTime.toLocal();
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    final day = local.day.toString().padLeft(2, '0');
    final month = months[local.month - 1];
    final year = local.year;
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    final second = local.second.toString().padLeft(2, '0');
    return '$day $month $year, $hour:$minute:$second';
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
    final statusColor = _getStatusColor(_transaction.status);

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xff0F172A), size: 18),
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
      body: RefreshIndicator(
        onRefresh: _refreshStatus,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          children: [
            // 1. Status Banner Card
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
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
                      _transaction.status.toLowerCase() == 'sukses' ||
                              _transaction.status.toLowerCase() == 'success'
                          ? Icons.check_circle_rounded
                          : _transaction.status.toLowerCase() == 'gagal' ||
                                  _transaction.status.toLowerCase() == 'failed'
                              ? Icons.cancel_rounded
                              : Icons.pending_actions_rounded,
                      size: 36,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Transaksi ${_transaction.status}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatRupiah(_transaction.sellingPrice),
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
                  _buildDetailRow('Layanan / Produk', _transaction.productName),
                  const Divider(height: 24, color: Color(0xffF1F5F9)),
                  _buildDetailRow('No Pelanggan', _transaction.customerNo),
                  const Divider(height: 24, color: Color(0xffF1F5F9)),
                  _buildDetailRowWithCopy(
                    context: context,
                    label: 'Ref ID',
                    value: _transaction.refId,
                    onCopy: () =>
                        _copyToClipboard(context, _transaction.refId, 'Ref ID'),
                  ),
                  const Divider(height: 24, color: Color(0xffF1F5F9)),
                  if (_transaction.sn != null &&
                      _transaction.sn!.isNotEmpty) ...[
                    _buildDetailRowWithCopy(
                      context: context,
                      label: 'Serial Number (SN)',
                      value: _transaction.sn!,
                      onCopy: () => _copyToClipboard(
                          context, _transaction.sn!, 'Serial Number'),
                    ),
                    const Divider(height: 24, color: Color(0xffF1F5F9)),
                  ],
                  _buildDetailRow('Waktu Transaksi',
                      _formatIndonesianDateTime(_transaction.createdAt)),
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
                  _buildPriceRow(
                      'Harga Produk', _formatRupiah(_transaction.price)),
                  const SizedBox(height: 8),
                  _buildPriceRow('Biaya Admin / Markup',
                      _formatRupiah(_transaction.markupPrice)),
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
                        _formatRupiah(_transaction.sellingPrice),
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
            const SizedBox(height: 24),

            // 4. Action Buttons (Refresh Status & Share Receipt)
            OutlinedButton.icon(
              onPressed: _isRefreshing ? null : _refreshStatus,
              icon: _isRefreshing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Color(0xff475569)),
                    )
                  : const Icon(Icons.refresh_rounded, size: 18),
              label: const Text(
                'Cek / Refresh Status Transaksi',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xff334155),
                side: const BorderSide(color: Color(0xffCBD5E1)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _showShareReceiptBottomSheet,
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
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 6,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
                fontSize: 12,
                color: Color(0xff0F172A),
                fontWeight: FontWeight.bold),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 6,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xff0F172A),
                      fontWeight: FontWeight.bold),
                ),
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
                  child: const Icon(Icons.copy_rounded,
                      size: 14, color: Colors.grey),
                ),
              ),
            ],
          ),
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
          style: const TextStyle(
              fontSize: 12,
              color: Color(0xff64748B),
              fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: const TextStyle(
              fontSize: 12,
              color: Color(0xff475569),
              fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  void _showShareReceiptBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return _WhatsAppShareBottomSheet(
          transaction: _transaction,
          formatRupiah: _formatRupiah,
          formatDateTime: _formatIndonesianDateTime,
        );
      },
    );
  }
}

class _WhatsAppShareBottomSheet extends StatefulWidget {
  const _WhatsAppShareBottomSheet({
    required this.transaction,
    required this.formatRupiah,
    required this.formatDateTime,
  });

  final PPOBTransactionModel transaction;
  final String Function(double) formatRupiah;
  final String Function(String) formatDateTime;

  @override
  State<_WhatsAppShareBottomSheet> createState() => _WhatsAppShareBottomSheetState();
}

class _WhatsAppShareBottomSheetState extends State<_WhatsAppShareBottomSheet> {
  final _part2Controller = TextEditingController();
  final _part3Controller = TextEditingController();
  final _part4Controller = TextEditingController();

  final _part2FocusNode = FocusNode();
  final _part3FocusNode = FocusNode();
  final _part4FocusNode = FocusNode();

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeDefaultPhoneNumber();
  }

  void _initializeDefaultPhoneNumber() {
    final categoryLower = widget.transaction.category?.toLowerCase() ?? '';
    final isPulsaOrKuota = categoryLower.contains('pulsa') || 
                           categoryLower.contains('data') || 
                           categoryLower.contains('kuota') ||
                           categoryLower.contains('internet');

    if (isPulsaOrKuota) {
      String? defaultNum = widget.transaction.waNumber;
      if (defaultNum == null || defaultNum.isEmpty) {
        defaultNum = widget.transaction.customerNo;
      }
      
      if (defaultNum.isNotEmpty) {
        final cleanNum = defaultNum.replaceAll(RegExp(r'[^0-9]'), '');
        if (cleanNum.length >= 9) {
          _parseAndSetPhoneNumber(defaultNum);
        }
      }
    }
  }

  Future<void> _pickContact() async {
    final status = await Permission.contacts.request();
    if (status.isGranted) {
      try {
        final contact = await FlutterContacts.openExternalPick();
        if (contact != null) {
          final fullContact = await FlutterContacts.getContact(contact.id);
          if (fullContact != null && fullContact.phones.isNotEmpty) {
            final number = fullContact.phones.first.number;
            _parseAndSetPhoneNumber(number);
          }
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Gagal memilih kontak: ${e.toString()}';
        });
      }
    } else {
      setState(() {
        _errorMessage = 'Izin akses kontak ditolak';
      });
    }
  }

  void _parseAndSetPhoneNumber(String rawNumber) {
    var number = rawNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    
    if (number.startsWith('+62')) {
      number = number.substring(3);
    } else if (number.startsWith('62')) {
      number = number.substring(2);
    } else if (number.startsWith('0')) {
      number = number.substring(1);
    }
    
    if (number.length >= 3) {
      _part2Controller.text = number.substring(0, 3);
      if (number.length >= 7) {
        _part3Controller.text = number.substring(3, 7);
        final remaining = number.substring(7);
        _part4Controller.text = remaining.substring(0, remaining.length > 4 ? 4 : remaining.length);
      } else {
        _part3Controller.text = number.substring(3);
        _part4Controller.clear();
      }
    } else {
      _part2Controller.text = number;
      _part3Controller.clear();
      _part4Controller.clear();
    }
    
    setState(() {
      _errorMessage = null;
    });
  }

  @override
  void dispose() {
    _part2Controller.dispose();
    _part3Controller.dispose();
    _part4Controller.dispose();
    _part2FocusNode.dispose();
    _part3FocusNode.dispose();
    _part4FocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final part2 = _part2Controller.text.trim();
    final part3 = _part3Controller.text.trim();
    final part4 = _part4Controller.text.trim();

    if (part2.length < 3 || part3.length < 4 || part4.length < 4) {
      setState(() {
        _errorMessage = 'Nomor WhatsApp belum lengkap';
      });
      return;
    }

    final cleanPhone = '62$part2$part3$part4';
    final formattedDate = widget.formatDateTime(widget.transaction.createdAt);
    
    final formattedMessage = '''
*STRUK TRANSAKSI RESMI PURWA DIGITAL*
----------------------------------------
*No. Referensi:* `${widget.transaction.refId}`
*Tanggal:* $formattedDate
*Kategori:* ${widget.transaction.category ?? '-'}
*Produk:* ${widget.transaction.productName}
*No. Pelanggan:* `${widget.transaction.customerNo}`
*Status:* *${widget.transaction.status.toUpperCase()}*
----------------------------------------
${widget.transaction.sn != null && widget.transaction.sn!.isNotEmpty ? '*SN / Keterangan:* \n`${widget.transaction.sn}`\n----------------------------------------\n' : ''}*TOTAL BAYAR:* *${widget.formatRupiah(widget.transaction.sellingPrice)}*
----------------------------------------
_Terima kasih telah menggunakan layanan Purwa Digital._
_Simpan resi ini sebagai bukti pembayaran yang sah._
''';

    final whatsappUrl = Uri.parse(
      'https://wa.me/$cleanPhone?text=${Uri.encodeComponent(formattedMessage)}',
    );

    Navigator.pop(context);

    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(whatsappUrl, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal membuka WhatsApp. Pastikan aplikasi terinstall.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 24.0,
        right: 24.0,
        top: 12.0,
        bottom: 24.0 + bottomInset,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xffE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bagikan ke WhatsApp',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xff0F172A),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Kirim struk / resi langsung ke pelanggan',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xff64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Nomor WhatsApp',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff64748B),
                ),
              ),
              TextButton.icon(
                onPressed: _pickContact,
                icon: Icon(Icons.contacts_rounded, size: 14, color: primaryColor),
                label: Text(
                  'Pilih Kontak',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Segmented Input Fields
          Row(
            children: [
              // Part 1: Country Code (+62)
              Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xffF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xffE2E8F0)),
                ),
                child: const Center(
                  child: Text(
                    '+62',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff475569),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              
              // Part 2: 3 Digits
              Expanded(
                flex: 3,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xffF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xffE2E8F0)),
                  ),
                  child: TextField(
                    controller: _part2Controller,
                    focusNode: _part2FocusNode,
                    keyboardType: TextInputType.phone,
                    textAlign: TextAlign.center,
                    maxLength: 4,
                    decoration: const InputDecoration(
                      hintText: '8XX',
                      counterText: '',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff0F172A),
                    ),
                    onChanged: (val) {
                      if (val.length >= 3) {
                        _part3FocusNode.requestFocus();
                      }
                      if (_errorMessage != null) {
                        setState(() {
                          _errorMessage = null;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              
              // Part 3: 4 Digits
              Expanded(
                flex: 4,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xffF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xffE2E8F0)),
                  ),
                  child: TextField(
                    controller: _part3Controller,
                    focusNode: _part3FocusNode,
                    keyboardType: TextInputType.phone,
                    textAlign: TextAlign.center,
                    maxLength: 4,
                    decoration: const InputDecoration(
                      hintText: 'XXXX',
                      counterText: '',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff0F172A),
                    ),
                    onChanged: (val) {
                      if (val.length >= 4) {
                        _part4FocusNode.requestFocus();
                      } else if (val.isEmpty) {
                        _part2FocusNode.requestFocus();
                      }
                      if (_errorMessage != null) {
                        setState(() {
                          _errorMessage = null;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              
              // Part 4: 4 Digits
              Expanded(
                flex: 4,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xffF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xffE2E8F0)),
                  ),
                  child: TextField(
                    controller: _part4Controller,
                    focusNode: _part4FocusNode,
                    keyboardType: TextInputType.phone,
                    textAlign: TextAlign.center,
                    maxLength: 4,
                    decoration: const InputDecoration(
                      hintText: 'XXXX',
                      counterText: '',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff0F172A),
                    ),
                    onChanged: (val) {
                      if (val.isEmpty) {
                        _part3FocusNode.requestFocus();
                      }
                      if (_errorMessage != null) {
                        setState(() {
                          _errorMessage = null;
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          const SizedBox(height: 28),
          
          // Submit Button
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Buka WhatsApp',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
