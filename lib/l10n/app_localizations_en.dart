// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'My App';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get loginButton => 'Sign In';

  @override
  String get registerButton => 'Create Account';

  @override
  String get noAccount => 'Don\'t have an account? ';

  @override
  String get haveAccount => 'Already have an account? ';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get logout => 'Logout';

  @override
  String get language => 'Language';

  @override
  String get loadingPdf => 'Loading PDF...';

  @override
  String get errorLoadingPdf => 'Error loading PDF';

  @override
  String get retry => 'Retry';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get loginError => 'Invalid email or password';

  @override
  String get registerError => 'Registration failed';

  @override
  String get networkError => 'Network error. Please try again.';

  @override
  String get welcome => 'Welcome';
}
