import 'package:flutter/material.dart';
import 'package:conveo/models/vehicle.dart';
import 'package:conveo/repositories/vehicle_repository.dart';

/// Provider que gerencia o estado do veículo.
/// Usa ChangeNotifier para notificar as telas quando os dados mudam.
class VehicleProvider extends ChangeNotifier {
  final VehicleRepository _repository = VehicleRepository();

  Vehicle? _vehicle;
  bool _isLoading = false;
  String? _error;

  Vehicle? get vehicle => _vehicle;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasVehicle => _vehicle != null;

  /// Carrega o veículo do banco de dados.
  Future<void> loadVehicle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _vehicle = await _repository.getVehicle();
    } catch (e) {
      _error = 'Erro ao carregar veículo: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Salva ou atualiza o veículo.
  Future<bool> saveVehicle(Vehicle vehicle) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _vehicle = await _repository.saveVehicle(vehicle);
      _error = null;
      return true;
    } catch (e) {
      _error = 'Erro ao salvar veículo: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Exclui o veículo cadastrado.
  Future<bool> deleteVehicle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteVehicle();
      _vehicle = null;
      _error = null;
      return true;
    } catch (e) {
      _error = 'Erro ao excluir veículo: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Limpa o erro atual.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
