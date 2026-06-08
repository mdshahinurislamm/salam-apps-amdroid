import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';
  String get pdfLang => _locale.languageCode; // 'en' or 'ar'

  void setEnglish() {
    _locale = const Locale('en');
    notifyListeners();
  }

  void setArabic() {
    _locale = const Locale('ar');
    notifyListeners();
  }

  void toggle() {
    if (isArabic) {
      setEnglish();
    } else {
      setArabic();
    }
  }
}
