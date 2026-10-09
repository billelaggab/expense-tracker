import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'database_service.dart';
import '../models/transaction.dart';

class BackupService {
  static final BackupService instance = BackupService._init();

  BackupService._init();

  /// Export all transactions to a JSON file and share it
  Future<String> exportBackup() async {
    try {
      final transactions = await DatabaseService.instance.getAllTransactions();
      final data = transactions.map((t) => t.toMap()).toList();

      final jsonContent = jsonEncode(data);

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/expense_backup_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(jsonContent);

      // Share the file using the modern SharePlus API
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: 'Expense Tracker Backup',
        ),
      );

      return file.path;
    } catch (e) {
      throw Exception('Export failed: $e');
    }
  }

  /// Import transactions from a JSON file
  Future<int> importBackup() async {
    try {
      final selectedFiles = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (selectedFiles.isEmpty) return 0;

      final file = File(selectedFiles.first.path!);
      final content = await file.readAsString();
      final List<dynamic> decoded = jsonDecode(content);

      int importedCount = 0;
      for (final item in decoded) {
        if (item is Map<String, dynamic>) {
          final transaction = ExpenseTransaction.fromMap(item);
          await DatabaseService.instance.insertTransaction(transaction);
          importedCount++;
        }
      }

      return importedCount;
    } catch (e) {
      throw Exception('Import failed: $e');
    }
  }
}