/// Funções auxiliares para cálculos de consumo e custo.
class Calculations {
  Calculations();

  /// Calcula o valor total do abastecimento.
  /// Valor total = preço por litro × quantidade de litros.
  static double calculateTotalValue(double pricePerLiter, double liters) {
    return pricePerLiter * liters;
  }

  /// Calcula a distância percorrida entre dois abastecimentos.
  /// Distância = quilometragem atual - quilometragem anterior.
  static double calculateDistance(double currentKm, double previousKm) {
    return currentKm - previousKm;
  }

  /// Calcula o consumo em km/L.
  /// Consumo = distância percorrida / litros do abastecimento atual.
  static double? calculateConsumption(double distance, double liters) {
    if (distance <= 0 || liters <= 0) return null;
    return distance / liters;
  }

  /// Calcula o custo por quilômetro em R$/km.
  /// Custo/km = valor total do abastecimento / distância percorrida.
  static double? calculateCostPerKm(double totalValue, double distance) {
    if (distance <= 0) return null;
    return totalValue / distance;
  }
}
