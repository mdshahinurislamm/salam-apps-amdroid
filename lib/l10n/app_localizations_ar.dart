// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'تطبيقي';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get register => 'إنشاء حساب';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get firstName => 'الاسم الأول';

  @override
  String get lastName => 'اسم العائلة';

  @override
  String get loginButton => 'دخول';

  @override
  String get registerButton => 'إنشاء حساب';

  @override
  String get noAccount => 'ليس لديك حساب؟ ';

  @override
  String get haveAccount => 'لديك حساب بالفعل؟ ';

  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get language => 'اللغة';

  @override
  String get loadingPdf => 'جارٍ تحميل الملف...';

  @override
  String get errorLoadingPdf => 'خطأ في تحميل الملف';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get emailRequired => 'البريد الإلكتروني مطلوب';

  @override
  String get passwordRequired => 'كلمة المرور مطلوبة';

  @override
  String get nameRequired => 'الاسم مطلوب';

  @override
  String get loginError => 'البريد الإلكتروني أو كلمة المرور غير صحيحة';

  @override
  String get registerError => 'فشل التسجيل';

  @override
  String get networkError => 'خطأ في الشبكة. حاول مرة أخرى.';

  @override
  String get welcome => 'مرحباً';
}
