import 'package:equatable/equatable.dart';

/// Tipo de transação financeira.
enum TransactionType { income, expense }

/// Modelo de transação (receita ou despesa).
class Transaction extends Equatable {
  const Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.category,
    this.description,
    required this.date,
  });

  final String id;
  final double amount;
  final TransactionType type;
  final String category;
  final String? description;
  final DateTime date;

  Transaction copyWith({
    String? id,
    double? amount,
    TransactionType? type,
    String? category,
    String? description,
    DateTime? date,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      description: description ?? this.description,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'type': type.name,
        'category': category,
        'description': description,
        'date': date.toIso8601String(),
      };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'] as String,
        amount: (json['amount'] as num).toDouble(),
        type: TransactionType.values.byName(json['type'] as String),
        category: json['category'] as String,
        description: json['description'] as String?,
        date: DateTime.parse(json['date'] as String),
      );

  @override
  List<Object?> get props => [id, amount, type, category, description, date];
}
