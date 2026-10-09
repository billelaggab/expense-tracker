import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/backup_service.dart';
import '../services/localization_service.dart';

class SettingsScreen extends StatefulWidget {
  final LocalizationService localization;
  const SettingsScreen({super.key, required this.localization});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  DateTime _budgetStartDate = DateTime.now();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBudgetStartDate();
  }

  Future<void> _loadBudgetStartDate() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt('budget_start_date');
    if (timestamp != null) {
      _budgetStartDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveBudgetStartDate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('budget_start_date', _budgetStartDate.millisecondsSinceEpoch);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved')),
      );
    }
  }

  Future<void> _selectBudgetStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _budgetStartDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() => _budgetStartDate = date);
      await _saveBudgetStartDate();
    }
  }

  Future<void> _exportBackup() async {
    try {
      await BackupService.instance.exportBackup();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.localization.translate('backup_exported'))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.localization.translate('error_export'))),
        );
      }
    }
  }

  Future<void> _importBackup() async {
    try {
      final count = await BackupService.instance.importBackup();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(
            widget.localization.isArabic
                ? 'تم استيراد $count معاملات بنجاح'
                : 'Imported $count transactions successfully',
          )),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.localization.translate('error_import'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = widget.localization;

    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('settings'))),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Budget Start Date
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.calendar_month, color: Color(0xFF2E7D32)),
                    title: Text(loc.translate('budget_start_date')),
                    subtitle: Text(DateFormat('yyyy/MM/dd').format(_budgetStartDate)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _selectBudgetStartDate,
                  ),
                ),
                const SizedBox(height: 12),
                // Export Backup
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.file_download, color: Color(0xFF2E7D32)),
                    title: Text(loc.translate('export_backup')),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _exportBackup,
                  ),
                ),
                const SizedBox(height: 12),
                // Import Backup
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.file_upload, color: Color(0xFF2E7D32)),
                    title: Text(loc.translate('import_backup')),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _importBackup,
                  ),
                ),
              ],
            ),
    );
  }
}