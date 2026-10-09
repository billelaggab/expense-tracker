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
  TransactionCategory? _categoryFilter;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final all = await DatabaseService.instance.getAllTransactions();
    if (!mounted) return;
    setState(() => _transactions = all);
  }

  @override
  Widget build(BuildContext context) {
    final loc = widget.localization;
    final filtered = _transactions.where((t) {
      final matchesSearch = t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.notes.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _categoryFilter == null || t.category == _categoryFilter;
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('history'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: loc.translate('search'),
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: FilterChip(
                    label: Text(loc.translate('all')),
                    selected: _categoryFilter == null,
                    onSelected: (_) => setState(() => _categoryFilter = null),
                    selectedColor: const Color(0xFFE8F5E9),
                    checkmarkColor: const Color(0xFF2E7D32),
                  ),
                ),
                ...TransactionCategory.values.map((cat) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: FilterChip(
                    label: Text(loc.translate(cat.name)),
                    selected: _categoryFilter == cat,
                    onSelected: (selected) {
                      setState(() => _categoryFilter = selected ? cat : null);
                    },
                    selectedColor: const Color(0xFFE8F5E9),
                    checkmarkColor: const Color(0xFF2E7D32),
                  ),
                )),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      loc.translate('no_transactions'),
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final t = filtered[index];
                      return Dismissible(
                        key: Key(t.id.toString()),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) async {
                          await DatabaseService.instance.deleteTransaction(t.id!);
                          _loadData();
                        },
                        background: Container(
                          alignment: AlignmentDirectional.centerEnd,
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          padding: const EdgeInsetsDirectional.only(end: 24),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFFE8F5E9),
                              child: Icon(
                                _getCategoryIcon(t.category),
                                color: const Color(0xFF2E7D32),
                                size: 20,
                              ),
                            ),
                            title: Text(t.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text(
                              DateFormat('yyyy/MM/dd').format(t.date),
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                            trailing: Text(
                              '${t.amount.toStringAsFixed(2)} ${loc.translate('currency')}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
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

  IconData _getCategoryIcon(TransactionCategory cat) {
    switch (cat) {
      case TransactionCategory.food: return Icons.restaurant;
      case TransactionCategory.transport: return Icons.directions_car;
      case TransactionCategory.utilities: return Icons.receipt;
      case TransactionCategory.shopping: return Icons.shopping_bag;
      case TransactionCategory.health: return Icons.medical_services;
      case TransactionCategory.other: return Icons.more_horiz;
    }
  }
}
