enum TransactionCategory {
  food,
  transport,
  utilities,
  shopping,
  health,
  other,
}

class ExpenseTransaction {
  final int? id;
  final String title;
  final double amount;
  final TransactionCategory category;
  final DateTime date;
  final String notes;

  ExpenseTransaction({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category.name,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }

  factory ExpenseTransaction.fromMap(Map<String, dynamic> map) {
    return ExpenseTransaction(
      id: map['id'] as int?,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: TransactionCategory.values.firstWhere(
        (c) => c.name == map['category'],
        orElse: () => TransactionCategory.other,
      ),
      date: DateTime.parse(map['date'] as String),
      notes: (map['notes'] as String?) ?? '',
    );
  }

  ExpenseTransaction copyWith({
    int? id,
    String? title,
    double? amount,
    TransactionCategory? category,
    DateTime? date,
    String? notes,
  }) {
    return ExpenseTransaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }
}
