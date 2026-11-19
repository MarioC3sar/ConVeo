/// Modelo que representa o veículo cadastrado pelo usuário.
class Vehicle {
  int? id; // Primary key (auto-increment no banco)
  String brand; // Marca do veículo (ex: "FIAT")
  String model; // Modelo do veículo (ex: "UNO")
  int year; // Ano do veículo (ex: 2020)
  double engineCapacity; // Cilindrada do motor (ex: 1.0)

  Vehicle({
    this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.engineCapacity,
  });

  /// Converte o veículo em um Map para inserção/atualização no SQLite.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'year': year,
      'engine_capacity': engineCapacity,
    };
  }

  /// Cria um Vehicle a partir de um Map retornado pelo SQLite.
  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'] as int?,
      brand: map['brand'] as String,
      model: map['model'] as String,
      year: map['year'] as int,
      engineCapacity: (map['engine_capacity'] as num).toDouble(),
    );
  }

  @override
  String toString() {
    return '$year $brand $model';
  }
}
