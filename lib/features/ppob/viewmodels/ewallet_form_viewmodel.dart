import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/ppob_service.dart';
import '../models/ppob_product_model.dart';
import 'ewallet_form_state.dart';
import 'pulsa_form_viewmodel.dart'; // Reuse ppobServiceProvider

final ewalletFormViewModelProvider =
    StateNotifierProvider.autoDispose<EWalletFormViewModel, EWalletFormState>((ref) {
  final service = ref.watch(ppobServiceProvider);
  return EWalletFormViewModel(service);
});

class EWalletFormViewModel extends StateNotifier<EWalletFormState> {
  final PPOBService _service;

  EWalletFormViewModel(this._service) : super(EWalletFormState());

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
      var list = await _service.getProducts(category: 'e-money', brand: provider);
      if (list.isEmpty) {
        list = await _service.getProducts(category: 'emoney', brand: provider);
      }
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
        errorMessage: 'Gagal mengambil produk e-wallet: ${e.toString()}',
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
      state = state.copyWith(errorMessage: 'Nomor HP atau Nominal e-wallet belum diisi.');
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
