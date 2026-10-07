import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../services/database_service.dart';
import '../services/localization_service.dart';
import 'add_transaction_screen.dart';
import 'transactions_list_screen.dart';

class HomeDashboard extends StatefulWidget {
  final LocalizationService localization;
  const HomeDashboard({super.key, required this.localization});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  double _monthlyTotal = 0;
  List<ExpenseTransaction> _recentTransactions = [];
  Map<TransactionCategory, double> _categoryTotals = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final now = DateTime.now();
    final monthly = await DatabaseService.instance.getMonthlyTransactions(now.month, now.year);

    double total = 0;
    Map<TransactionCategory, double> catTotals = {};
    for (var t in monthly) {
      total += t.amount;
      catTotals[t.category] = (catTotals[t.category] ?? 0) + t.amount;
    }

    final all = await DatabaseService.instance.getAllTransactions();

    if (!mounted) return;
    setState(() {
      _monthlyTotal = total;
      _categoryTotals = catTotals;
      _recentTransactions = all.take(5).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = widget.localization;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('app_title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => loc.toggleLanguage(),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primaryGreen,
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTotalCard(loc),
              _buildCategorySection(loc),
              _buildRecentSection(loc),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddTransactionScreen(localization: loc)),
          );
          _loadData();
        },
        label: Text(loc.translate('add_expense')),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTotalCard(LocalizationService loc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.translate('total_monthly'),
            style: GoogleFonts.rubik(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _monthlyTotal.toStringAsFixed(2),
                style: GoogleFonts.rubik(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                loc.translate('currency'),
                style: GoogleFonts.rubik(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(LocalizationService loc) {
    if (_categoryTotals.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            loc.translate('categories'),
            style: GoogleFonts.rubik(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: TransactionCategory.values.length,
            itemBuilder: (context, index) {
              final cat = TransactionCategory.values[index];
              final total = _categoryTotals[cat] ?? 0;
              if (total == 0) return const SizedBox.shrink();

              return Container(
                width: 110,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_getCategoryIcon(cat), color: const Color(0xFF2E7D32)),
                    const SizedBox(height: 8),
                    Text(
                      loc.translate(cat.name),
                      style: GoogleFonts.rubik(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      total.toStringAsFixed(0),
                      style: GoogleFonts.rubik(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentSection(LocalizationService loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                loc.translate('history'),
                style: GoogleFonts.rubik(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TransactionsListScreen(localization: loc)),
                  ).then((_) => _loadData());
                },
                child: Text(
                  loc.isArabic ? 'عرض الكل' : 'View All',
                  style: GoogleFonts.rubik(
                    color: const Color(0xFF2E7D32),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_recentTransactions.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Text(
                loc.translate('no_transactions'),
                style: GoogleFonts.rubik(color: Colors.grey[400]),
              ),
            ),
          )
        else
          ..._recentTransactions.map((t) => _buildTransactionTile(t, loc)),
      ],
    );
  }

  Widget _buildTransactionTile(ExpenseTransaction t, LocalizationService loc) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE8F5E9),
          child: Icon(_getCategoryIcon(t.category), color: const Color(0xFF2E7D32), size: 20),
        ),
        title: Text(t.title, style: GoogleFonts.rubik(fontWeight: FontWeight.w600)),
        subtitle: Text(
          DateFormat('yyyy/MM/dd').format(t.date),
          style: GoogleFonts.rubik(color: Colors.grey[600], fontSize: 12),
        ),
        trailing: Text(
          '${t.amount.toStringAsFixed(2)} ${loc.translate('currency')}',
          style: GoogleFonts.rubik(fontWeight: FontWeight.bold, color: const Color(0xFF2E7D32)),
        ),
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

class AppColors {
  static const Color primaryGreen = Color(0xFF2E7D32);
}
