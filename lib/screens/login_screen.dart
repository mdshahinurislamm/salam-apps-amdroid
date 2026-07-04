import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import 'register_screen.dart';
import 'dashboard_screen.dart';
import 'otp_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    auth.clearError();
    final ok = await auth.login(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else {
      final isAr = context.read<LanguageProvider>().isArabic;

      // If email not verified → send to OTP screen
      if (auth.error == 'emailNotVerified') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.mark_email_unread_outlined,
                    color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isAr
                        ? 'يرجى التحقق من بريدك الإلكتروني أولاً'
                        : 'Please verify your email first',
                    textDirection:
                        isAr ? TextDirection.rtl : TextDirection.ltr,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.orange.shade700,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
            action: SnackBarAction(
              label: isAr ? 'تحقق' : 'Verify',
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OtpScreen(
                        email: _emailCtrl.text.trim(),
                        password: _passCtrl.text),
                  ),
                );
              },
            ),
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _mapError(auth.error, isAr),
                  textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  String _mapError(String? error, bool isAr) {
    if (error == null) return isAr ? 'فشل تسجيل الدخول' : 'Login failed';
    switch (error) {
      case 'invalidCredentials':
        return isAr
            ? 'البريد الإلكتروني أو كلمة المرور غير صحيحة'
            : 'Incorrect email or password';
      case 'emailNotVerified':
        return isAr
            ? 'يرجى التحقق من بريدك الإلكتروني أولاً'
            : 'Please verify your email first';
      case 'networkError':
        return isAr
            ? 'خطأ في الشبكة. حاول مرة أخرى.'
            : 'Network error. Please try again.';
      case 'timeoutError':
        return isAr
            ? 'انتهت مهلة الاتصال. حاول مرة أخرى.'
            : 'Connection timed out. Please try again.';
      default:
        return error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final auth = context.watch<AuthProvider>();
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
                  padding: const EdgeInsets.all(24),
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
                            labelText:
                                isAr ? 'البريد الإلكتروني' : 'Email',
                            prefixIcon: const Icon(Icons.email_outlined),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return isAr
                                  ? 'البريد الإلكتروني مطلوب'
                                  : 'Email is required';
                            }
                            if (!v.contains('@')) {
                              return isAr
                                  ? 'بريد إلكتروني غير صالح'
                                  : 'Invalid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passCtrl,
                          obscureText: _obscurePass,
                          textDirection: TextDirection.ltr,
                          textAlign: isAr ? TextAlign.right : TextAlign.left,
                          decoration: InputDecoration(
                            labelText:
                                isAr ? 'كلمة المرور' : 'Password',
                            prefixIcon: const Icon(Icons.lock_outlined),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePass
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              onPressed: () => setState(
                                  () => _obscurePass = !_obscurePass),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return isAr
                                  ? 'كلمة المرور مطلوبة'
                                  : 'Password is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: isAr
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const ForgotPasswordScreen()),
                            ),
                            style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 36)),
                            child: Text(
                              isAr ? 'نسيت كلمة المرور؟' : 'Forgot password?',
                              style: const TextStyle(
                                color: Color(0xFF9A9B78),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: auth.loading ? null : _submit,
                          child: auth.loading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  isAr ? 'تسجيل الدخول' : 'Sign In'),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                                child: Divider(
                                    color: Colors.grey.shade300)),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12),
                              child: Text(
                                isAr ? 'أو' : 'OR',
                                style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 13),
                              ),
                            ),
                            Expanded(
                                child: Divider(
                                    color: Colors.grey.shade300)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        OutlinedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const RegisterScreen()),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16),
                            side: const BorderSide(
                                color: Color(0xFF9A9B78)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            isAr
                                ? 'إنشاء حساب جديد'
                                : 'Create New Account',
                            style: const TextStyle(
                              color: Color(0xFF9A9B78),
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
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

  Widget _buildHeader(
      BuildContext context, bool isAr, LanguageProvider lang) {
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
            Align(
              alignment:
                  isAr ? Alignment.centerLeft : Alignment.centerRight,
              child: _LanguageToggle(provider: lang),
            ),
            const SizedBox(height: 28),
            Container(
              width: 64,
              height: 64,
              // decoration: BoxDecoration(
              //   color: Colors.white.withOpacity(0.2),
              //   borderRadius: BorderRadius.circular(16),
              // ),
            //   child: const Icon(Icons.picture_as_pdf,
            //       size: 36, color: Colors.white),
            // ),
             child: ClipRRect(
              // borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/logo.png', // <-- your image path
                // fit: BoxFit.cover,
              ),
            ),
            ),
            const SizedBox(height: 20),
            Text(
              isAr ? 'تسجيل الدخول' : 'Welcome Back',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isAr ? 'قم بتسجيل الدخول للمتابعة' : 'Sign in to continue',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF9A9B78) : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
