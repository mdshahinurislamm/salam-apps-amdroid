import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import 'dashboard_screen.dart';

// ─── Age group options ────────────────────────────────────────────────────────
const _ageGroups = [
  {'value': 'group_a', 'en': 'Group A', 'ar': 'المجموعة أ'},
  {'value': 'group_b', 'en': 'Group B', 'ar': 'المجموعة ب'},
];

// ─── Country list ─────────────────────────────────────────────────────────────
const _countries = [
  {'value': 'Afghanistan',    'en': 'Afghanistan',     'ar': 'أفغانستان'},
  {'value': 'Bangladesh',     'en': 'Bangladesh',      'ar': 'بنغلاديش'},
  {'value': 'Egypt',          'en': 'Egypt',           'ar': 'مصر'},
  {'value': 'India',          'en': 'India',           'ar': 'الهند'},
  {'value': 'Indonesia',      'en': 'Indonesia',       'ar': 'إندونيسيا'},
  {'value': 'Iran',           'en': 'Iran',            'ar': 'إيران'},
  {'value': 'Iraq',           'en': 'Iraq',            'ar': 'العراق'},
  {'value': 'Jordan',         'en': 'Jordan',          'ar': 'الأردن'},
  {'value': 'Kuwait',         'en': 'Kuwait',          'ar': 'الكويت'},
  {'value': 'Lebanon',        'en': 'Lebanon',         'ar': 'لبنان'},
  {'value': 'Libya',          'en': 'Libya',           'ar': 'ليبيا'},
  {'value': 'Malaysia',       'en': 'Malaysia',        'ar': 'ماليزيا'},
  {'value': 'Morocco',        'en': 'Morocco',         'ar': 'المغرب'},
  {'value': 'Nigeria',        'en': 'Nigeria',         'ar': 'نيجيريا'},
  {'value': 'Oman',           'en': 'Oman',            'ar': 'عمان'},
  {'value': 'Pakistan',       'en': 'Pakistan',        'ar': 'باكستان'},
  {'value': 'Palestine',      'en': 'Palestine',       'ar': 'فلسطين'},
  {'value': 'Qatar',          'en': 'Qatar',           'ar': 'قطر'},
  {'value': 'Saudi Arabia',   'en': 'Saudi Arabia',    'ar': 'المملكة العربية السعودية'},
  {'value': 'Sudan',          'en': 'Sudan',           'ar': 'السودان'},
  {'value': 'Syria',          'en': 'Syria',           'ar': 'سوريا'},
  {'value': 'Tunisia',        'en': 'Tunisia',         'ar': 'تونس'},
  {'value': 'Turkey',         'en': 'Turkey',          'ar': 'تركيا'},
  {'value': 'United Kingdom', 'en': 'United Kingdom',  'ar': 'المملكة المتحدة'},
  {'value': 'United States',  'en': 'United States',   'ar': 'الولايات المتحدة'},
  {'value': 'UAE',            'en': 'UAE',             'ar': 'الإمارات العربية المتحدة'},
  {'value': 'Yemen',          'en': 'Yemen',           'ar': 'اليمن'},
];

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirm = true;

  // New fields
  String? _selectedAge;
  String? _selectedCountry;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    auth.clearError();
    final ok = await auth.register(
      firstName: _firstNameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      age: _selectedAge!,
      country: _selectedCountry!,
    );
    if (!mounted) return;
    final isAr = context.read<LanguageProvider>().isArabic;
    if (ok) {
      // Show green success snackbar then navigate
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isAr
                      ? 'تم إنشاء الحساب بنجاح!'
                      : 'Account created successfully!',
                  textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (_) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  String _mapError(String? error, bool isAr) {
    if (error == null) return isAr ? 'فشل التسجيل' : 'Registration failed';
    switch (error) {
      case 'emailAlreadyExists':
        return isAr
            ? 'البريد الإلكتروني مستخدم بالفعل'
            : 'Email already exists. Please use a different one.';
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

  // ── Reusable dropdown builder ─────────────────────────────────────────────

  Widget _buildDropdown<T>({
    required bool isAr,
    required String labelEn,
    required String labelAr,
    required String hintEn,
    required String hintAr,
    required String validatorMsgEn,
    required String validatorMsgAr,
    required IconData icon,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: isAr ? labelAr : labelEn,
        hintText: isAr ? hintAr : hintEn,
        prefixIcon: Icon(icon),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      items: items,
      onChanged: onChanged,
      validator: (v) {
        if (v == null) {
          return isAr ? validatorMsgAr : validatorMsgEn;
        }
        return null;
      },
    );
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
                        // ── First Name ──────────────────────────────────────
                        TextFormField(
                          controller: _firstNameCtrl,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            labelText: isAr ? 'الاسم الأول' : 'First Name',
                            prefixIcon:
                                const Icon(Icons.person_outlined),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return isAr
                                  ? 'الاسم مطلوب'
                                  : 'Name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // ── Email ───────────────────────────────────────────
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          textDirection: TextDirection.ltr,
                          textAlign:
                              isAr ? TextAlign.right : TextAlign.left,
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
                            if (!v.contains('@') || !v.contains('.')) {
                              return isAr
                                  ? 'بريد إلكتروني غير صالح'
                                  : 'Invalid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // ── Age Group dropdown ──────────────────────────────
                        _buildDropdown<String>(
                          isAr: isAr,
                          labelEn: 'Age Group',
                          labelAr: 'الفئة العمرية',
                          hintEn: 'Select age group',
                          hintAr: 'اختر الفئة العمرية',
                          validatorMsgEn: 'Please select an age group',
                          validatorMsgAr: 'الرجاء اختيار الفئة العمرية',
                          icon: Icons.group_outlined,
                          value: _selectedAge,
                          items: _ageGroups
                              .map((g) => DropdownMenuItem<String>(
                                    value: g['value'],
                                    child: Text(isAr ? g['ar']! : g['en']!),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedAge = v),
                        ),
                        const SizedBox(height: 16),

                        // ── Country dropdown ────────────────────────────────
                        _buildDropdown<String>(
                          isAr: isAr,
                          labelEn: 'Country',
                          labelAr: 'الدولة',
                          hintEn: 'Select your country',
                          hintAr: 'اختر دولتك',
                          validatorMsgEn: 'Please select a country',
                          validatorMsgAr: 'الرجاء اختيار الدولة',
                          icon: Icons.public_outlined,
                          value: _selectedCountry,
                          items: _countries
                              .map((c) => DropdownMenuItem<String>(
                                    value: c['value'],
                                    child: Text(isAr ? c['ar']! : c['en']!),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedCountry = v),
                        ),
                        const SizedBox(height: 16),

                        // ── Password ────────────────────────────────────────
                        TextFormField(
                          controller: _passCtrl,
                          obscureText: _obscurePass,
                          textDirection: TextDirection.ltr,
                          textAlign:
                              isAr ? TextAlign.right : TextAlign.left,
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
                            if (v.length < 6) {
                              return isAr
                                  ? '٦ أحرف على الأقل'
                                  : 'Minimum 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // ── Confirm Password ────────────────────────────────
                        TextFormField(
                          controller: _confirmPassCtrl,
                          obscureText: _obscureConfirm,
                          textDirection: TextDirection.ltr,
                          textAlign:
                              isAr ? TextAlign.right : TextAlign.left,
                          decoration: InputDecoration(
                            labelText: isAr
                                ? 'تأكيد كلمة المرور'
                                : 'Confirm Password',
                            prefixIcon: const Icon(Icons.lock_outlined),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              onPressed: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return isAr
                                  ? 'تأكيد كلمة المرور مطلوب'
                                  : 'Please confirm password';
                            }
                            if (v != _passCtrl.text) {
                              return isAr
                                  ? 'كلمات المرور غير متطابقة'
                                  : 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 28),

                        // ── Register button ─────────────────────────────────
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
                                  isAr ? 'إنشاء الحساب' : 'Create Account'),
                        ),
                        const SizedBox(height: 20),

                        // ── Back to login ───────────────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isAr
                                  ? 'لديك حساب بالفعل؟ '
                                  : 'Already have an account? ',
                              style:
                                  TextStyle(color: Colors.grey.shade600),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                isAr ? 'تسجيل الدخول' : 'Sign In',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1565C0),
                                ),
                              ),
                            ),
                          ],
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
                    isAr
                        ? Icons.arrow_forward_ios
                        : Icons.arrow_back_ios,
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
              child: const Icon(Icons.person_add_outlined,
                  size: 36, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              isAr ? 'إنشاء حساب جديد' : 'Create Account',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isAr ? 'أنشئ حسابك للبدء' : 'Register to get started',
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
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
