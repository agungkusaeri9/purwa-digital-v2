import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  var _currentPage = 0;

  static const _slides = [
    _OnboardingSlide(
      icon: Icons.account_balance_wallet_rounded,
      title: 'Semua dalam satu aplikasi',
      description:
          'Akses layanan dan kebutuhan digital Anda dengan praktis dari satu tempat.',
    ),
    _OnboardingSlide(
      icon: Icons.flash_on_rounded,
      title: 'Cepat dan mudah',
      description:
          'Nikmati proses sederhana agar aktivitas digital Anda selesai lebih cepat.',
    ),
    _OnboardingSlide(
      icon: Icons.verified_user_rounded,
      title: 'Aman setiap saat',
      description:
          'Data dan aktivitas Anda dilindungi untuk pengalaman yang lebih tenang.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_currentPage == _slides.length - 1) {
      context.go('/login');
      return;
    }
    await _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLastPage = _currentPage == _slides.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Lewati'),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  itemBuilder: (context, index) =>
                      _OnboardingSlideView(slide: _slides[index]),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: index == _currentPage ? 26 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      color: index == _currentPage
                          ? colorScheme.primary
                          : colorScheme.outlineVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _next,
                  style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: Text(isLastPage ? 'Mulai' : 'Selanjutnya'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingSlide {
  const _OnboardingSlide(
      {required this.icon, required this.title, required this.description});
  final IconData icon;
  final String title;
  final String description;
}

class _OnboardingSlideView extends StatelessWidget {
  const _OnboardingSlideView({required this.slide});
  final _OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 168,
          height: 168,
          decoration: BoxDecoration(
              color: colorScheme.primaryContainer, shape: BoxShape.circle),
          child:
              Icon(slide.icon, size: 78, color: colorScheme.onPrimaryContainer),
        ),
        const SizedBox(height: 48),
        Text(
          slide.title,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 14),
        Text(
          slide.description,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: colorScheme.onSurfaceVariant, height: 1.5),
        ),
      ],
    );
  }
}
