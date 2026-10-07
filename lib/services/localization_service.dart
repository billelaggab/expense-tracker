import 'package:flutter/material.dart';

enum AppLanguage { arabic, english }

class LocalizationService with ChangeNotifier {
  AppLanguage _currentLanguage = AppLanguage.arabic;

  AppLanguage get currentLanguage => _currentLanguage;
  Locale get currentLocale => _currentLanguage == AppLanguage.arabic
    ? const Locale('ar', 'SA')
    : const Locale('en', 'US');

  bool get isArabic => _currentLanguage == AppLanguage.arabic;

  void toggleLanguage() {
    _currentLanguage = _currentLanguage == AppLanguage.arabic
      ? AppLanguage.english
      : AppLanguage.arabic;
    notifyListeners();
  }

  static final Map<String, Map<AppLanguage, String>> _strings = {
    'app_title': {AppLanguage.arabic: 'متعقب المصاريف', AppLanguage.english: 'Expense Tracker'},
    'total_monthly': {AppLanguage.arabic: 'إجمالي الشهر', AppLanguage.english: 'Monthly Total'},
    'currency': {AppLanguage.arabic: 'ر.س', AppLanguage.english: 'SAR'},
    'add_expense': {AppLanguage.arabic: 'إضافة عملية', AppLanguage.english: 'Add Transaction'},
    'history': {AppLanguage.arabic: 'السجل', AppLanguage.english: 'History'},
    'dashboard': {AppLanguage.arabic: 'الرئيسية', AppLanguage.english: 'Dashboard'},
    'categories': {AppLanguage.arabic: 'التصنيفات', AppLanguage.english: 'Categories'},
    'title': {AppLanguage.arabic: 'العنوان', AppLanguage.english: 'Title'},
    'amount': {AppLanguage.arabic: 'المبلغ', AppLanguage.english: 'Amount'},
    'category': {AppLanguage.arabic: 'التصنيف', AppLanguage.english: 'Category'},
    'date': {AppLanguage.arabic: 'التاريخ', AppLanguage.english: 'Date'},
    'notes': {AppLanguage.arabic: 'ملاحظات', AppLanguage.english: 'Notes'},
    'save': {AppLanguage.arabic: 'حفظ', AppLanguage.english: 'Save'},
    'cancel': {AppLanguage.arabic: 'إلغاء', AppLanguage.english: 'Cancel'},
    'food': {AppLanguage.arabic: 'طعام', AppLanguage.english: 'Food'},
    'transport': {AppLanguage.arabic: 'مواصلات', AppLanguage.english: 'Transport'},
    'utilities': {AppLanguage.arabic: 'فواتير وخدمات', AppLanguage.english: 'Utilities'},
    'shopping': {AppLanguage.arabic: 'تسوق', AppLanguage.english: 'Shopping'},
    'health': {AppLanguage.arabic: 'صحة', AppLanguage.english: 'Health'},
    'other': {AppLanguage.arabic: 'أخرى', AppLanguage.english: 'Other'},
    'search': {AppLanguage.arabic: 'بحث...', AppLanguage.english: 'Search...'},
    'all': {AppLanguage.arabic: 'الكل', AppLanguage.english: 'All'},
    'no_transactions': {AppLanguage.arabic: 'لا توجد معاملات', AppLanguage.english: 'No transactions'},
    'stats': {AppLanguage.arabic: 'الإحصائيات', AppLanguage.english: 'Statistics'},
  };

  String translate(String key) {
    return _strings[key]?[_currentLanguage] ?? key;
  }
}
