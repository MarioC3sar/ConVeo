import 'package:conveo/database/database_helper.dart';
import 'package:conveo/models/fueling.dart';

/// Repositório para operações CRUD dos abastecimentos.
/// Abstrai o acesso ao banco de dados para a camada de negócio.
class FuelingRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Retorna todos os abastecimentos de um veículo, ordenados por data.
  Future<List<Fueling>> getFuelings(int vehicleId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'fuelings',
      where: 'vehicle_id = ?',
      whereArgs: [vehicleId],
      orderBy: 'date ASC',
    );
    return List.generate(maps.length, (i) => Fueling.fromMap(maps[i]));
  }

  /// Insere um novo abastecimento.
  Future<Fueling> insertFueling(Fueling fueling) async {
    final db = await _dbHelper.database;
    final id = await db.insert('fuelings', fueling.toMap());
    return Fueling(
      id: id,
      vehicleId: fueling.vehicleId,
      fuelType: fueling.fuelType,
      pricePerLiter: fueling.pricePerLiter,
      kilometers: fueling.kilometers,
      liters: fueling.liters,
      date: fueling.date,
      totalValue: fueling.totalValue,
    );
  }

  /// Exclui um abastecimento pelo ID.
  Future<void> deleteFueling(int id) async {
    final db = await _dbHelper.database;
    await db.delete('fuelings', where: 'id = ?', whereArgs: [id]);
  }

  /// Exclui todos os abastecimentos de um veículo.
  Future<void> deleteFuelingsByVehicleId(int vehicleId) async {
    final db = await _dbHelper.database;
    await db.delete('fuelings', where: 'vehicle_id = ?', whereArgs: [vehicleId]);
  }

  /// Retorna o último abastecimento de um veículo (por quilometragem).
  Future<Fueling?> getLastFueling(int vehicleId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'fuelings',
      where: 'vehicle_id = ?',
      whereArgs: [vehicleId],
      orderBy: 'kilometers DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Fueling.fromMap(maps.first);
  }
}
