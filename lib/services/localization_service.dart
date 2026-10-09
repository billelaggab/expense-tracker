import 'package:flutter/material.dart';

enum AppLanguage { arabic, english }

class LocalizationService with ChangeNotifier {
  AppLanguage _currentLanguage = AppLanguage.arabic;

  AppLanguage get currentLanguage => _currentLanguage;
  Locale get currentLocale => _currentLanguage == AppLanguage.arabic
    ? const Locale('ar', 'DZ')
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
    'currency': {AppLanguage.arabic: 'دج', AppLanguage.english: 'DZD'},
    'add_expense': {AppLanguage.arabic: 'إضافة عملية', AppLanguage.english: 'Add Transaction'},
    'history': {AppLanguage.arabic: 'السجل', AppLanguage.english: 'History'},
    'dashboard': {AppLanguage.arabic: 'الرئيسية', AppLanguage.english: 'Dashboard'},
    'categories': {AppLanguage.arabic: 'التصنيفات', AppLanguage.english: 'Categories'},
    'title': {AppLanguage.arabic: 'اسم عملية', AppLanguage.english: 'Transaction Name'},
    'amount': {AppLanguage.arabic: 'المبلغ', AppLanguage.english: 'Amount'},
    'category': {AppLanguage.arabic: 'التصنيف', AppLanguage.english: 'Category'},
    'date': {AppLanguage.arabic: 'التاريخ', AppLanguage.english: 'Date'},
    'notes': {AppLanguage.arabic: 'ملاحظات', AppLanguage.english: 'Notes'},
    'save': {AppLanguage.arabic: 'حفظ', AppLanguage.english: 'Save'},
    'cancel': {AppLanguage.arabic: 'إلغاء', AppLanguage.english: 'Cancel'},
    'settings': {AppLanguage.arabic: 'الإعدادات', AppLanguage.english: 'Settings'},
    'budget_start_date': {AppLanguage.arabic: 'تاريخ بداية الميزانية', AppLanguage.english: 'Budget Start Date'},
    'export_backup': {AppLanguage.arabic: 'تصدير النسخة الاحتياطية', AppLanguage.english: 'Export Backup'},
    'import_backup': {AppLanguage.arabic: 'استيراد النسخة الاحتياطية', AppLanguage.english: 'Import Backup'},
    'backup_exported': {AppLanguage.arabic: 'تم تصدير النسخة الاحتياطية بنجاح', AppLanguage.english: 'Backup exported successfully'},
    'backup_imported': {AppLanguage.arabic: 'تم استيراد النسخة الاحتياطية بنجاح', AppLanguage.english: 'Backup imported successfully'},
    'choose_file': {AppLanguage.arabic: 'اختر الملف', AppLanguage.english: 'Choose File'},
    'error_export': {AppLanguage.arabic: 'حدث خطأ في التصدير', AppLanguage.english: 'Export error'},
    'error_import': {AppLanguage.arabic: 'حدث خطأ في الاستيراد', AppLanguage.english: 'Import error'},
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
    'budget': {AppLanguage.arabic: 'الميزانية الشهرية', AppLanguage.english: 'Monthly Budget'},
    'set_budget': {AppLanguage.arabic: 'تحديد الميزانية', AppLanguage.english: 'Set Budget'},
    'remaining': {AppLanguage.arabic: 'المتبقي', AppLanguage.english: 'Remaining'},
    'spent': {AppLanguage.arabic: 'المستهلك', AppLanguage.english: 'Spent'},
    'enter_budget_amount': {AppLanguage.arabic: 'أدخل قيمة الميزانية', AppLanguage.english: 'Enter budget amount'},
    'over_budget': {AppLanguage.arabic: 'تجاوزت الميزانية!', AppLanguage.english: 'Over budget!'},
    'month_progress': {AppLanguage.arabic: 'تقدم دورة الميزانية', AppLanguage.english: 'Budget Cycle Progress'},
    'days_remaining': {AppLanguage.arabic: 'يوم متبقي', AppLanguage.english: 'Days Remaining'},
    'days_passed': {AppLanguage.arabic: 'يوم مر', AppLanguage.english: 'Days Passed'},
  };

  String translate(String key) {
    return _strings[key]?[_currentLanguage] ?? key;
  }
}