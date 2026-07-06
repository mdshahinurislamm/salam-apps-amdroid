import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import 'login_screen.dart';

// Age group options (same as register screen)
const _ageGroups = [
  {'value': 'group_a', 'en': 'Ages 4-8', 'ar': 'للأعمار من 4 إلى 8 سنوات'},
  {'value': 'group_b', 'en': 'Ages 12-16', 'ar': 'للأعمار من 12 إلى 16 عاماً'},
];

// const _countries = [
//   {'value': 'Afghanistan',    'en': 'Afghanistan',    'ar': 'أفغانستان'},
//   {'value': 'Bangladesh',     'en': 'Bangladesh',     'ar': 'بنغلاديش'},
//   {'value': 'Egypt',          'en': 'Egypt',          'ar': 'مصر'},
//   {'value': 'India',          'en': 'India',          'ar': 'الهند'},
//   {'value': 'Indonesia',      'en': 'Indonesia',      'ar': 'إندونيسيا'},
//   {'value': 'Iran',           'en': 'Iran',           'ar': 'إيران'},
//   {'value': 'Iraq',           'en': 'Iraq',           'ar': 'العراق'},
//   {'value': 'Jordan',         'en': 'Jordan',         'ar': 'الأردن'},
//   {'value': 'Kuwait',         'en': 'Kuwait',         'ar': 'الكويت'},
//   {'value': 'Lebanon',        'en': 'Lebanon',        'ar': 'لبنان'},
//   {'value': 'Libya',          'en': 'Libya',          'ar': 'ليبيا'},
//   {'value': 'Malaysia',       'en': 'Malaysia',       'ar': 'ماليزيا'},
//   {'value': 'Morocco',        'en': 'Morocco',        'ar': 'المغرب'},
//   {'value': 'Nigeria',        'en': 'Nigeria',        'ar': 'نيجيريا'},
//   {'value': 'Oman',           'en': 'Oman',           'ar': 'عمان'},
//   {'value': 'Pakistan',       'en': 'Pakistan',       'ar': 'باكستان'},
//   {'value': 'Palestine',      'en': 'Palestine',      'ar': 'فلسطين'},
//   {'value': 'Qatar',          'en': 'Qatar',          'ar': 'قطر'},
//   {'value': 'Saudi Arabia',   'en': 'Saudi Arabia',   'ar': 'المملكة العربية السعودية'},
//   {'value': 'Sudan',          'en': 'Sudan',          'ar': 'السودان'},
//   {'value': 'Syria',          'en': 'Syria',          'ar': 'سوريا'},
//   {'value': 'Tunisia',        'en': 'Tunisia',        'ar': 'تونس'},
//   {'value': 'Turkey',         'en': 'Turkey',         'ar': 'تركيا'},
//   {'value': 'United Kingdom', 'en': 'United Kingdom', 'ar': 'المملكة المتحدة'},
//   {'value': 'United States',  'en': 'United States',  'ar': 'الولايات المتحدة'},
//   {'value': 'UAE',            'en': 'UAE',            'ar': 'الإمارات العربية المتحدة'},
//   {'value': 'Yemen',          'en': 'Yemen',          'ar': 'اليمن'},
// ];

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

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final auth = context.watch<AuthProvider>();
    final isAr = lang.isArabic;
    final user = auth.user;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: NestedScrollView(
          headerSliverBuilder: (_, __) => [
            SliverAppBar(
              expandedHeight: 320,
              pinned: true,
              backgroundColor: const Color(0xFF9A9B78),
              foregroundColor: Colors.white,
              leading: IconButton(
                icon: Icon(isAr
                    ? Icons.arrow_forward_ios
                    : Icons.arrow_back_ios),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: _ProfileHeader(user: user, isAr: isAr),
              ),
              bottom: TabBar(
                controller: _tabs,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: [
                  Tab(text: isAr ? 'الملف' : 'Profile'),
                  Tab(text: isAr ? 'الأمان' : 'Security'),
                  Tab(text: isAr ? 'الحساب' : 'Account'),
                ],
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabs,
            children: [
              _EditProfileTab(user: user, isAr: isAr),
              _ChangePasswordTab(isAr: isAr),
              _AccountTab(isAr: isAr),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Profile header with avatar ───────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final UserModel? user;
  final bool isAr;
  const _ProfileHeader({required this.user, required this.isAr});

  @override
  Widget build(BuildContext context) {
    final initials = _initials(user);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9A9B78), Color(0xFF9A9B78)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.6), width: 2),
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim(),
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? '',
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
          ),
        ],
      ),
    );
  }

  String _initials(UserModel? u) {
    if (u == null) return '?';
    final f = u.firstName.isNotEmpty ? u.firstName[0].toUpperCase() : '';
    final l = u.lastName.isNotEmpty ? u.lastName[0].toUpperCase() : '';
    return '$f$l'.isNotEmpty ? '$f$l' : '?';
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TAB 1 — Edit Profile
// ═════════════════════════════════════════════════════════════════════════════

class _EditProfileTab extends StatefulWidget {
  final UserModel? user;
  final bool isAr;
  const _EditProfileTab({required this.user, required this.isAr});

  @override
  State<_EditProfileTab> createState() => _EditProfileTabState();
}

class _EditProfileTabState extends State<_EditProfileTab> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _email;
  String? _selectedAge;
  String? _selectedCountry;
  bool _success = false;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _firstName = TextEditingController(text: u?.firstName ?? '');
    _lastName = TextEditingController(text: u?.lastName ?? '');
    _email = TextEditingController(text: u?.email ?? '');
    _selectedAge = _validAge(u?.age);
    _selectedCountry = _validCountry(u?.country);
  }

  String? _validAge(String? v) {
    if (v == null) return null;
    return _ageGroups.any((g) => g['value'] == v) ? v : null;
  }

  String? _validCountry(String? v) {
    if (v == null) return null;
    return _countries.any((c) => c['value'] == v) ? v : null;
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _success = false);
    final auth = context.read<AuthProvider>();
    auth.clearError();
    final ok = await auth.updateProfile(
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      email: _email.text.trim(),
      age: _selectedAge ?? '',
      country: _selectedCountry ?? '',
    );
    if (!mounted) return;
    if (ok) {
      setState(() => _success = true);
      ScaffoldMessenger.of(context).showSnackBar(_successSnack(
        widget.isAr ? 'تم تحديث الملف الشخصي' : 'Profile updated successfully',
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(_errorSnack(
        _mapError(auth.error, widget.isAr),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isAr = widget.isAr;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // First name
            _FieldLabel(isAr ? 'الاسم الأول' : 'First Name'),
            TextFormField(
              controller: _firstName,
              textCapitalization: TextCapitalization.words,
              decoration: _dec(Icons.person_outlined,
                  isAr ? 'الاسم الأول' : 'First name'),
              validator: (v) => (v == null || v.isEmpty)
                  ? (isAr ? 'مطلوب' : 'Required')
                  : null,
            ),
            const SizedBox(height: 16),

            // Last name
            _FieldLabel(isAr ? 'اسم العائلة' : 'Last Name'),
            TextFormField(
              controller: _lastName,
              textCapitalization: TextCapitalization.words,
              decoration:
                  _dec(Icons.person_outlined, isAr ? 'اسم العائلة' : 'Last name'),
            ),
            const SizedBox(height: 16),

            // Email
            _FieldLabel(isAr ? 'البريد الإلكتروني' : 'Email'),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textDirection: TextDirection.ltr,
              textAlign: isAr ? TextAlign.right : TextAlign.left,
              decoration: _dec(
                  Icons.email_outlined, isAr ? 'البريد الإلكتروني' : 'Email'),
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return isAr ? 'البريد مطلوب' : 'Email required';
                }
                if (!v.contains('@')) {
                  return isAr ? 'بريد غير صالح' : 'Invalid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Age group
            _FieldLabel(isAr ? 'الفئة العمرية' : 'Age Group'),
            DropdownButtonFormField<String>(
              value: _selectedAge,
              decoration: _dec(Icons.group_outlined,
                  isAr ? 'اختر الفئة' : 'Select age group'),
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              items: _ageGroups
                  .map((g) => DropdownMenuItem(
                        value: g['value'],
                        child: Text(isAr ? g['ar']! : g['en']!),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedAge = v),
            ),
            const SizedBox(height: 16),

            // Country
            _FieldLabel(isAr ? 'الدولة' : 'Country'),
            DropdownButtonFormField<String>(
              value: _selectedCountry,
              decoration:
                  _dec(Icons.public_outlined, isAr ? 'اختر الدولة' : 'Select country'),
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              items: _countries
                  .map((c) => DropdownMenuItem(
                        value: c['value'],
                        child: Text(isAr ? c['ar']! : c['en']!),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCountry = v),
            ),
            const SizedBox(height: 28),

            ElevatedButton.icon(
              onPressed: auth.loading ? null : _save,
              icon: auth.loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.save_outlined),
              label: Text(isAr ? 'حفظ التغييرات' : 'Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _dec(IconData icon, String hint) => InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );

  String _mapError(String? e, bool isAr) {
    if (e == 'networkError') return isAr ? 'خطأ في الشبكة' : 'Network error';
    if (e == 'unauthorizedError') return isAr ? 'انتهت الجلسة' : 'Session expired';
    return isAr ? 'فشل التحديث' : 'Update failed';
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TAB 2 — Change Password
// ═════════════════════════════════════════════════════════════════════════════

class _ChangePasswordTab extends StatefulWidget {
  final bool isAr;
  const _ChangePasswordTab({required this.isAr});

  @override
  State<_ChangePasswordTab> createState() => _ChangePasswordTabState();
}

class _ChangePasswordTabState extends State<_ChangePasswordTab> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _newPass = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscCurrent = true;
  bool _obscNew = true;
  bool _obscConfirm = true;

  @override
  void dispose() {
    _current.dispose();
    _newPass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    auth.clearError();
    final ok = await auth.changePassword(
      currentPassword: _current.text,
      newPassword: _newPass.text,
      newPasswordConfirmation: _confirm.text,
    );
    if (!mounted) return;
    if (ok) {
      _current.clear();
      _newPass.clear();
      _confirm.clear();
      ScaffoldMessenger.of(context).showSnackBar(_successSnack(
        widget.isAr ? 'تم تغيير كلمة المرور' : 'Password changed successfully',
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(_errorSnack(
        _mapError(auth.error, widget.isAr),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isAr = widget.isAr;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionCard(
              icon: Icons.lock_person_outlined,
              title: isAr ? 'تغيير كلمة المرور' : 'Change Password',
              subtitle: isAr
                  ? 'أدخل كلمة مرورك الحالية ثم الجديدة'
                  : 'Enter your current password then set a new one',
              children: [
                _passField(
                  ctrl: _current,
                  label: isAr ? 'كلمة المرور الحالية' : 'Current Password',
                  obscure: _obscCurrent,
                  toggle: () => setState(() => _obscCurrent = !_obscCurrent),
                  validator: (v) => (v == null || v.isEmpty)
                      ? (isAr ? 'مطلوب' : 'Required')
                      : null,
                ),
                const SizedBox(height: 16),
                _passField(
                  ctrl: _newPass,
                  label: isAr ? 'كلمة المرور الجديدة' : 'New Password',
                  obscure: _obscNew,
                  toggle: () => setState(() => _obscNew = !_obscNew),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return isAr ? 'مطلوب' : 'Required';
                    }
                    if (v.length < 6) {
                      return isAr ? '٦ أحرف على الأقل' : 'Min 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _passField(
                  ctrl: _confirm,
                  label: isAr ? 'تأكيد كلمة المرور' : 'Confirm New Password',
                  obscure: _obscConfirm,
                  toggle: () => setState(() => _obscConfirm = !_obscConfirm),
                  validator: (v) {
                    if (v != _newPass.text) {
                      return isAr ? 'كلمات المرور غير متطابقة' : 'Passwords do not match';
                    }
                    return null;
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: auth.loading ? null : _submit,
              icon: auth.loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.lock_reset_outlined),
              label: Text(isAr ? 'تغيير كلمة المرور' : 'Change Password'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _passField({
    required TextEditingController ctrl,
    required String label,
    required bool obscure,
    required VoidCallback toggle,
    required FormFieldValidator<String> validator,
  }) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      textDirection: TextDirection.ltr,
      textAlign: widget.isAr ? TextAlign.right : TextAlign.left,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outlined),
        suffixIcon: IconButton(
          icon: Icon(obscure
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined),
          onPressed: toggle,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: validator,
    );
  }

  String _mapError(String? e, bool isAr) {
    if (e == 'wrongCurrentPassword') {
      return isAr ? 'كلمة المرور الحالية غير صحيحة' : 'Current password is incorrect';
    }
    if (e == 'networkError') return isAr ? 'خطأ في الشبكة' : 'Network error';
    return isAr ? 'فشل تغيير كلمة المرور' : 'Failed to change password';
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TAB 3 — Account (Delete)
// ═════════════════════════════════════════════════════════════════════════════

class _AccountTab extends StatelessWidget {
  final bool isAr;
  const _AccountTab({required this.isAr});

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red.shade600),
            const SizedBox(width: 8),
            Text(isAr ? 'حذف الحساب' : 'Delete Account'),
          ],
        ),
        content: Text(
          isAr
              ? 'هذا الإجراء لا يمكن التراجع عنه.\nهل أنت متأكد أنك تريد حذف حسابك نهائياً؟'
              : 'This action cannot be undone.\nAre you sure you want to permanently delete your account?',
          style: const TextStyle(height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(isAr ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(isAr ? 'حذف نهائياً' : 'Delete Forever',
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final auth = context.read<AuthProvider>();
    final ok = await auth.deleteAccount();
    if (!context.mounted) return;
    if (ok) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(_errorSnack(
        isAr ? 'فشل حذف الحساب' : 'Failed to delete account',
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Info card
          _SectionCard(
            icon: Icons.info_outline_rounded,
            title: isAr ? 'معلومات الحساب' : 'Account Info',
            subtitle: '',
            children: [
              _InfoRow(
                label: isAr ? 'الاسم الكامل' : 'Full Name',
                value: '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim(),
                icon: Icons.person_outlined,
              ),
              const Divider(height: 24),
              _InfoRow(
                label: isAr ? 'البريد الإلكتروني' : 'Email',
                value: user?.email ?? '',
                icon: Icons.email_outlined,
              ),
              const Divider(height: 24),
              _InfoRow(
                label: isAr ? 'الفئة العمرية' : 'Age Group',
                value: _ageLabel(user?.age, isAr),
                icon: Icons.group_outlined,
              ),
              const Divider(height: 24),
              _InfoRow(
                label: isAr ? 'الدولة' : 'Country',
                value: _countryLabel(user?.country, isAr),
                icon: Icons.public_outlined,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Danger zone
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.dangerous_outlined, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Text(
                      isAr ? 'منطقة الخطر' : 'Danger Zone',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  isAr
                      ? 'حذف الحساب إجراء دائم لا يمكن التراجع عنه. ستُفقد جميع بياناتك.'
                      : 'Deleting your account is permanent and irreversible. All your data will be lost.',
                  style: TextStyle(
                      color: Colors.red.shade700, fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: auth.loading ? null : () => _confirmDelete(context),
                    icon: auth.loading
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.red.shade600))
                        : Icon(Icons.delete_forever_outlined,
                            color: Colors.red.shade700),
                    label: Text(
                      isAr ? 'حذف حسابي نهائياً' : 'Delete My Account',
                      style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.red.shade400),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _ageLabel(String? v, bool isAr) {
    if (v == null || v.isEmpty) return '—';
    final match = _ageGroups.firstWhere(
      (g) => g['value'] == v,
      orElse: () => {'en': v, 'ar': v, 'value': v},
    );
    return isAr ? match['ar']! : match['en']!;
  }

  String _countryLabel(String? v, bool isAr) {
    if (v == null || v.isEmpty) return '—';
    final match = _countries.firstWhere(
      (c) => c['value'] == v,
      orElse: () => {'en': v, 'ar': v, 'value': v},
    );
    return isAr ? match['ar']! : match['en']!;
  }
}

// ─── Shared small widgets ─────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text,
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.grey.shade700)),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Widget> children;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF9A9B78).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF9A9B78), size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  if (subtitle.isNotEmpty)
                    Text(subtitle,
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
            ],
          ),
          if (children.isNotEmpty) ...[
            const SizedBox(height: 20),
            ...children,
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade400),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Snackbar helpers ─────────────────────────────────────────────────────────

SnackBar _successSnack(String msg) => SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(msg)),
      ]),
      backgroundColor: const Color(0xFF2E7D32),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );

SnackBar _errorSnack(String msg) => SnackBar(
      content: Row(children: [
        const Icon(Icons.error_outline, color: Colors.white, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(msg)),
      ]),
      backgroundColor: Colors.red.shade700,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
