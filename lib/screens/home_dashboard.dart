import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';
import '../services/database_service.dart';
import '../services/localization_service.dart';
import 'add_transaction_screen.dart';
import 'transactions_list_screen.dart';
import 'stats_screen.dart';

class HomeDashboard extends StatefulWidget {
  final LocalizationService localization;
  const HomeDashboard({super.key, required this.localization});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  double _monthlyTotal = 0;
  double _monthlyBudget = 50000.0; // Default budget in DZD
  List<ExpenseTransaction> _recentTransactions = [];
  Map<TransactionCategory, double> _categoryTotals = {};

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadBudget();
  }

  Future<void> _loadBudget() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _monthlyBudget = prefs.getDouble('monthly_budget') ?? 50000.0;
    });
  }

  Future<void> _saveBudget(double newBudget) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('monthly_budget', newBudget);
    setState(() {
      _monthlyBudget = newBudget;
    });
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

  void _showBudgetDialog(LocalizationService loc) {
    final controller = TextEditingController(text: _monthlyBudget.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.translate('set_budget'), style: GoogleFonts.rubik(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: GoogleFonts.rubik(),
          decoration: InputDecoration(
            labelText: loc.translate('budget'),
            suffixText: loc.translate('currency'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.translate('cancel'), style: GoogleFonts.rubik()),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text);
              if (val != null) {
                _saveBudget(val);
              }
              Navigator.pop(context);
            },
            child: Text(loc.translate('save'), style: GoogleFonts.rubik()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = widget.localization;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('app_title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.pie_chart),
            tooltip: loc.translate('stats'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => StatsScreen(localization: loc)),
              );
            },
          ),
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
              _buildBudgetCard(loc),
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
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

  Widget _buildBudgetCard(LocalizationService loc) {
    final progress = _monthlyBudget > 0 ? (_monthlyTotal / _monthlyBudget).clamp(0.0, 1.0) : 0.0;
    final isOver = _monthlyTotal > _monthlyBudget;

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                loc.translate('budget'),
                style: GoogleFonts.rubik(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: () => _showBudgetDialog(loc),
                icon: const Icon(Icons.edit, size: 16, color: Color(0xFF2E7D32)),
                label: Text(
                  '${_monthlyBudget.toStringAsFixed(0)} ${loc.translate('currency')}',
                  style: GoogleFonts.rubik(color: const Color(0xFF2E7D32), fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.grey[100],
              valueColor: AlwaysStoppedAnimation<Color>(
                isOver ? Colors.red : const Color(0xFF2E7D32),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${loc.translate('spent')}: ${_monthlyTotal.toStringAsFixed(0)}',
                style: GoogleFonts.rubik(color: Colors.grey[600], fontSize: 13),
              ),
              Text(
                isOver ? loc.translate('over_budget') : '${loc.translate('remaining')}: ${(_monthlyBudget - _monthlyTotal).toStringAsFixed(0)}',
                style: GoogleFonts.rubik(
                  color: isOver ? Colors.red : Colors.grey[600],
                  fontWeight: isOver ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
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
