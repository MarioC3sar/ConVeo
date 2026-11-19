import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:conveo/providers/vehicle_provider.dart';
import 'package:conveo/providers/fueling_provider.dart';
import 'package:conveo/widgets/fueling_card.dart';

/// Tela de histórico de abastecimentos.
/// Lista todos os abastecimentos com opção de exclusão.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    _loadFuelings();
  }

  /// Carrega os abastecimentos quando a tela aparece.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadFuelings();
  }

  Future<void> _loadFuelings() async {
    final vehicleProvider = context.read<VehicleProvider>();
    final fuelingProvider = context.read<FuelingProvider>();

    if (vehicleProvider.hasVehicle) {
      await fuelingProvider.loadFuelings(vehicleProvider.vehicle!.id!);
    }
  }

  /// Exclui um abastecimento com confirmação.
  Future<void> _deleteFueling(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir abastecimento'),
        content: const Text('Tem certeza que deseja excluir este abastecimento?'),
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
      final fuelingProvider = context.read<FuelingProvider>();
      final success = await fuelingProvider.deleteFueling(id);

      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Abastecimento excluído.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de Abastecimentos')),
      body: Consumer<VehicleProvider>(
        builder: (context, vehicleProvider, child) {
          if (!vehicleProvider.hasVehicle) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.car_rental, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Nenhum veículo cadastrado.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Consumer<FuelingProvider>(
            builder: (context, fuelingProvider, child) {
              if (fuelingProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!fuelingProvider.hasFuelings) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.local_gas_station, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Nenhum abastecimento registrado.',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: fuelingProvider.fuelings.length,
                itemBuilder: (context, index) {
                  final fueling = fuelingProvider.fuelings[index];
                  return FuelingCard(
                    fueling: fueling,
                    onDelete: () => _deleteFueling(fueling.id!),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
