import 'package:conveo/database/database_helper.dart';
import 'package:conveo/models/vehicle.dart';
import 'package:conveo/repositories/fueling_repository.dart';

/// Repositório para operações CRUD do veículo.
/// Abstrai o acesso ao banco de dados para a camada de negócio.
class VehicleRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final FuelingRepository _fuelingRepository = FuelingRepository();

  /// Retorna o veículo cadastrado (apenas um por vez).
  Future<Vehicle?> getVehicle() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('vehicles');
    if (maps.isEmpty) return null;
    return Vehicle.fromMap(maps.first);
  }

  /// Salva ou atualiza o veículo.
  /// Como só existe um veículo por vez, insere se não existe, ou atualiza se já existe.
  Future<Vehicle> saveVehicle(Vehicle vehicle) async {
    final db = await _dbHelper.database;

    final existing = await getVehicle();
    if (existing == null) {
      // Primeiro cadastro
      final id = await db.insert('vehicles', vehicle.toMap());
      return Vehicle(
        id: id,
        brand: vehicle.brand,
        model: vehicle.model,
        year: vehicle.year,
        engineCapacity: vehicle.engineCapacity,
      );
    } else {
      // Atualização do veículo existente
      final map = vehicle.toMap()..['id'] = existing.id;
      await db.update('vehicles', map, where: 'id = ?', whereArgs: [existing.id]);
      return Vehicle(
        id: existing.id,
        brand: vehicle.brand,
        model: vehicle.model,
        year: vehicle.year,
        engineCapacity: vehicle.engineCapacity,
      );
    }
  }

  /// Exclui o veículo cadastrado e todos os abastecimentos associados.
  /// Deleta explicitamente os abastecimentos antes do veículo para garantir a limpeza,
  /// já que as foreign keys do SQLite podem não estar habilitadas em todas as conexões.
  Future<void> deleteVehicle() async {
    final db = await _dbHelper.database;
    
    // Primeiro, obtém todos os veículos para deletar os abastecimentos associados
    final List<Map<String, dynamic>> vehicles = await db.query('vehicles');
    for (final vehicle in vehicles) {
      final vehicleId = vehicle['id'] as int;
      await _fuelingRepository.deleteFuelingsByVehicleId(vehicleId);
    }
    
    // Depois, deleta os veículos
    await db.delete('vehicles');
  }
}
