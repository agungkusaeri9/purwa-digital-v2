import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:purwa_digital/config/dependency_injection/core_providers.dart';
import '../services/ppob_service.dart';
import '../models/ppob_product_model.dart';
import 'pulsa_form_state.dart';

final ppobServiceProvider = Provider<PPOBService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PPOBService(apiClient);
});

final pulsaFormViewModelProvider =
    StateNotifierProvider.autoDispose<PulsaFormViewModel, PulsaFormState>((ref) {
  final service = ref.watch(ppobServiceProvider);
  return PulsaFormViewModel(service);
});

class PulsaFormViewModel extends StateNotifier<PulsaFormState> {
  final PPOBService _service;

  PulsaFormViewModel(this._service) : super(PulsaFormState());

  // Detect operator based on prefix
  String _detectProvider(String number) {
    if (number.length < 4) return '';
    final clean = number.replaceAll(RegExp(r'\D'), '');
    var prefix = clean;
    if (clean.startsWith('62')) {
      prefix = '0${clean.substring(2)}';
    } else if (clean.startsWith('+62')) {
      prefix = '0${clean.substring(3)}';
    }
    if (prefix.length < 4) return '';
    prefix = prefix.substring(0, 4);

    final telkomsel = ['0811', '0812', '0813', '0821', '0822', '0852', '0853', '0823'];
    final indosat = ['0814', '0815', '0816', '0855', '0856', '0857', '0858'];
    final xl = ['0817', '0818', '0819', '0859', '0877', '0878'];
    final axis = ['0838', '0831', '0832', '0833'];
    final tri = ['0895', '0896', '0897', '0898', '0899'];
    final smartfren = ['0881', '0882', '0883', '0884', '0885', '0886', '0887', '0888', '0889'];

    if (telkomsel.contains(prefix)) return 'Telkomsel';
    if (indosat.contains(prefix)) return 'Indosat';
    if (xl.contains(prefix)) return 'XL';
    if (axis.contains(prefix)) return 'Axis';
    if (tri.contains(prefix)) return 'Tri';
    if (smartfren.contains(prefix)) return 'Smartfren';

    return '';
  }

  void setInitialBrand(String brand) {
    state = state.copyWith(
      providerName: brand,
    );
    fetchProducts(brand);
  }

  void setPhoneNumber(String number) {
    final digits = number.replaceAll(RegExp(r'\D'), '');
    
    var clean = digits;
    if (digits.startsWith('62')) {
      clean = '0${digits.substring(2)}';
    } else if (digits.isNotEmpty && !digits.startsWith('0')) {
      clean = '0$digits';
    }

    state = state.copyWith(
      phoneNumber: clean,
    );
  }

  void selectProduct(PPOBProductModel product) {
    state = state.copyWith(selectedProduct: product);
  }

  Future<void> fetchProducts(String provider) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _service.getProducts(category: 'Pulsa', brand: provider);
      // Sort products by sellingPrice asc
      list.sort((a, b) => a.sellingPrice.compareTo(b.sellingPrice));
      state = state.copyWith(
        products: list,
        isLoading: false,
        selectedProduct: list.isNotEmpty ? list.first : null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal mengambil produk: ${e.toString()}',
      );
    }
  }

  Future<void> pickContact() async {
    final status = await Permission.contacts.request();
    if (status.isGranted) {
      try {
        final contact = await FlutterContacts.openExternalPick();
        if (contact != null) {
          final fullContact = await FlutterContacts.getContact(contact.id);
          if (fullContact != null && fullContact.phones.isNotEmpty) {
            var number = fullContact.phones.first.number;
            // Clean formatting characters like spaces or dashes
            number = number.replaceAll(RegExp(r'[^0-9+]'), '');
            setPhoneNumber(number);
          }
        }
      } catch (e) {
        state = state.copyWith(
          errorMessage: 'Gagal memilih kontak: ${e.toString()}',
        );
      }
    } else {
      state = state.copyWith(
        errorMessage: 'Izin akses kontak ditolak.',
      );
    }
  }

  Future<String?> submitTransaction({String? pin}) async {
    if (state.selectedProduct == null || state.phoneNumber.isEmpty) {
      state = state.copyWith(errorMessage: 'Nomor HP atau Produk belum diisi.');
      return null;
    }

    state = state.copyWith(isProcessing: true, errorMessage: null, successRefId: null);
    final refId = 'PD-${DateTime.now().millisecondsSinceEpoch}';

    try {
      await _service.createTransaction(
        buyerSkuCode: state.selectedProduct!.skuCode,
        customerNo: state.phoneNumber,
        refId: refId,
        pin: pin,
      );
      state = state.copyWith(
        isProcessing: false,
        successRefId: refId,
      );
      return refId;
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return null;
    }
  }
}
