import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../services/database_service.dart';
import '../services/localization_service.dart';

class AddTransactionScreen extends StatefulWidget {
  final LocalizationService localization;
  const AddTransactionScreen({super.key, required this.localization});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  TransactionCategory _selectedCategory = TransactionCategory.food;
  DateTime _selectedDate = DateTime.now();

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final newTransaction = ExpenseTransaction(
      title: _titleController.text,
      amount: double.parse(_amountController.text),
      category: _selectedCategory,
      date: _selectedDate,
      notes: _notesController.text,
    );

    await DatabaseService.instance.insertTransaction(newTransaction);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final loc = widget.localization;
    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('add_expense'))),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // 1. Amount
            TextFormField(
              controller: _amountController,
              autofocus: true,
              textInputAction: TextInputAction.next,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: loc.translate('amount'),
                suffixText: loc.translate('currency'),
                prefixIcon: const Icon(Icons.attach_money),
              ),
              validator: (v) => double.tryParse(v ?? '') == null ? (loc.isArabic ? 'مبلغ غير صحيح' : 'Invalid amount') : null,
            ),
            const SizedBox(height: 16),
            // 2. Date
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: ListTile(
                leading: const Icon(Icons.calendar_today, color: Color(0xFF2E7D32)),
                title: Text(
                  "${loc.translate('date')}: ${DateFormat('yyyy/MM/dd').format(_selectedDate)}",
                ),
                trailing: const Icon(Icons.arrow_drop_down),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) setState(() => _selectedDate = date);
                },
              ),
            ),
            const SizedBox(height: 16),
            // 3. Transaction Name (Title)
            TextFormField(
              controller: _titleController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: loc.translate('title'),
                prefixIcon: const Icon(Icons.edit_note),
              ),
              validator: (v) => v!.isEmpty ? (loc.isArabic ? 'مطلوب' : 'Required') : null,
            ),
            const SizedBox(height: 16),
            // 4. Category
            DropdownButtonFormField<TransactionCategory>(
              initialValue: _selectedCategory,
              decoration: InputDecoration(
                labelText: loc.translate('category'),
                prefixIcon: const Icon(Icons.category),
              ),
              items: TransactionCategory.values.map((cat) => DropdownMenuItem(
                value: cat,
                child: Text(loc.translate(cat.name)),
              )).toList(),
              onChanged: (v) => setState(() => _selectedCategory = v!),
            ),
            const SizedBox(height: 16),
            // 5. Notes
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: loc.translate('notes'),
                prefixIcon: const Icon(Icons.notes),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _save,
              child: Text(loc.translate('save'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
