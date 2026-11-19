/// Modelo que representa um registro de abastecimento.
class Fueling {
  int? id; // Primary key (auto-increment)
  int vehicleId; // Foreign key → Vehicle.id
  String fuelType; // Tipo: "etanol", "gasolina", "diesel"
  double pricePerLiter; // Preço por litro (R$)
  double kilometers; // Quilometragem atual do veículo
  double liters; // Quantidade de litros abastecidos
  DateTime date; // Data e horário do abastecimento
  double totalValue; // Calculado: pricePerLiter × liters

  // Campos calculados pelo dashboard (opcionais)
  double? distance; // Distância percorrida desde o abastecimento anterior
  double? consumption; // Consumo em km/L
  double? costPerKm; // Custo por quilômetro em R$/km

  Fueling({
    this.id,
    required this.vehicleId,
    required this.fuelType,
    required this.pricePerLiter,
    required this.kilometers,
    required this.liters,
    required this.date,
    required this.totalValue,
    this.distance,
    this.consumption,
    this.costPerKm,
  });

  /// Converte o abastecimento em um Map para inserção no SQLite.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'fuel_type': fuelType,
      'price_per_liter': pricePerLiter,
      'kilometers': kilometers,
      'liters': liters,
      'date': date.toIso8601String(),
      'total_value': totalValue,
    };
  }

  /// Cria um Fueling a partir de um Map retornado pelo SQLite.
  factory Fueling.fromMap(Map<String, dynamic> map) {
    return Fueling(
      id: map['id'] as int?,
      vehicleId: map['vehicle_id'] as int,
      fuelType: map['fuel_type'] as String,
      pricePerLiter: (map['price_per_liter'] as num).toDouble(),
      kilometers: (map['kilometers'] as num).toDouble(),
      liters: (map['liters'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      totalValue: (map['total_value'] as num).toDouble(),
    );
  }

  /// Cria uma cópia do abastecimento com campos calculados atualizados.
  Fueling copyWith({
    double? distance,
    double? consumption,
    double? costPerKm,
  }) {
    return Fueling(
      id: id,
      vehicleId: vehicleId,
      fuelType: fuelType,
      pricePerLiter: pricePerLiter,
      kilometers: kilometers,
      liters: liters,
      date: date,
      totalValue: totalValue,
      distance: distance ?? this.distance,
      consumption: consumption ?? this.consumption,
      costPerKm: costPerKm ?? this.costPerKm,
    );
  }
}
