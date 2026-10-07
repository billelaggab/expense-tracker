import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../services/database_service.dart';
import '../services/localization_service.dart';

class TransactionsListScreen extends StatefulWidget {
  final LocalizationService localization;
  const TransactionsListScreen({super.key, required this.localization});

  @override
  State<TransactionsListScreen> createState() => _TransactionsListScreenState();
}

class _TransactionsListScreenState extends State<TransactionsListScreen> {
  List<ExpenseTransaction> _transactions = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final all = await DatabaseService.instance.getAllTransactions();
    setState(() => _transactions = all);
  }

  @override
  Widget build(BuildContext context) {
    final loc = widget.localization;
    final filtered = _transactions.where((t) =>
      t.title.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();

    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('history'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: loc.translate('search'),
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final t = filtered[index];
                return Dismissible(
                  key: Key(t.id.toString()),
                  onDismissed: (_) async {
                    await DatabaseService.instance.deleteTransaction(t.id!);
                    _loadData();
                  },
                  background: Container(color: Colors.redAccent),
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ListTile(
                      title: Text(t.title),
                      subtitle: Text(DateFormat('yyyy/MM/dd').format(t.date)),
                      trailing: Text('${t.amount.toStringAsFixed(2)} ${loc.translate('currency')}'),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
