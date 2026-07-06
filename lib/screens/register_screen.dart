import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import 'dashboard_screen.dart';
import 'otp_screen.dart';

// ─── Age group options ────────────────────────────────────────────────────────
const _ageGroups = [
  {'value': 'group_a', 'en': 'Ages 4-8', 'ar': 'للأعمار من 4 إلى 8 سنوات'},
  {'value': 'group_b', 'en': 'Ages 12-16', 'ar': 'للأعمار من 12 إلى 16 عاماً'},
];

// ─── Country list ─────────────────────────────────────────────────────────────
const _countries = [
  {'value': 'Afghanistan', 'en': 'Afghanistan', 'ar': 'أفغانستان'},
  {'value': 'Albania', 'en': 'Albania', 'ar': 'ألبانيا'},
  {'value': 'Algeria', 'en': 'Algeria', 'ar': 'الجزائر'},
  {'value': 'Andorra', 'en': 'Andorra', 'ar': 'أندورا'},
  {'value': 'Angola', 'en': 'Angola', 'ar': 'أنغولا'},
  {'value': 'Antigua and Barbuda', 'en': 'Antigua and Barbuda', 'ar': 'أنتيغوا وباربودا'},
  {'value': 'Argentina', 'en': 'Argentina', 'ar': 'الأرجنتين'},
  {'value': 'Armenia', 'en': 'Armenia', 'ar': 'أرمينيا'},
  {'value': 'Australia', 'en': 'Australia', 'ar': 'أستراليا'},
  {'value': 'Austria', 'en': 'Austria', 'ar': 'النمسا'},
  {'value': 'Azerbaijan', 'en': 'Azerbaijan', 'ar': 'أذربيجان'},
  {'value': 'Bahamas', 'en': 'Bahamas', 'ar': 'البهاما'},
  {'value': 'Bahrain', 'en': 'Bahrain', 'ar': 'البحرين'},
  {'value': 'Bangladesh', 'en': 'Bangladesh', 'ar': 'بنغلاديش'},
  {'value': 'Barbados', 'en': 'Barbados', 'ar': 'باربادوس'},
  {'value': 'Belarus', 'en': 'Belarus', 'ar': 'بيلاروسيا'},
  {'value': 'Belgium', 'en': 'Belgium', 'ar': 'بلجيكا'},
  {'value': 'Belize', 'en': 'Belize', 'ar': 'بليز'},
  {'value': 'Benin', 'en': 'Benin', 'ar': 'بنين'},
  {'value': 'Bhutan', 'en': 'Bhutan', 'ar': 'بوتان'},
  {'value': 'Bolivia', 'en': 'Bolivia', 'ar': 'بوليفيا'},
  {'value': 'Bosnia and Herzegovina', 'en': 'Bosnia and Herzegovina', 'ar': 'البوسنة والهرسك'},
  {'value': 'Botswana', 'en': 'Botswana', 'ar': 'بوتسوانا'},
  {'value': 'Brazil', 'en': 'Brazil', 'ar': 'البرازيل'},
  {'value': 'Brunei', 'en': 'Brunei', 'ar': 'بروناي'},
  {'value': 'Bulgaria', 'en': 'Bulgaria', 'ar': 'بلغاريا'},
  {'value': 'Burkina Faso', 'en': 'Burkina Faso', 'ar': 'بوركينا فاسو'},
  {'value': 'Burundi', 'en': 'Burundi', 'ar': 'بوروندي'},
  {'value': 'Cabo Verde', 'en': 'Cabo Verde', 'ar': 'الرأس الأخضر'},
  {'value': 'Cambodia', 'en': 'Cambodia', 'ar': 'كمبوديا'},
  {'value': 'Cameroon', 'en': 'Cameroon', 'ar': 'الكاميرون'},
  {'value': 'Canada', 'en': 'Canada', 'ar': 'كندا'},
  {'value': 'Central African Republic', 'en': 'Central African Republic', 'ar': 'جمهورية أفريقيا الوسطى'},
  {'value': 'Chad', 'en': 'Chad', 'ar': 'تشاد'},
  {'value': 'Chile', 'en': 'Chile', 'ar': 'تشيلي'},
  {'value': 'China', 'en': 'China', 'ar': 'الصين'},
  {'value': 'Colombia', 'en': 'Colombia', 'ar': 'كولومبيا'},
  {'value': 'Comoros', 'en': 'Comoros', 'ar': 'جزر القمر'},
  {'value': 'Congo', 'en': 'Congo', 'ar': 'جمهورية الكونغو'},
  {'value': 'Costa Rica', 'en': 'Costa Rica', 'ar': 'كوستاريكا'},
  {'value': 'Croatia', 'en': 'Croatia', 'ar': 'كرواتيا'},
  {'value': 'Cuba', 'en': 'Cuba', 'ar': 'كوبا'},
  {'value': 'Cyprus', 'en': 'Cyprus', 'ar': 'قبرص'},
  {'value': 'Czech Republic', 'en': 'Czech Republic', 'ar': 'التشيك'},
  {'value': 'Democratic Republic of the Congo', 'en': 'Democratic Republic of the Congo', 'ar': 'جمهورية الكونغو الديمقراطية'},
  {'value': 'Denmark', 'en': 'Denmark', 'ar': 'الدنمارك'},
  {'value': 'Djibouti', 'en': 'Djibouti', 'ar': 'جيبوتي'},
  {'value': 'Dominica', 'en': 'Dominica', 'ar': 'دومينيكا'},
  {'value': 'Dominican Republic', 'en': 'Dominican Republic', 'ar': 'جمهورية الدومينيكان'},
  {'value': 'Ecuador', 'en': 'Ecuador', 'ar': 'الإكوادور'},
  {'value': 'Egypt', 'en': 'Egypt', 'ar': 'مصر'},
  {'value': 'El Salvador', 'en': 'El Salvador', 'ar': 'السلفادور'},
  {'value': 'Equatorial Guinea', 'en': 'Equatorial Guinea', 'ar': 'غينيا الاستوائية'},
  {'value': 'Eritrea', 'en': 'Eritrea', 'ar': 'إريتريا'},
  {'value': 'Estonia', 'en': 'Estonia', 'ar': 'إستونيا'},
  {'value': 'Eswatini', 'en': 'Eswatini', 'ar': 'إسواتيني'}, // Swaziland in older lists
  {'value': 'Ethiopia', 'en': 'Ethiopia', 'ar': 'إثيوبيا'},
  {'value': 'Fiji', 'en': 'Fiji', 'ar': 'فيجي'},
  {'value': 'Finland', 'en': 'Finland', 'ar': 'فنلندا'},
  {'value': 'France', 'en': 'France', 'ar': 'فرنسا'},
  {'value': 'Gabon', 'en': 'Gabon', 'ar': 'الغابون'},
  {'value': 'Gambia', 'en': 'Gambia', 'ar': 'غامبيا'},
  {'value': 'Georgia', 'en': 'Georgia', 'ar': 'جورجيا'},
  {'value': 'Germany', 'en': 'Germany', 'ar': 'ألمانيا'},
  {'value': 'Ghana', 'en': 'Ghana', 'ar': 'غانا'},
  {'value': 'Greece', 'en': 'Greece', 'ar': 'اليونان'},
  {'value': 'Grenada', 'en': 'Grenada', 'ar': 'جرينادا'},
  {'value': 'Guatemala', 'en': 'Guatemala', 'ar': 'غواتيمالا'},
  {'value': 'Guinea', 'en': 'Guinea', 'ar': 'غينيا'},
  {'value': 'Guinea-Bissau', 'en': 'Guinea-Bissau', 'ar': 'غينيا بيساو'},
  {'value': 'Guyana', 'en': 'Guyana', 'ar': 'غويانا'},
  {'value': 'Haiti', 'en': 'Haiti', 'ar': 'هايتي'},
  {'value': 'Honduras', 'en': 'Honduras', 'ar': 'هندوراس'},
  {'value': 'Hungary', 'en': 'Hungary', 'ar': 'المجر'},
  {'value': 'Iceland', 'en': 'Iceland', 'ar': 'آيسلندا'},
  {'value': 'India', 'en': 'India', 'ar': 'الهند'},
  {'value': 'Indonesia', 'en': 'Indonesia', 'ar': 'إندونيسيا'},
  {'value': 'Iran', 'en': 'Iran', 'ar': 'إيران'},
  {'value': 'Iraq', 'en': 'Iraq', 'ar': 'العراق'},
  {'value': 'Ireland', 'en': 'Ireland', 'ar': 'جمهورية أيرلندا'},
  {'value': 'Israel', 'en': 'Israel', 'ar': 'إسرائيل'},
  {'value': 'Italy', 'en': 'Italy', 'ar': 'إيطاليا'},
  {'value': 'Jamaica', 'en': 'Jamaica', 'ar': 'جامايكا'},
  {'value': 'Japan', 'en': 'Japan', 'ar': 'اليابان'},
  {'value': 'Jordan', 'en': 'Jordan', 'ar': 'الأردن'},
  {'value': 'Kazakhstan', 'en': 'Kazakhstan', 'ar': 'كازاخستان'},
  {'value': 'Kenya', 'en': 'Kenya', 'ar': 'كينيا'},
  {'value': 'Kiribati', 'en': 'Kiribati', 'ar': 'كيريباتي'},
  {'value': 'Kuwait', 'en': 'Kuwait', 'ar': 'الكويت'},
  {'value': 'Kyrgyzstan', 'en': 'Kyrgyzstan', 'ar': 'قرغيزستان'},
  {'value': 'Laos', 'en': 'Laos', 'ar': 'لاوس'},
  {'value': 'Latvia', 'en': 'Latvia', 'ar': 'لاتفيا'},
  {'value': 'Lebanon', 'en': 'Lebanon', 'ar': 'لبنان'},
  {'value': 'Lesotho', 'en': 'Lesotho', 'ar': 'ليسوتو'},
  {'value': 'Liberia', 'en': 'Liberia', 'ar': 'ليبيريا'},
  {'value': 'Libya', 'en': 'Libya', 'ar': 'ليبيا'},
  {'value': 'Liechtenstein', 'en': 'Liechtenstein', 'ar': 'ليختنشتاين'},
  {'value': 'Lithuania', 'en': 'Lithuania', 'ar': 'ليتوانيا'},
  {'value': 'Luxembourg', 'en': 'Luxembourg', 'ar': 'لوكسمبورغ'},
  {'value': 'Madagascar', 'en': 'Madagascar', 'ar': 'مدغشقر'},
  {'value': 'Malawi', 'en': 'Malawi', 'ar': 'مالاوي'},
  {'value': 'Malaysia', 'en': 'Malaysia', 'ar': 'ماليزيا'},
  {'value': 'Maldives', 'en': 'Maldives', 'ar': 'جزر المالديف'},
  {'value': 'Mali', 'en': 'Mali', 'ar': 'مالي'},
  {'value': 'Malta', 'en': 'Malta', 'ar': 'مالطا'},
  {'value': 'Marshall Islands', 'en': 'Marshall Islands', 'ar': 'جزر مارشال'},
  {'value': 'Mauritania', 'en': 'Mauritania', 'ar': 'موريتانيا'},
  {'value': 'Mauritius', 'en': 'Mauritius', 'ar': 'موريشيوس'},
  {'value': 'Mexico', 'en': 'Mexico', 'ar': 'المكسيك'},
  {'value': 'Micronesia', 'en': 'Micronesia', 'ar': 'مايكرونيزيا'},
  {'value': 'Moldova', 'en': 'Moldova', 'ar': 'مولدوفا'},
  {'value': 'Monaco', 'en': 'Monaco', 'ar': 'موناكو'},
  {'value': 'Mongolia', 'en': 'Mongolia', 'ar': 'منغوليا'},
  {'value': 'Montenegro', 'en': 'Montenegro', 'ar': 'الجبل الأسود'},
  {'value': 'Morocco', 'en': 'Morocco', 'ar': 'المغرب'},
  {'value': 'Mozambique', 'en': 'Mozambique', 'ar': 'موزمبيق'},
  {'value': 'Myanmar', 'en': 'Myanmar', 'ar': 'بورما'},
  {'value': 'Namibia', 'en': 'Namibia', 'ar': 'ناميبيا'},
  {'value': 'Nauru', 'en': 'Nauru', 'ar': 'ناورو'},
  {'value': 'Nepal', 'en': 'Nepal', 'ar': 'نيبال'},
  {'value': 'Netherlands', 'en': 'Netherlands', 'ar': 'هولندا'},
  {'value': 'New Zealand', 'en': 'New Zealand', 'ar': 'نيوزيلندا'},
  {'value': 'Nicaragua', 'en': 'Nicaragua', 'ar': 'نيكاراجوا'},
  {'value': 'Niger', 'en': 'Niger', 'ar': 'النيجر'},
  {'value': 'Nigeria', 'en': 'Nigeria', 'ar': 'نيجيريا'},
  {'value': 'North Korea', 'en': 'North Korea', 'ar': 'كوريا الشمالية'},
  {'value': 'North Macedonia', 'en': 'North Macedonia', 'ar': 'مقدونيا الشمالية'}, // Updated from older name
  {'value': 'Norway', 'en': 'Norway', 'ar': 'النرويج'},
  {'value': 'Oman', 'en': 'Oman', 'ar': 'سلطنة عمان'},
  {'value': 'Pakistan', 'en': 'Pakistan', 'ar': 'باكستان'},
  {'value': 'Palau', 'en': 'Palau', 'ar': 'بالاو'},
  {'value': 'Palestine', 'en': 'Palestine', 'ar': 'فلسطين'},
  {'value': 'Panama', 'en': 'Panama', 'ar': 'بنما'},
  {'value': 'Papua New Guinea', 'en': 'Papua New Guinea', 'ar': 'بابوا غينيا الجديدة'},
  {'value': 'Paraguay', 'en': 'Paraguay', 'ar': 'باراغواي'},
  {'value': 'Peru', 'en': 'Peru', 'ar': 'بيرو'},
  {'value': 'Philippines', 'en': 'Philippines', 'ar': 'الفلبين'},
  {'value': 'Poland', 'en': 'Poland', 'ar': 'بولندا'},
  {'value': 'Portugal', 'en': 'Portugal', 'ar': 'البرتغال'},
  {'value': 'Qatar', 'en': 'Qatar', 'ar': 'قطر'},
  {'value': 'Romania', 'en': 'Romania', 'ar': 'رومانيا'},
  {'value': 'Russia', 'en': 'Russia', 'ar': 'روسيا'},
  {'value': 'Rwanda', 'en': 'Rwanda', 'ar': 'رواندا'},
  {'value': 'Saint Kitts and Nevis', 'en': 'Saint Kitts and Nevis', 'ar': 'سانت كيتس ونيفيس'},
  {'value': 'Saint Lucia', 'en': 'Saint Lucia', 'ar': 'سانت لوسيا'},
  {'value': 'Saint Vincent and the Grenadines', 'en': 'Saint Vincent and the Grenadines', 'ar': 'سانت فنسينت والجرينادينز'},
  {'value': 'Samoa', 'en': 'Samoa', 'ar': 'ساموا'},
  {'value': 'San Marino', 'en': 'San Marino', 'ar': 'سان مارينو'},
  {'value': 'Sao Tome and Principe', 'en': 'Sao Tome and Principe', 'ar': 'ساو تومي وبرينسيب'},
  {'value': 'Saudi Arabia', 'en': 'Saudi Arabia', 'ar': 'السعودية'},
  {'value': 'Senegal', 'en': 'Senegal', 'ar': 'السنغال'},
  {'value': 'Serbia', 'en': 'Serbia', 'ar': 'صربيا'},
  {'value': 'Seychelles', 'en': 'Seychelles', 'ar': 'سيشيل'},
  {'value': 'Sierra Leone', 'en': 'Sierra Leone', 'ar': 'سيراليون'},
  {'value': 'Singapore', 'en': 'Singapore', 'ar': 'سنغافورة'},
  {'value': 'Slovakia', 'en': 'Slovakia', 'ar': 'سلوفاكيا'},
  {'value': 'Slovenia', 'en': 'Slovenia', 'ar': 'سلوفينيا'},
  {'value': 'Solomon Islands', 'en': 'Solomon Islands', 'ar': 'جزر سليمان'},
  {'value': 'Somalia', 'en': 'Somalia', 'ar': 'الصومال'},
  {'value': 'South Africa', 'en': 'South Africa', 'ar': 'جنوب أفريقيا'},
  {'value': 'South Korea', 'en': 'South Korea', 'ar': 'كوريا الجنوبية'},
  {'value': 'South Sudan', 'en': 'South Sudan', 'ar': 'جنوب السودان'},
  {'value': 'Spain', 'en': 'Spain', 'ar': 'إسبانيا'},
  {'value': 'Sri Lanka', 'en': 'Sri Lanka', 'ar': 'سريلانكا'},
  {'value': 'Sudan', 'en': 'Sudan', 'ar': 'السودان'},
  {'value': 'Suriname', 'en': 'Suriname', 'ar': 'سورينام'},
  {'value': 'Sweden', 'en': 'Sweden', 'ar': 'السويد'},
  {'value': 'Switzerland', 'en': 'Switzerland', 'ar': 'سويسرا'},
  {'value': 'Syria', 'en': 'Syria', 'ar': 'سوريا'},
  {'value': 'Taiwan', 'en': 'Taiwan', 'ar': 'تايوان'},
  {'value': 'Tajikistan', 'en': 'Tajikistan', 'ar': 'طاجيكستان'},
  {'value': 'Tanzania', 'en': 'Tanzania', 'ar': 'تنزانيا'},
  {'value': 'Thailand', 'en': 'Thailand', 'ar': 'تايلاند'},
  {'value': 'Timor-Leste', 'en': 'Timor-Leste', 'ar': 'تيمور الشرقية'},
  {'value': 'Togo', 'en': 'Togo', 'ar': 'توغو'},
  {'value': 'Tonga', 'en': 'Tonga', 'ar': 'تونجا'},
  {'value': 'Trinidad and Tobago', 'en': 'Trinidad and Tobago', 'ar': 'ترينيداد وتوباغو'},
  {'value': 'Tunisia', 'en': 'Tunisia', 'ar': 'تونس'},
  {'value': 'Turkey', 'en': 'Turkey', 'ar': 'تركيا'},
  {'value': 'Turkmenistan', 'en': 'Turkmenistan', 'ar': 'تركمانستان'},
  {'value': 'Tuvalu', 'en': 'Tuvalu', 'ar': 'توفالو'},
  {'value': 'Uganda', 'en': 'Uganda', 'ar': 'أوغندا'},
  {'value': 'Ukraine', 'en': 'Ukraine', 'ar': 'أوكرانيا'},
  {'value': 'United Arab Emirates', 'en': 'United Arab Emirates', 'ar': 'الإمارات العربية المتحدة'},
  {'value': 'United Kingdom', 'en': 'United Kingdom', 'ar': 'المملكة المتحدة'},
  {'value': 'United States', 'en': 'United States', 'ar': 'الولايات المتحدة'},
  {'value': 'Uruguay', 'en': 'Uruguay', 'ar': 'أوروغواي'},
  {'value': 'Uzbekistan', 'en': 'Uzbekistan', 'ar': 'أوزبكستان'},
  {'value': 'Vanuatu', 'en': 'Vanuatu', 'ar': 'فانواتو'},
  {'value': 'Vatican City', 'en': 'Vatican City', 'ar': 'مدينة الفاتيكان'},
  {'value': 'Venezuela', 'en': 'Venezuela', 'ar': 'فنزويلا'},
  {'value': 'Vietnam', 'en': 'Vietnam', 'ar': 'فيتنام'},
  {'value': 'Yemen', 'en': 'Yemen', 'ar': 'اليمن'},
  {'value': 'Zambia', 'en': 'Zambia', 'ar': 'زامبيا'},
  {'value': 'Zimbabwe', 'en': 'Zimbabwe', 'ar': 'زيمبابوي'},
];

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
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
    _lastNameCtrl.dispose();
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
      lastName: _lastNameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      age: _selectedAge!,
      country: _selectedCountry!,
    );
    if (!mounted) return;
    final isAr = context.read<LanguageProvider>().isArabic;
    if (ok) {
      // Navigate to OTP verification screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OtpScreen(
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text,
          ),
        ),
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

                        TextFormField(
                          controller: _lastNameCtrl,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            labelText: isAr ? 'اسم العائلة' : 'Last Name',
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
                                  color: Color(0xFF9A9B78),
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
            color: selected ? const Color(0xFF9A9B78) : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
