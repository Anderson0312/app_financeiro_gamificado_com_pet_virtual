import 'package:equatable/equatable.dart';

/// Modelo de meta de economia.
class Goal extends Equatable {
  const Goal({
    required this.id,
    required this.title,
    required this.targetAmount,
    this.currentAmount = 0,
    this.deadline,
    this.isMonthly = true,
  });

  final String id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime? deadline;
  final bool isMonthly;

  double get progress =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0;

  Goal copyWith({
    String? id,
    String? title,
    double? targetAmount,
    double? currentAmount,
    DateTime? deadline,
    bool? isMonthly,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
      isMonthly: isMonthly ?? this.isMonthly,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'targetAmount': targetAmount,
        'currentAmount': currentAmount,
        'deadline': deadline?.toIso8601String(),
        'isMonthly': isMonthly,
      };

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
        id: json['id'] as String,
        title: json['title'] as String,
        targetAmount: (json['targetAmount'] as num).toDouble(),
        currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0,
        deadline: json['deadline'] != null
            ? DateTime.parse(json['deadline'] as String)
            : null,
        isMonthly: json['isMonthly'] as bool? ?? true,
      );

  @override
  List<Object?> get props =>
      [id, title, targetAmount, currentAmount, deadline, isMonthly];
}
