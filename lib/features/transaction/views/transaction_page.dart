import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../viewmodels/transaction_state.dart';
import '../viewmodels/transaction_viewmodel.dart';
import '../models/ppob_transaction_model.dart';
import 'transaction_detail_page.dart';

class TransactionPage extends ConsumerStatefulWidget {
  const TransactionPage({super.key});

  @override
  ConsumerState<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends ConsumerState<TransactionPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
        return const Color(0xff10B981); // Emerald Green
      case 'gagal':
      case 'failed':
        return const Color(0xffEF4444); // Crimson Red
      default:
        return const Color(0xffF59E0B); // Amber Yellow
    }
  }

  void _showFilterModal(BuildContext context, TransactionState state, TransactionViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        String tempCategory = state.filter.category.isEmpty ? 'Semua' : state.filter.category;
        String tempStatus = state.filter.status.isEmpty ? 'Semua' : state.filter.status;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Modal Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Transaksi',
                        style: TextStyle(
                          fontSize: 18,
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

                  // Category Filter
                  const Text(
                    'Kategori Layanan',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: state.categories.map((cat) {
                      final isSelected = tempCategory == cat;
                      return ChoiceChip(
                        selected: isSelected,
                        label: Text(cat),
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : const Color(0xff475569),
                        ),
                        selectedColor: Theme.of(context).primaryColor,
                        backgroundColor: const Color(0xffF1F5F9),
                        onSelected: (selected) {
                          setModalState(() {
                            tempCategory = cat;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Status Filter
                  const Text(
                    'Status Transaksi',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['Semua', 'Sukses', 'Pending', 'Gagal'].map((st) {
                      final isSelected = tempStatus.toLowerCase() == st.toLowerCase();
                      return ChoiceChip(
                        selected: isSelected,
                        label: Text(st),
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : const Color(0xff475569),
                        ),
                        selectedColor: Theme.of(context).primaryColor,
                        backgroundColor: const Color(0xffF1F5F9),
                        onSelected: (selected) {
                          setModalState(() {
                            tempStatus = st;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),

                  // Apply & Reset Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            viewModel.setCategory('Semua');
                            viewModel.setStatus('Semua');
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            viewModel.setCategory(tempCategory);
                            viewModel.setStatus(tempStatus);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: const Text('Terapkan Filter'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transactionViewModelProvider);
    final viewModel = ref.read(transactionViewModelProvider.notifier);

    final hasActiveFilter = state.filter.category.isNotEmpty || state.filter.status.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Transaksi PPOB',
          style: TextStyle(
            color: Color(0xff0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.tune_rounded, color: Color(0xff0F172A)),
                if (hasActiveFilter)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => _showFilterModal(context, state, viewModel),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => viewModel.loadInitialData(),
        child: Column(
          children: [
            // 1. Search Bar & Quick Filter Trigger Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      onSubmitted: (value) => viewModel.setSearch(value.trim()),
                      decoration: InputDecoration(
                        hintText: 'Cari No Pelanggan, Ref ID...',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  viewModel.setSearch('');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: const Color(0xffF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xffE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xffE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () => _showFilterModal(context, state, viewModel),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: hasActiveFilter
                            ? Theme.of(context).primaryColor.withOpacity(0.1)
                            : const Color(0xffF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: hasActiveFilter
                              ? Theme.of(context).primaryColor
                              : const Color(0xffE2E8F0),
                        ),
                      ),
                      child: Icon(
                        Icons.filter_list_rounded,
                        color: hasActiveFilter
                            ? Theme.of(context).primaryColor
                            : const Color(0xff64748B),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // 2. Active Filter Chips Indicator (jika ada filter yang aktif)
            if (hasActiveFilter)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                child: Row(
                  children: [
                    if (state.filter.category.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Chip(
                          label: Text(state.filter.category),
                          labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                          onDeleted: () => viewModel.setCategory('Semua'),
                          backgroundColor: const Color(0xffF1F5F9),
                        ),
                      ),
                    if (state.filter.status.isNotEmpty)
                      Chip(
                        label: Text(state.filter.status),
                        labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        onDeleted: () => viewModel.setStatus('Semua'),
                        backgroundColor: const Color(0xffF1F5F9),
                      ),
                  ],
                ),
              ),

            // 3. List Transaksi
            Expanded(
              child: state.isLoading
                  ? _buildListSkeleton()
                  : state.transactions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade300),
                              const SizedBox(height: 12),
                              Text(
                                'Tidak ada transaksi ditemukan',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                          itemCount: state.transactions.length,
                          itemBuilder: (context, index) {
                            final tx = state.transactions[index];
                            return _buildTransactionCard(context, tx);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, PPOBTransactionModel tx) {
    final statusColor = _getStatusColor(tx.status);

    // Tampilkan Nama Kategori murni (bukan Object)
    final categoryName = (tx.category != null && tx.category!.isNotEmpty)
        ? tx.category!
        : 'PPOB';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransactionDetailPage(transaction: tx),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xffE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.015),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Category Name Badge & Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xffF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      categoryName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: Color(0xff475569),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      tx.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        color: statusColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Row 2: Product Name
              Text(
                tx.productName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff0F172A),
                ),
              ),
              const SizedBox(height: 4),

              // Row 3: Customer Number & Price
              Row(
                children: [
                  Icon(Icons.phone_android_rounded, size: 14, color: Colors.grey.shade400),
                  const SizedBox(width: 4),
                  Text(
                    tx.customerNo,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatRupiah(tx.sellingPrice),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Color(0xff0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Serial Number Snippet (Jika ada)
              if (tx.sn != null && tx.sn!.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 4.0),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xffF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xffF1F5F9)),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'SN: ',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      Expanded(
                        child: Text(
                          tx.sn!,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xff334155)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, size: 16, color: Colors.grey),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12.0),
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          );
        },
      ),
    );
  }
}
