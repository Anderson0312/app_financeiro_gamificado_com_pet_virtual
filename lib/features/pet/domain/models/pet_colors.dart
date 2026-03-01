import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

/// Modelo para armazenar as cores personalizadas de cada pet.
class PetColors extends Equatable {
  const PetColors({
    required this.primaryColor,
    required this.secondaryColor,
    required this.outlineColor,
  });

  final Color primaryColor;
  final Color secondaryColor;
  final Color outlineColor;

  /// Cores padrão do gato (laranja vibrante).
  static const PetColors defaultCat = PetColors(
    primaryColor: Color(0xFFFFAB00),
    secondaryColor: Color(0xFFFFE599),
    outlineColor: Color(0xFFD68F00),
  );

  /// Cores padrão do cachorro (marrom caramelo).
  static const PetColors defaultDog = PetColors(
    primaryColor: Color(0xFFD48F3B),
    secondaryColor: Color(0xFFFFCB80),
    outlineColor: Color(0xFF8F572A),
  );

  /// Cores padrão do dragão (verde vibrante).
  static const PetColors defaultDragon = PetColors(
    primaryColor: Color(0xFF4CAF50),
    secondaryColor: Color(0xFFC6FF00),
    outlineColor: Color(0xFF2E7D32),
  );

  /// Cores padrão da capivara (marrom).
  static const PetColors defaultCapybara = PetColors(
    primaryColor: Color(0xFF8D6E63),
    secondaryColor: Color(0xFFA1887F),
    outlineColor: Color(0xFF5D4037),
  );

  PetColors copyWith({
    Color? primaryColor,
    Color? secondaryColor,
    Color? outlineColor,
  }) {
    return PetColors(
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      outlineColor: outlineColor ?? this.outlineColor,
    );
  }

  Map<String, dynamic> toJson() => {
        'primaryColor': primaryColor.value,
        'secondaryColor': secondaryColor.value,
        'outlineColor': outlineColor.value,
      };

  factory PetColors.fromJson(Map<String, dynamic> json) => PetColors(
        primaryColor: Color(json['primaryColor'] as int),
        secondaryColor: Color(json['secondaryColor'] as int),
        outlineColor: Color(json['outlineColor'] as int),
      );

  @override
  List<Object?> get props => [primaryColor, secondaryColor, outlineColor];
}
