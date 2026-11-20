import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:conveo/models/vehicle.dart';
import 'package:conveo/providers/vehicle_provider.dart';
import 'package:conveo/providers/fueling_provider.dart';
import 'package:conveo/services/fipe_service.dart';
import 'package:conveo/utils/validators.dart';

/// Tela de cadastro e visualização do veículo.
/// Permite selecionar marca e modelo via BrasilAPI e cadastrar o veículo.
class VehicleScreen extends StatefulWidget {
  const VehicleScreen({super.key});

  @override
  State<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _engineCapacityController = TextEditingController();

  final FipeService _fipeService = FipeService();

  // Seleção de marca
  List<FipeBrand> _brands = [];
  FipeBrand? _selectedBrand;
  bool _loadingBrands = false;

  // Seleção de modelo
  List<FipeModel> _models = [];
  FipeModel? _selectedModel;
  bool _loadingModels = false;

  // Ano do veículo
  String? _selectedYear;
  List<String> _years = [];

  // Erros da API
  String? _apiError;

  @override
  void initState() {
    super.initState();
    _loadYears();
    _loadBrands();
    _loadExistingVehicle();
  }

  @override
  void dispose() {
    _engineCapacityController.dispose();
    super.dispose();
  }

  /// Gera lista de anos do ano atual até 1886.
  void _loadYears() {
    final currentYear = DateTime.now().year + 1;
    _years = List.generate(currentYear - 1886 + 1, (i) => (currentYear - i).toString());
  }

  /// Carrega as marcas da BrasilAPI.
  Future<void> _loadBrands() async {
    setState(() {
      _loadingBrands = true;
      _apiError = null;
    });

    try {
      final brands = await _fipeService.getBrands();
      setState(() {
        _brands = brands;
        _apiError = null;
      });
    } catch (e) {
      setState(() {
        _apiError = 'Erro ao carregar marcas. Verifique sua conexão.';
      });
    } finally {
      setState(() {
        _loadingBrands = false;
      });
    }
  }

  /// Carrega os modelos da marca selecionada.
  Future<void> _loadModels(String brandCode) async {
    setState(() {
      _loadingModels = true;
      _apiError = null;
    });

    try {
      final models = await _fipeService.getModels(brandCode);
      setState(() {
        _models = models;
        _selectedModel = null;
        _apiError = null;
      });
    } catch (e) {
      setState(() {
        _apiError = 'Erro ao carregar modelos. Verifique sua conexão.';
      });
    } finally {
      setState(() {
        _loadingModels = false;
      });
    }
  }

  /// Carrega o veículo já cadastrado, se existir.
  Future<void> _loadExistingVehicle() async {
    final provider = context.read<VehicleProvider>();
    await provider.loadVehicle();

    if (provider.hasVehicle && mounted) {
      final vehicle = provider.vehicle!;
      setState(() {
        // Tenta encontrar a marca correspondente
        _selectedBrand = _brands.firstWhere(
          (b) => b.name.toUpperCase() == vehicle.brand.toUpperCase(),
          orElse: () => FipeBrand(code: '', name: vehicle.brand),
        );
        _selectedModel = FipeModel(code: '', name: vehicle.model);
        _selectedYear = vehicle.year.toString();
        _engineCapacityController.text = vehicle.engineCapacity.toString();
      });
    }
  }

  /// Salva o veículo.
  Future<void> _saveVehicle() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBrand == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma marca.')),
      );
      return;
    }
    if (_selectedModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um modelo.')),
      );
      return;
    }
    if (_selectedYear == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione o ano.')),
      );
      return;
    }

    final vehicle = Vehicle(
      brand: _selectedBrand!.name,
      model: _selectedModel!.name,
      year: int.parse(_selectedYear!),
      engineCapacity: double.parse(_engineCapacityController.text),
    );

    final provider = context.read<VehicleProvider>();
    final success = await provider.saveVehicle(vehicle);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veículo salvo com sucesso!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error ?? 'Erro ao salvar veículo.')),
        );
      }
    }
  }

  /// Exclui o veículo com confirmação.
  Future<void> _deleteVehicle() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir veículo'),
        content: const Text(
          'Tem certeza que deseja excluir o veículo? Todos os abastecimentos também serão removidos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final vehicleProvider = context.read<VehicleProvider>();
      final fuelingProvider = context.read<FuelingProvider>();
      final success = await vehicleProvider.deleteVehicle();

      if (mounted) {
        if (success) {
          // Limpa os abastecimentos em memória para evitar dados órfãos
          fuelingProvider.clearFuelings();
          setState(() {
            _selectedBrand = null;
            _selectedModel = null;
            _selectedYear = null;
            _engineCapacityController.clear();
            _models.clear();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Veículo excluído com sucesso.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(vehicleProvider.error ?? 'Erro ao excluir veículo.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meu Veículo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Marca
              const Text('Marca', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (_loadingBrands)
                const Center(child: CircularProgressIndicator())
              else if (_apiError != null && _brands.isEmpty)
                Column(
                  children: [
                    Text(_apiError!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _loadBrands,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                )
              else
                DropdownButtonFormField<FipeBrand>(
                  isExpanded: true,
                  value: _selectedBrand,
                  items: _brands
                      .map((brand) => DropdownMenuItem(
                            value: brand,
                            child: Text(brand.name),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBrand = value;
                      _models.clear();
                      _selectedModel = null;
                    });
                    if (value != null) {
                      _loadModels(value.code);
                    }
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Selecione a marca',
                  ),
                ),
              const SizedBox(height: 16),

              // Modelo
              const Text('Modelo', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (_loadingModels)
                const Center(child: CircularProgressIndicator())
              else if (_apiError != null && _models.isEmpty && _selectedBrand != null)
                Column(
                  children: [
                    Text(_apiError!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (_selectedBrand != null) {
                          _loadModels(_selectedBrand!.code);
                        }
                      },
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                )
              else
                DropdownButtonFormField<FipeModel>(
                  isExpanded: true,
                  value: _selectedModel,
                  items: _models
                      .map((model) => DropdownMenuItem(
                            value: model,
                            child: Text(model.name),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedModel = value;
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Selecione o modelo',
                  ),
                ),
              const SizedBox(height: 16),

              // Ano
              const Text('Ano', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedYear,
                items: _years
                    .map((year) => DropdownMenuItem(
                          value: year,
                          child: Text(year),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedYear = value;
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Selecione o ano',
                ),
              ),
              const SizedBox(height: 16),

              // Cilindrada
              const Text('Cilindrada do motor', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _engineCapacityController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: Validators.validateEngineCapacity,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Ex: 1.0',
                ),
              ),
              const SizedBox(height: 24),

              // Botões de ação
              Consumer<VehicleProvider>(
                builder: (context, provider, child) {
                  return Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: provider.isLoading ? null : _saveVehicle,
                          child: provider.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Salvar'),
                        ),
                      ),
                      if (provider.hasVehicle) ...[
                        const SizedBox(width: 16),
                        OutlinedButton(
                          onPressed: provider.isLoading ? null : _deleteVehicle,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('Excluir'),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
