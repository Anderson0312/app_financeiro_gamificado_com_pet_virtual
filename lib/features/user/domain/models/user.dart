import 'package:equatable/equatable.dart';

/// Modelo do usuário do aplicativo.
class User extends Equatable {
  const User({
    required this.id,
    this.displayName,
    this.totalXp = 0,
    this.virtualCoins = 0,
    required this.createdAt,
  });

  final String id;
  final String? displayName;
  final int totalXp;
  final int virtualCoins;
  final DateTime createdAt;

  User copyWith({
    String? id,
    String? displayName,
    int? totalXp,
    int? virtualCoins,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      totalXp: totalXp ?? this.totalXp,
      virtualCoins: virtualCoins ?? this.virtualCoins,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'totalXp': totalXp,
        'virtualCoins': virtualCoins,
        'createdAt': createdAt.toIso8601String(),
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        displayName: json['displayName'] as String?,
        totalXp: (json['totalXp'] as num?)?.toInt() ?? 0,
        virtualCoins: (json['virtualCoins'] as num?)?.toInt() ?? 0,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  @override
  List<Object?> get props => [id, displayName, totalXp, virtualCoins, createdAt];
}
