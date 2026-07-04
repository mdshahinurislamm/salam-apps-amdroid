import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Entry point: just exports the first step.
// The full flow lives in 3 private step widgets managed by a shared controller.
// ─────────────────────────────────────────────────────────────────────────────

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const _ForgotPasswordFlow();
}

// ─── Shared state passed down through the steps ───────────────────────────────

class _FlowState {
  String email = '';
  String otp = '';
}

// ─────────────────────────────────────────────────────────────────────────────
// Flow controller: manages which step is shown
// ─────────────────────────────────────────────────────────────────────────────

class _ForgotPasswordFlow extends StatefulWidget {
  const _ForgotPasswordFlow();

  @override
  State<_ForgotPasswordFlow> createState() => _ForgotPasswordFlowState();
}

class _ForgotPasswordFlowState extends State<_ForgotPasswordFlow> {
  int _step = 0; // 0 = email, 1 = otp, 2 = new password
  final _flow = _FlowState();

  void _goToOtp(String email) {
    _flow.email = email;
    setState(() => _step = 1);
  }

  void _goToReset(String otp) {
    _flow.otp = otp;
    setState(() => _step = 2);
  }

  @override
  Widget build(BuildContext context) {
    return switch (_step) {
      0 => _EmailStep(onSuccess: _goToOtp),
      1 => _OtpStep(flow: _flow, onSuccess: _goToReset),
      _ => _ResetStep(flow: _flow),
    };
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// STEP 1 — Email entry
// ═════════════════════════════════════════════════════════════════════════════

class _EmailStep extends StatefulWidget {
  final void Function(String email) onSuccess;
  const _EmailStep({required this.onSuccess});

  @override
  State<_EmailStep> createState() => _EmailStepState();
}

class _EmailStepState extends State<_EmailStep> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  final _api = ApiService();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await _api.forgotPassword(email: _emailCtrl.text.trim());
      if (!mounted) return;
      widget.onSuccess(_emailCtrl.text.trim());
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
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
                _Header(
                  isAr: isAr,
                  lang: lang,
                  icon: Icons.lock_reset_outlined,
                  title: isAr ? 'نسيت كلمة المرور' : 'Forgot Password',
                  subtitle: isAr
                      ? 'أدخل بريدك الإلكتروني وسنرسل لك رمز التحقق'
                      : 'Enter your email and we\'ll send you a reset code',
                ),
                Padding(
                  padding: const EdgeInsets.all(28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          textDirection: TextDirection.ltr,
                          textAlign: isAr ? TextAlign.right : TextAlign.left,
                          decoration: InputDecoration(
                            labelText: isAr ? 'البريد الإلكتروني' : 'Email Address',
                            prefixIcon: const Icon(Icons.email_outlined),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return isAr ? 'البريد الإلكتروني مطلوب' : 'Email is required';
                            }
                            if (!v.contains('@') || !v.contains('.')) {
                              return isAr ? 'بريد إلكتروني غير صالح' : 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        if (_error != null)
                          _ErrorBanner(message: _mapError(_error!, isAr)),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loading ? null : _submit,
                          child: _loading
                              ? _Spinner()
                              : Text(isAr ? 'إرسال رمز التحقق' : 'Send Reset Code'),
                        ),
                        const SizedBox(height: 20),
                        _BackToLogin(isAr: isAr),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _mapError(String e, bool isAr) {
    if (e == 'userNotFound') {
      return isAr ? 'البريد الإلكتروني غير مسجل' : 'No account found with this email';
    }
    if (e == 'networkError') {
      return isAr ? 'خطأ في الشبكة. حاول مرة أخرى.' : 'Network error. Please try again.';
    }
    if (e == 'timeoutError') {
      return isAr ? 'انتهت مهلة الاتصال' : 'Connection timed out';
    }
    return isAr ? 'فشل الإرسال. حاول مرة أخرى.' : 'Failed to send. Please try again.';
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// STEP 2 — OTP verification with 5-minute countdown
// ═════════════════════════════════════════════════════════════════════════════

class _OtpStep extends StatefulWidget {
  final _FlowState flow;
  final void Function(String otp) onSuccess;
  const _OtpStep({required this.flow, required this.onSuccess});

  @override
  State<_OtpStep> createState() => _OtpStepState();
}

class _OtpStepState extends State<_OtpStep> {
  final List<TextEditingController> _ctrls =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());

  bool _loading = false;
  bool _expired = false;
  String? _error;

  static const int _totalSecs = 300;
  int _secsLeft = _totalSecs;
  Timer? _timer;

  final _api = ApiService();

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _secsLeft--);
      if (_secsLeft <= 0) { t.cancel(); _onExpired(); }
    });
  }

  void _onExpired() {
    if (!mounted) return;
    setState(() => _expired = true);
    final isAr = context.read<LanguageProvider>().isArabic;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ExpiredDialog(
        isAr: isAr,
        onGoLogin: () => Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _ctrls) c.dispose();
    for (final f in _nodes) f.dispose();
    super.dispose();
  }

  String get _otpValue => _ctrls.map((c) => c.text).join();
  String get _timerLabel {
    final m = (_secsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
  Color get _timerColor {
    if (_secsLeft > 120) return const Color(0xFF2E7D32);
    if (_secsLeft > 60) return Colors.orange.shade700;
    return Colors.red.shade600;
  }

  void _onDigitChanged(int i, String v) {
    if (v.length == 1 && i < 5) _nodes[i + 1].requestFocus();
    if (v.length == 6 && i == 0) {
      for (int j = 0; j < 6; j++) _ctrls[j].text = v[j];
      _nodes[5].requestFocus();
      setState(() {});
    }
  }

  void _onKey(int i, RawKeyEvent e) {
    if (e is RawKeyDownEvent &&
        e.logicalKey == LogicalKeyboardKey.backspace &&
        _ctrls[i].text.isEmpty && i > 0) {
      _nodes[i - 1].requestFocus();
    }
  }

  Future<void> _verify() async {
    if (_expired) return;
    if (_otpValue.length < 6) { setState(() => _error = 'incomplete'); return; }
    setState(() { _loading = true; _error = null; });
    try {
      await _api.verifyResetOtp(
        email: widget.flow.email,
        otp: _otpValue,
      );
      if (!mounted) return;
      _timer?.cancel();
      widget.onSuccess(_otpValue);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
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
                _Header(
                  isAr: isAr,
                  lang: lang,
                  icon: Icons.mark_email_read_outlined,
                  title: isAr ? 'رمز التحقق' : 'Enter Reset Code',
                  subtitle: isAr
                      ? 'أدخل الرمز المرسل إلى ${widget.flow.email}'
                      : 'Enter the code sent to ${widget.flow.email}',
                ),
                Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Countdown timer
                      Center(
                        child: Column(
                          children: [
                            Text(
                              isAr ? 'ينتهي الرمز خلال' : 'Code expires in',
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                            ),
                            const SizedBox(height: 8),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: _timerColor.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: _timerColor.withOpacity(0.3), width: 1.5),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.timer_outlined, color: _timerColor, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    _timerLabel,
                                    style: TextStyle(
                                      color: _timerColor,
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      fontFeatures: const [FontFeature.tabularFigures()],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                              width: 160,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: _secsLeft / _totalSecs,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: AlwaysStoppedAnimation(_timerColor),
                                  minHeight: 5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // OTP boxes
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(6, (i) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: _OtpBox(
                              controller: _ctrls[i],
                              focusNode: _nodes[i],
                              onChanged: (v) => _onDigitChanged(i, v),
                              onKeyEvent: (e) => _onKey(i, e),
                              hasError: _error != null,
                              disabled: _expired,
                            ),
                          )),
                        ),
                      ),
                      const SizedBox(height: 14),

                      if (_error != null)
                        _ErrorBanner(message: _mapError(_error!, isAr)),

                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: (_loading || _expired) ? null : _verify,
                        child: _loading ? _Spinner() : Text(isAr ? 'تحقق من الرمز' : 'Verify Code'),
                      ),
                      const SizedBox(height: 20),
                      _BackToLogin(isAr: isAr),
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

  String _mapError(String e, bool isAr) {
    if (e == 'incomplete') return isAr ? 'الرجاء إدخال الرمز كاملاً' : 'Enter the full 6-digit code';
    if (e == 'otpExpired') return isAr ? 'انتهت صلاحية الرمز. ابدأ من جديد.' : 'Code expired. Please start over.';
    if (e == 'invalidOtp') return isAr ? 'رمز غير صحيح. حاول مرة أخرى.' : 'Invalid code. Please try again.';
    if (e == 'networkError') return isAr ? 'خطأ في الشبكة.' : 'Network error.';
    return isAr ? 'فشل التحقق.' : 'Verification failed.';
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// STEP 3 — New password entry
// ═════════════════════════════════════════════════════════════════════════════

class _ResetStep extends StatefulWidget {
  final _FlowState flow;
  const _ResetStep({required this.flow});

  @override
  State<_ResetStep> createState() => _ResetStepState();
}

class _ResetStepState extends State<_ResetStep> {
  final _formKey = GlobalKey<FormState>();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _error;
  bool _done = false;

  final _api = ApiService();

  @override
  void dispose() {
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await _api.resetPassword(
        email: widget.flow.email,
        otp: widget.flow.otp,
        password: _passCtrl.text,
        passwordConfirmation: _confirmCtrl.text,
      );
      if (!mounted) return;
      setState(() => _done = true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final isAr = lang.isArabic;

    if (_done) return _SuccessScreen(isAr: isAr, lang: lang);

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _Header(
                  isAr: isAr,
                  lang: lang,
                  icon: Icons.lock_outlined,
                  title: isAr ? 'كلمة مرور جديدة' : 'New Password',
                  subtitle: isAr
                      ? 'أنشئ كلمة مرور جديدة لحسابك'
                      : 'Create a new password for your account',
                ),
                Padding(
                  padding: const EdgeInsets.all(28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // New password
                        TextFormField(
                          controller: _passCtrl,
                          obscureText: _obscurePass,
                          textDirection: TextDirection.ltr,
                          textAlign: isAr ? TextAlign.right : TextAlign.left,
                          decoration: InputDecoration(
                            labelText: isAr ? 'كلمة المرور الجديدة' : 'New Password',
                            prefixIcon: const Icon(Icons.lock_outlined),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePass
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined),
                              onPressed: () => setState(() => _obscurePass = !_obscurePass),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return isAr ? 'كلمة المرور مطلوبة' : 'Password is required';
                            }
                            if (v.length < 6) {
                              return isAr ? '٦ أحرف على الأقل' : 'Minimum 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Confirm password
                        TextFormField(
                          controller: _confirmCtrl,
                          obscureText: _obscureConfirm,
                          textDirection: TextDirection.ltr,
                          textAlign: isAr ? TextAlign.right : TextAlign.left,
                          decoration: InputDecoration(
                            labelText: isAr ? 'تأكيد كلمة المرور' : 'Confirm Password',
                            prefixIcon: const Icon(Icons.lock_outlined),
                            suffixIcon: IconButton(
                              icon: Icon(_obscureConfirm
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined),
                              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return isAr ? 'تأكيد كلمة المرور مطلوب' : 'Please confirm password';
                            }
                            if (v != _passCtrl.text) {
                              return isAr ? 'كلمات المرور غير متطابقة' : 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        if (_error != null)
                          _ErrorBanner(message: _mapError(_error!, isAr)),

                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loading ? null : _submit,
                          child: _loading
                              ? _Spinner()
                              : Text(isAr ? 'إعادة تعيين كلمة المرور' : 'Reset Password'),
                        ),
                        const SizedBox(height: 20),
                        _BackToLogin(isAr: isAr),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _mapError(String e, bool isAr) {
    if (e == 'networkError') return isAr ? 'خطأ في الشبكة.' : 'Network error.';
    if (e == 'timeoutError') return isAr ? 'انتهت مهلة الاتصال.' : 'Connection timed out.';
    return isAr ? 'فشل التحديث. حاول مرة أخرى.' : 'Reset failed. Please try again.';
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Success screen shown after password reset
// ═════════════════════════════════════════════════════════════════════════════

class _SuccessScreen extends StatelessWidget {
  final bool isAr;
  final LanguageProvider lang;
  const _SuccessScreen({required this.isAr, required this.lang});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  margin: const EdgeInsets.only(bottom: 32),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_outline_rounded,
                      color: Color(0xFF2E7D32), size: 56),
                ),
                Text(
                  isAr ? 'تم بنجاح!' : 'Password Reset!',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                Text(
                  isAr
                      ? 'تم تغيير كلمة مرورك بنجاح.\nيمكنك الآن تسجيل الدخول بكلمة المرور الجديدة.'
                      : 'Your password has been changed successfully.\nYou can now sign in with your new password.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 15, height: 1.6),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (_) => false,
                  ),
                  icon: const Icon(Icons.login_rounded),
                  label: Text(isAr ? 'تسجيل الدخول' : 'Sign In'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Shared small widgets
// ═════════════════════════════════════════════════════════════════════════════

class _Header extends StatelessWidget {
  final bool isAr;
  final LanguageProvider lang;
  final IconData icon;
  final String title;
  final String subtitle;

  const _Header({
    required this.isAr,
    required this.lang,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9A9B78), Color(0xFF9A9B78)],
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
                  onPressed: () => Navigator.canPop(context)
                      ? Navigator.pop(context)
                      : Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (_) => false,
                        ),
                  icon: Icon(
                    isAr ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                    color: Colors.white,
                  ),
                  padding: EdgeInsets.zero,
                ),
                _LangToggle(provider: lang),
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
              child: Icon(icon, size: 34, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(title,
                style: const TextStyle(
                    color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(subtitle,
                style:
                    TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: TextStyle(color: Colors.red.shade700, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _BackToLogin extends StatelessWidget {
  final bool isAr;
  const _BackToLogin({required this.isAr});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: () => Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        ),
        icon: Icon(
          isAr ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
          size: 14,
          color: const Color(0xFF9A9B78),
        ),
        label: Text(
          isAr ? 'العودة لتسجيل الدخول' : 'Back to Sign In',
          style: const TextStyle(
              color: Color(0xFF9A9B78), fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _ExpiredDialog extends StatelessWidget {
  final bool isAr;
  final VoidCallback onGoLogin;
  const _ExpiredDialog({required this.isAr, required this.onGoLogin});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
                color: Colors.orange.shade50, shape: BoxShape.circle),
            child: Icon(Icons.timer_off_outlined,
                color: Colors.orange.shade700, size: 38),
          ),
          const SizedBox(height: 20),
          Text(
            isAr ? 'انتهت مهلة الرمز' : 'Code Expired',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            isAr
                ? 'انتهت صلاحية رمز التحقق.\nيرجى طلب رمز جديد.'
                : 'The reset code has expired.\nPlease request a new one.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onGoLogin,
              child: Text(isAr ? 'العودة لتسجيل الدخول' : 'Back to Sign In'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Spinner extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
      );
}

// ─── OTP digit box (reused from otp_screen) ───────────────────────────────────

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
                  width: 1.5),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF9A9B78), width: 2),
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

// ─── Language toggle (local copy) ─────────────────────────────────────────────

class _LangToggle extends StatelessWidget {
  final LanguageProvider provider;
  const _LangToggle({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _LBtn(label: 'EN', selected: !provider.isArabic, onTap: provider.setEnglish),
        _LBtn(label: 'AR', selected: provider.isArabic, onTap: provider.setArabic),
      ]),
    );
  }
}

class _LBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _LBtn({required this.label, required this.selected, required this.onTap});

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
        child: Text(label,
            style: TextStyle(
              color: selected ? const Color(0xFF9A9B78) : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            )),
      ),
    );
  }
}
