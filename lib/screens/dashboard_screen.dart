import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:conveo/providers/vehicle_provider.dart';
import 'package:conveo/providers/fueling_provider.dart';
import 'package:conveo/widgets/consumption_chart.dart';
import 'package:conveo/widgets/cost_chart.dart';

/// Tela principal do aplicativo — Dashboard com indicadores e gráficos.
class DashboardScreen extends StatefulWidget {
  final void Function(int)? onSwitchTab;

  const DashboardScreen({this.onSwitchTab, super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  Future<void> _loadData() async {
    final vehicleProvider = context.read<VehicleProvider>();
    final fuelingProvider = context.read<FuelingProvider>();

    // Carrega veículo se não estiver carregado
    if (!vehicleProvider.hasVehicle && !vehicleProvider.isLoading) {
      await vehicleProvider.loadVehicle();
    }

    // Carrega abastecimentos se houver veículo
    if (vehicleProvider.hasVehicle) {
      await fuelingProvider.loadFuelings(vehicleProvider.vehicle!.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ConVeo'),
        centerTitle: true,
      ),
      body: Consumer<VehicleProvider>(
        builder: (context, vehicleProvider, child) {
          if (!vehicleProvider.hasVehicle) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.car_rental, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Bem-vindo ao ConVeo!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Cadastre seu veículo para começar a controlar seus gastos com combustível.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Navega para a aba do veículo usando a callback do MainNavigation
                      widget.onSwitchTab?.call(1);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Cadastrar Veículo'),
                  ),
                ],
              ),
            );
          }

          // Exibe informações do veículo
          final vehicle = vehicleProvider.vehicle!;
          return RefreshIndicator(
            onRefresh: _loadData,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Card do veículo
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.directions_car, color: Colors.blue),
                    title: Text(
                      vehicle.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Cilindrada: ${vehicle.engineCapacity}L'),
                  ),
                ),
                const SizedBox(height: 16),

                // Resumo dos abastecimentos
                Consumer<FuelingProvider>(
                  builder: (context, fuelingProvider, child) {
                    if (fuelingProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final fuelings = fuelingProvider.fuelings;
                    if (fuelings.isEmpty) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              const Icon(Icons.local_gas_station, size: 48, color: Colors.grey),
                              const SizedBox(height: 8),
                              const Text(
                                'Nenhum abastecimento registrado.',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Registre seu primeiro abastecimento para começar a ver os indicadores.',
                                style: TextStyle(color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Calcula totais
                    double totalGasto = 0;
                    double totalLitros = 0;
                    double ultimoConsumo = 0;
                    double ultimoCustoKm = 0;
                    bool temIndicadores = false;

                    for (final f in fuelings) {
                      totalGasto += f.totalValue;
                      totalLitros += f.liters;
                      if (f.consumption != null) {
                        ultimoConsumo = f.consumption!;
                        ultimoCustoKm = f.costPerKm!;
                        temIndicadores = true;
                      }
                    }

                    return Column(
                      children: [
                        // Cards de indicadores
                        Row(
                          children: [
                            Expanded(
                              child: _buildIndicatorCard(
                                'Total Gasto',
                                'R\$ ${totalGasto.toStringAsFixed(2)}',
                                Icons.attach_money,
                                Colors.green,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildIndicatorCard(
                                'Total Litros',
                                '${totalLitros.toStringAsFixed(1)} L',
                                Icons.local_drink,
                                Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _buildIndicatorCard(
                                'Abastecimentos',
                                '${fuelings.length}',
                                Icons.list,
                                Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildIndicatorCard(
                                'Último Consumo',
                                temIndicadores
                                    ? '${ultimoConsumo.toStringAsFixed(2)} km/L'
                                    : 'N/A',
                                Icons.speed,
                                Colors.purple,
                              ),
                            ),
                          ],
                        ),
                        if (temIndicadores) ...[
                          const SizedBox(height: 8),
                          _buildIndicatorCard(
                            'Último Custo/km',
                            'R\$ ${ultimoCustoKm.toStringAsFixed(3)}',
                            Icons.money_off,
                            Colors.red,
                          ),
                        ],
                        const SizedBox(height: 24),

                        // Gráfico de consumo
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              children: [
                                const Text(
                                  'Evolução do Consumo (km/L)',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                ConsumptionChart(fuelings: fuelings),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Gráfico de custo/km
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              children: [
                                const Text(
                                  'Evolução do Custo (R\$/km)',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                CostChart(fuelings: fuelings),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Widget auxiliar para os cards de indicadores.
  Widget _buildIndicatorCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
