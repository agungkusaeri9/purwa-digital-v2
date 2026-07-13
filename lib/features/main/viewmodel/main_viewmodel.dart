import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purwa_digital/features/main/viewmodel/main_state.dart';

class MainViewModel extends Notifier<MainState> {
  @override
  MainState build() => const MainState();

  void changeTab(int index) {
    state = state.copyWith(currentIndex: index);
  }
}

final mainViewModelProvider = NotifierProvider<MainViewModel, MainState>(
  MainViewModel.new,
);
