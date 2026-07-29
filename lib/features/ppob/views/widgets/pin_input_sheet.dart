import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/pulsa_form_viewmodel.dart';

class PinInputSheet extends ConsumerStatefulWidget {
  final void Function(String pin)? onPinSubmitted;

  const PinInputSheet({
    super.key,
    this.onPinSubmitted,
  });

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      useSafeArea: false,
      barrierDismissible: false,
      builder: (context) => const PinInputSheet(),
    );
  }

  @override
  ConsumerState<PinInputSheet> createState() => _PinInputSheetState();
}

class _PinInputSheetState extends ConsumerState<PinInputSheet> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _pin = '';
  bool _isVerifying = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onDigitPressed(String digit) {
    if (_isVerifying || _pin.length >= 6) return;
    final newPin = _pin + digit;
    _updatePin(newPin);
  }

  void _onBackspacePressed() {
    if (_isVerifying || _pin.isEmpty) return;
    final newPin = _pin.substring(0, _pin.length - 1);
    _updatePin(newPin);
  }

  Future<void> _updatePin(String newPin) async {
    setState(() {
      _pin = newPin;
      _controller.text = newPin;
      _errorMessage = null;
    });

    // Auto-verify & auto-submit when exactly 6 digits are entered
    if (newPin.length == 6 && !_isVerifying) {
      setState(() {
        _isVerifying = true;
      });

      try {
        final service = ref.read(ppobServiceProvider);
        final isValid = await service.verifyPin(newPin);

        if (!mounted) return;

        if (isValid) {
          if (widget.onPinSubmitted != null) {
            widget.onPinSubmitted!(newPin);
          }
          Navigator.pop(context, newPin);
        } else {
          setState(() {
            _isVerifying = false;
            _errorMessage = 'PIN yang Anda masukkan salah. Silakan coba lagi.';
            _pin = '';
            _controller.clear();
          });
        }
      } catch (e) {
        if (!mounted) return;
        final errorMsg = e.toString().replaceAll('Exception: ', '');
        setState(() {
          _isVerifying = false;
          _errorMessage = errorMsg.contains('PIN') ? errorMsg : 'PIN yang Anda masukkan salah. Silakan coba lagi.';
          _pin = '';
          _controller.clear();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Close/Back Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 26, color: Color(0xff0F172A)),
                    onPressed: _isVerifying ? null : () => Navigator.pop(context, null),
                    tooltip: 'Batal',
                  ),
                  const Text(
                    'Verifikasi PIN',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff0F172A),
                    ),
                  ),
                  const SizedBox(width: 48), // Spacer to balance close icon
                ],
              ),
            ),

            // Centered Content Area
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Lock Icon
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: _errorMessage != null
                              ? Colors.red.shade50
                              : primaryColor.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _errorMessage != null ? Icons.lock_clock_rounded : Icons.lock_rounded,
                          color: _errorMessage != null ? Colors.red.shade600 : primaryColor,
                          size: 34,
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        'Masukkan PIN Transaksi',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color(0xff0F172A),
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Masukkan 6 digit PIN keamanan Anda untuk melanjutkan transaksi',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xff64748B),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // 6-Digit Dots Indicator / Verification Spinner
                      if (_isVerifying)
                        Column(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Memverifikasi PIN...',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        )
                      else
                        GestureDetector(
                          onTap: () => _focusNode.requestFocus(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(6, (index) {
                              final isFilled = index < _pin.length;
                              final isCurrent = index == _pin.length;

                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                margin: const EdgeInsets.symmetric(horizontal: 8),
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isFilled
                                      ? (_errorMessage != null ? Colors.red.shade600 : primaryColor)
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: _errorMessage != null
                                        ? Colors.red.shade600
                                        : (isFilled
                                            ? primaryColor
                                            : (isCurrent ? primaryColor : const Color(0xffCBD5E1))),
                                    width: isCurrent ? 2.5 : 1.5,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),

                      // Error Message Banner below PIN Dots
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.error_outline_rounded, size: 16, color: Colors.red.shade600),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 36),

                      // Custom 3x4 On-Screen Keypad (Centered & Clean)
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 320),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 1.4,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: 12,
                          itemBuilder: (context, index) {
                            if (index == 9) {
                              return const SizedBox.shrink(); // Empty bottom-left
                            } else if (index == 10) {
                              return _buildKeypadButton('0');
                            } else if (index == 11) {
                              return _buildBackspaceButton();
                            }
                            return _buildKeypadButton('${index + 1}');
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypadButton(String digit) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isVerifying ? null : () => _onDigitPressed(digit),
        borderRadius: BorderRadius.circular(20),
        splashColor: Theme.of(context).primaryColor.withOpacity(0.1),
        highlightColor: Theme.of(context).primaryColor.withOpacity(0.05),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xffF8FAFC),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xffF1F5F9)),
          ),
          child: Center(
            child: Text(
              digit,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xff0F172A),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isVerifying ? null : _onBackspacePressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xffF8FAFC),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xffF1F5F9)),
          ),
          child: const Center(
            child: Icon(
              Icons.backspace_outlined,
              size: 22,
              color: Color(0xff475569),
            ),
          ),
        ),
      ),
    );
  }
}
