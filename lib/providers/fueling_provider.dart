import 'package:flutter/material.dart';
import 'package:conveo/models/fueling.dart';
import 'package:conveo/repositories/fueling_repository.dart';
import 'package:conveo/utils/calculations.dart';

/// Provider que gerencia o estado dos abastecimentos.
/// Calcula indicadores de consumo e custo para o dashboard.
class FuelingProvider extends ChangeNotifier {
  final FuelingRepository _repository = FuelingRepository();

  List<Fueling> _fuelings = [];
  bool _isLoading = false;
  String? _error;

  List<Fueling> get fuelings => _fuelings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasFuelings => _fuelings.isNotEmpty;

  /// Carrega todos os abastecimentos de um veículo e calcula indicadores.
  Future<void> loadFuelings(int vehicleId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final fuelings = await _repository.getFuelings(vehicleId);
      _fuelings = _calculateIndicators(fuelings);
    } catch (e) {
      _error = 'Erro ao carregar abastecimentos: $e';
      _fuelings = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adiciona um novo abastecimento.
  Future<bool> addFueling(Fueling fueling) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.insertFueling(fueling);
      // Recarrega a lista com os cálculos atualizados
      await loadFuelings(fueling.vehicleId);
      return true;
    } catch (e) {
      _error = 'Erro ao salvar abastecimento: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Exclui um abastecimento.
  Future<bool> deleteFueling(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteFueling(id);
      // Recarrega a lista
      if (_fuelings.isNotEmpty) {
        final vehicleId = _fuelings.first.vehicleId;
        await loadFuelings(vehicleId);
      }
      return true;
    } catch (e) {
      _error = 'Erro ao excluir abastecimento: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Retorna o último abastecimento para validar quilometragem.
  Future<Fueling?> getLastFueling(int vehicleId) async {
    return await _repository.getLastFueling(vehicleId);
  }

  /// Calcula os indicadores (distância, consumo, custo/km) para cada abastecimento.
  List<Fueling> _calculateIndicators(List<Fueling> fuelings) {
    if (fuelings.isEmpty) return [];

    final result = <Fueling>[];

    for (int i = 0; i < fuelings.length; i++) {
      final fueling = fuelings[i];

      // O primeiro abastecimento é apenas referência
      if (i == 0) {
        result.add(fueling);
        continue;
      }

      final previous = fuelings[i - 1];
      final distance = Calculations.calculateDistance(fueling.kilometers, previous.kilometers);

      if (distance > 0) {
        final consumption = Calculations.calculateConsumption(distance, fueling.liters);
        final costPerKm = Calculations.calculateCostPerKm(fueling.totalValue, distance);

        result.add(fueling.copyWith(
          distance: distance,
          consumption: consumption,
          costPerKm: costPerKm,
        ));
      } else {
        // Quilometragem inválida — mantém sem indicadores
        result.add(fueling);
      }
    }

    return result;
  }

  /// Limpa o erro atual.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
