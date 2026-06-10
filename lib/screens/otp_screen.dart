import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../services/api_service.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final String password; // needed for auto-login after verification
  const OtpScreen({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _ctrls =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());

  bool _loading = false;
  String? _error;
  bool _expired = false;

  final ApiService _api = ApiService();

  // ── Countdown (5 minutes = 300 seconds) ───────────────────────────────────
  static const int _totalSeconds = 300;
  int _secondsLeft = _totalSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) {
        t.cancel();
        _onExpired();
      }
    });
  }

  void _onExpired() {
    if (!mounted) return;
    setState(() => _expired = true);
    // Show expiry dialog then redirect to login
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        final isAr = context.read<LanguageProvider>().isArabic;
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.timer_off_outlined,
                    color: Colors.orange.shade700, size: 38),
              ),
              const SizedBox(height: 20),
              Text(
                isAr ? 'انتهت مهلة التحقق' : 'Time Expired',
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                isAr
                    ? 'انتهت صلاحية رمز التحقق.\nالرجاء تسجيل الدخول مرة أخرى.'
                    : 'Your OTP has expired.\nPlease sign in again.',
                style: TextStyle(
                    color: Colors.grey.shade600, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const LoginScreen()),
                    (_) => false,
                  ),
                  child:
                      Text(isAr ? 'الذهاب لتسجيل الدخول' : 'Go to Login'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _ctrls) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  String get _otpValue => _ctrls.map((c) => c.text).join();

  // Format seconds as MM:SS
  String get _timerLabel {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // Color transitions: green → orange → red as time runs out
  Color get _timerColor {
    if (_secondsLeft > 120) return const Color(0xFF2E7D32);
    if (_secondsLeft > 60) return Colors.orange.shade700;
    return Colors.red.shade600;
  }

  Future<void> _verify() async {
    if (_expired) return;
    final otp = _otpValue;
    if (otp.length < 6) {
      setState(() => _error = 'incomplete');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _api.verifyOtp(
        email: widget.email,
        otp: otp,
      );
      if (!mounted) return;

      if (result['success'] == true) {
        _timer?.cancel();
        // Auto-login with the credentials from registration
        final auth = context.read<AuthProvider>();
        final ok = await auth.login(
          email: widget.email,
          password: widget.password,
        );
        if (!mounted) return;
        if (ok) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
            (_) => false,
          );
        } else {
          // Login failed after verification — send to login screen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (_) => false,
          );
        }
      } else {
        setState(() {
          _error =
              (result['message'] ?? 'invalidOtp').toString().toLowerCase();
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onDigitChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.length == 6 && index == 0) {
      for (int i = 0; i < 6; i++) {
        _ctrls[i].text = value[i];
      }
      _focusNodes[5].requestFocus();
      setState(() {});
    }
  }

  void _onKeyDown(int index, RawKeyEvent event) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _ctrls[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final isAr = lang.isArabic;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(context, isAr, lang),
                Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Email chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.email_outlined,
                                color: Color(0xFF1565C0), size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.email,
                                style: const TextStyle(
                                  color: Color(0xFF1565C0),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Countdown timer ──────────────────────────────────
                      Center(
                        child: Column(
                          children: [
                            Text(
                              isAr ? 'ينتهي الرمز خلال' : 'Code expires in',
                              style: TextStyle(
                                  color: Colors.grey.shade500, fontSize: 13),
                            ),
                            const SizedBox(height: 8),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: _timerColor.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: _timerColor.withOpacity(0.3),
                                    width: 1.5),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.timer_outlined,
                                      color: _timerColor, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    _timerLabel,
                                    style: TextStyle(
                                      color: _timerColor,
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      fontFeatures: const [
                                        FontFeature.tabularFigures()
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Progress bar
                            SizedBox(
                              width: 160,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: _secondsLeft / _totalSeconds,
                                  backgroundColor:
                                      Colors.grey.shade200,
                                  valueColor:
                                      AlwaysStoppedAnimation(_timerColor),
                                  minHeight: 5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // OTP digit boxes (always LTR)
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(6, (i) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: _OtpBox(
                                controller: _ctrls[i],
                                focusNode: _focusNodes[i],
                                onChanged: (v) => _onDigitChanged(i, v),
                                onKeyEvent: (e) => _onKeyDown(i, e),
                                hasError: _error != null,
                                disabled: _expired,
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Error message
                      if (_error != null)
                        Center(
                          child: Text(
                            _mapError(_error!, isAr),
                            style: TextStyle(
                                color: Colors.red.shade600, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      const SizedBox(height: 28),

                      // Verify button
                      ElevatedButton(
                        onPressed: (_loading || _expired) ? null : _verify,
                        child: _loading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Text(isAr ? 'تحقق من الرمز' : 'Verify Code'),
                      ),
                      const SizedBox(height: 20),

                      // Back to login link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isAr ? 'لديك حساب؟ ' : 'Already have an account? ',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LoginScreen()),
                              (_) => false,
                            ),
                            child: Text(
                              isAr ? 'تسجيل الدخول' : 'Sign In',
                              style: const TextStyle(
                                color: Color(0xFF1565C0),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _mapError(String error, bool isAr) {
    if (error == 'incomplete') {
      return isAr
          ? 'الرجاء إدخال الرمز كاملاً'
          : 'Please enter the full 6-digit code';
    }
    if (error.contains('expired') || error.contains('otp expired')) {
      return isAr
          ? 'انتهت صلاحية الرمز'
          : 'OTP has expired. Please register again.';
    }
    if (error.contains('invalid') || error.contains('not found')) {
      return isAr
          ? 'رمز غير صحيح. حاول مرة أخرى.'
          : 'Invalid code. Please try again.';
    }
    if (error == 'networkError' || error.contains('network')) {
      return isAr
          ? 'خطأ في الشبكة. حاول مرة أخرى.'
          : 'Network error. Please try again.';
    }
    return isAr ? 'فشل التحقق. حاول مرة أخرى.' : 'Verification failed. Try again.';
  }

  Widget _buildHeader(
      BuildContext context, bool isAr, LanguageProvider lang) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    isAr ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                    color: Colors.white,
                  ),
                  padding: EdgeInsets.zero,
                ),
                _LanguageToggle(provider: lang),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.mark_email_read_outlined,
                  size: 36, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              isAr ? 'التحقق من البريد' : 'Email Verification',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isAr
                  ? 'أدخل الرمز المرسل إلى بريدك الإلكتروني'
                  : 'Enter the 6-digit code sent to your email',
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Single OTP digit box ─────────────────────────────────────────────────────

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<RawKeyEvent> onKeyEvent;
  final bool hasError;
  final bool disabled;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onKeyEvent,
    required this.hasError,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 54,
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: onKeyEvent,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          enabled: !disabled,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: onChanged,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: disabled ? Colors.grey.shade400 : Colors.black,
          ),
          decoration: InputDecoration(
            counterText: '',
            contentPadding: EdgeInsets.zero,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? Colors.red.shade400 : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: Colors.grey.shade200, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFF1565C0), width: 2),
            ),
            filled: true,
            fillColor: disabled
                ? Colors.grey.shade100
                : hasError
                    ? Colors.red.shade50
                    : Colors.white,
          ),
        ),
      ),
    );
  }
}

// ─── Language Toggle ──────────────────────────────────────────────────────────

class _LanguageToggle extends StatelessWidget {
  final LanguageProvider provider;
  const _LanguageToggle({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LangBtn(
              label: 'EN',
              selected: !provider.isArabic,
              onTap: provider.setEnglish),
          _LangBtn(
              label: 'AR',
              selected: provider.isArabic,
              onTap: provider.setArabic),
        ],
      ),
    );
  }
}

class _LangBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _LangBtn(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF1565C0) : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
