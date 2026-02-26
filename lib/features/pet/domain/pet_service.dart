import 'models/pet.dart';

/// Serviço de domínio para lógica do pet.
class PetService {
  PetService._();

  /// Calcula o humor do pet com base na saúde financeira (0.0 a 1.0).
  ///
  /// Mapeamento:
  /// - >= 0.8: happy
  /// - 0.5 a 0.8: neutral
  /// - 0.2 a 0.5: sad
  /// - < 0.2: sick
  static PetMood computeMoodFromFinancialHealth(double health) {
    assert(health >= 0 && health <= 1, 'financialHealth deve estar entre 0 e 1');
    final clamped = health.clamp(0.0, 1.0);

    if (clamped >= 0.8) return PetMood.happy;
    if (clamped >= 0.5) return PetMood.neutral;
    if (clamped >= 0.2) return PetMood.sad;
    return PetMood.sick;
  }

  /// Calcula a saúde financeira simplificada.
  ///
  /// Fórmula: progressoMeta * 0.6 + (1 - overspendRatio) * 0.4
  /// - progressoMeta: 0 a 1, quanto da meta mensal foi atingida
  /// - overspendRatio: 0 a 1, quanto gastou a mais em relação às receitas (1 = gastou tudo e mais)
  static double computeFinancialHealth({
    required double goalProgress,
    required double overspendRatio,
  }) {
    final progressComponent = goalProgress.clamp(0.0, 1.0) * 0.6;
    final spendComponent = (1 - overspendRatio.clamp(0.0, 1.0)) * 0.4;
    return (progressComponent + spendComponent).clamp(0.0, 1.0);
  }
}
