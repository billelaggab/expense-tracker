import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/transaction.dart';
import '../services/database_service.dart';
import '../services/localization_service.dart';

class StatsScreen extends StatefulWidget {
  final LocalizationService localization;
  const StatsScreen({super.key, required this.localization});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  Map<TransactionCategory, double> _categoryTotals = {};
  double _totalSpent = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final now = DateTime.now();
    final monthly = await DatabaseService.instance.getMonthlyTransactions(now.month, now.year);

    double total = 0;
    Map<TransactionCategory, double> catTotals = {};
    for (var t in monthly) {
      total += t.amount;
      catTotals[t.category] = (catTotals[t.category] ?? 0) + t.amount;
    }

    if (!mounted) return;
    setState(() {
      _totalSpent = total;
      _categoryTotals = catTotals;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = widget.localization;
    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('stats'))),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
          : _categoryTotals.isEmpty
              ? Center(
                  child: Text(
                    loc.translate('no_transactions'),
                    style: GoogleFonts.rubik(color: Colors.grey[400]),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        loc.translate('total_monthly'),
                        style: GoogleFonts.rubik(color: Colors.grey[600], fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_totalSpent.toStringAsFixed(2)} ${loc.translate('currency')}',
                        style: GoogleFonts.rubik(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        height: 220,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 4,
                            centerSpaceRadius: 50,
                            sections: _getSections(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: _categoryTotals.entries.map((entry) {
                            final percentage = (_totalSpent > 0) ? (entry.value / _totalSpent) * 100 : 0.0;
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.grey[200]!),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: _getCategoryColor(entry.key).withValues(alpha: 0.15),
                                  child: Icon(_getCategoryIcon(entry.key), color: _getCategoryColor(entry.key)),
                                ),
                                title: Text(loc.translate(entry.key.name), style: GoogleFonts.rubik(fontWeight: FontWeight.w600)),
                                subtitle: Text('${percentage.toStringAsFixed(1)}%'),
                                trailing: Text(
                                  '${entry.value.toStringAsFixed(2)} ${loc.translate('currency')}',
                                  style: GoogleFonts.rubik(fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
    );
  }

  List<PieChartSectionData> _getSections() {
    return _categoryTotals.entries.map((entry) {
      final percentage = (_totalSpent > 0) ? (entry.value / _totalSpent) * 100 : 0.0;
      return PieChartSectionData(
        color: _getCategoryColor(entry.key),
        value: entry.value,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 60,
        titleStyle: GoogleFonts.rubik(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Color _getCategoryColor(TransactionCategory cat) {
    switch (cat) {
      case TransactionCategory.food: return Colors.orange;
      case TransactionCategory.transport: return Colors.blue;
      case TransactionCategory.utilities: return Colors.red;
      case TransactionCategory.shopping: return Colors.purple;
      case TransactionCategory.health: return Colors.teal;
      case TransactionCategory.other: return Colors.blueGrey;
    }
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
