import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:conveo/models/fueling.dart';
import 'package:conveo/providers/vehicle_provider.dart';
import 'package:conveo/providers/fueling_provider.dart';
import 'package:conveo/utils/constants.dart';
import 'package:conveo/utils/calculations.dart';
import 'package:conveo/utils/validators.dart';

/// Tela de registro de abastecimento.
/// Permite cadastrar um novo abastecimento com validações.
class FuelingScreen extends StatefulWidget {
  const FuelingScreen({super.key});

  @override
  State<FuelingScreen> createState() => _FuelingScreenState();
}

class _FuelingScreenState extends State<FuelingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _kilometersController = TextEditingController();
  final _litersController = TextEditingController();

  String? _selectedFuelType;
  double? _lastKilometers;
  int? _lastVehicleId;
  int _loadToken = 0;

  @override
  void initState() {
    super.initState();
    _selectedFuelType = Constants.fuelTypes.first;
    _loadLastKilometers();
    // Adiciona um listener no VehicleProvider para recarregar a quilometragem
    // quando o veículo é excluído/criado enquanto a tela está em memória (IndexedStack).
    context.read<VehicleProvider>().addListener(_onVehicleChanged);
  }

  /// Callback chamado quando o VehicleProvider notifica mudanças.
  /// Recarrega a quilometragem sempre que o veículo muda.
  void _onVehicleChanged() {
    if (mounted) {
      _loadLastKilometers();
    }
  }

  @override
  void dispose() {
    // Remove o listener para evitar memory leaks
    context.read<VehicleProvider>().removeListener(_onVehicleChanged);
    _priceController.dispose();
    _kilometersController.dispose();
    _litersController.dispose();
    super.dispose();
  }

  /// Carrega a quilometragem do último abastecimento para validação.
  /// Usa um token para evitar race conditions: se uma nova chamada for feita
  /// antes de uma anterior completar, o resultado antigo é descartado.
  Future<void> _loadLastKilometers() async {
    // Incrementa o token para marcar esta chamada como a mais recente
    final token = ++_loadToken;

    final vehicleProvider = context.read<VehicleProvider>();
    final fuelingProvider = context.read<FuelingProvider>();

    if (!vehicleProvider.hasVehicle) {
      // Sem veículo cadastrado, reseta os valores
      // Verifica se esta chamada ainda é a mais recente
      if (token == _loadToken && mounted) {
        setState(() {
          _lastVehicleId = null;
          _lastKilometers = null;
        });
      }
      return;
    }

    final currentVehicleId = vehicleProvider.vehicle!.id!;

    // Se o veículo mudou, reseta imediatamente a quilometragem
    if (_lastVehicleId != currentVehicleId) {
      if (mounted) {
        setState(() {
          _lastVehicleId = currentVehicleId;
          _lastKilometers = null;
        });
      }
    }

    // Busca o último abastecimento do veículo atual
    final last = await fuelingProvider.getLastFueling(currentVehicleId);

    // Só atualiza se esta chamada ainda é a mais recente (nenhuma nova chamada foi feita)
    if (token == _loadToken && mounted) {
      setState(() {
        _lastKilometers = last?.kilometers;
      });
    }
  }

  /// Salva o abastecimento.
  Future<void> _saveFueling() async {
    if (!_formKey.currentState!.validate()) return;

    final vehicleProvider = context.read<VehicleProvider>();
    if (!vehicleProvider.hasVehicle) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastre um veículo antes de registrar abastecimentos.')),
      );
      return;
    }

    final price = double.parse(_priceController.text);
    final kilometers = double.parse(_kilometersController.text);
    final liters = double.parse(_litersController.text);
    final totalValue = Calculations.calculateTotalValue(price, liters);

    final fueling = Fueling(
      vehicleId: vehicleProvider.vehicle!.id!,
      fuelType: _selectedFuelType!,
      pricePerLiter: price,
      kilometers: kilometers,
      liters: liters,
      date: DateTime.now(),
      totalValue: totalValue,
    );

    final fuelingProvider = context.read<FuelingProvider>();
    final success = await fuelingProvider.addFueling(fueling);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Abastecimento registrado com sucesso!')),
        );
        _priceController.clear();
        _kilometersController.clear();
        _litersController.clear();
        // Atualiza a quilometragem mínima
        setState(() {
          _lastKilometers = kilometers;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(fuelingProvider.error ?? 'Erro ao salvar abastecimento.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicleProvider = context.read<VehicleProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Abastecimento')),
      body: _buildBody(vehicleProvider),
    );
  }

  Widget _buildBody(VehicleProvider vehicleProvider) {
    if (!vehicleProvider.hasVehicle) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.car_rental, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Nenhum veículo cadastrado.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cadastre um veículo antes de registrar abastecimentos.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            // Tipo de combustível
            const Text('Tipo de combustível', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedFuelType,
              items: Constants.fuelTypes
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.capitalize()),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedFuelType = value;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Preço por litro
            const Text('Preço por litro (R\$)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: Validators.validatePricePerLiter,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Ex: 5.49',
                prefixText: 'R\$ ',
              ),
            ),
            const SizedBox(height: 16),

            // Quilometragem
            const Text('Quilometragem atual', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _kilometersController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (_lastKilometers != null) {
                  return Validators.validateKilometersGreaterThan(value, _lastKilometers!);
                }
                return Validators.validateKilometers(value);
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Ex: 50000',
                suffixText: ' km',
              ),
            ),
            if (_lastKilometers != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Última quilometragem: ${_lastKilometers!.toStringAsFixed(1)} km',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            const SizedBox(height: 16),

            // Litros
            const Text('Quantidade de litros', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _litersController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: Validators.validateLiters,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Ex: 45.5',
                suffixText: ' L',
              ),
            ),
            const SizedBox(height: 24),

            // Botão salvar
            ElevatedButton(
              onPressed: _saveFueling,
              child: const Text('Registrar Abastecimento'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Extensão para capitalizar a primeira letra.
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
