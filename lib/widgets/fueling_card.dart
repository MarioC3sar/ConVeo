import 'package:flutter/material.dart';
import 'package:conveo/models/fueling.dart';

/// Widget que exibe um card com os detalhes de um abastecimento.
class FuelingCard extends StatelessWidget {
  final Fueling fueling;
  final VoidCallback onDelete;

  const FuelingCard({
    super.key,
    required this.fueling,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hasIndicators = fueling.consumption != null;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getFuelColor(fueling.fuelType),
          child: Icon(Icons.local_gas_station, color: Colors.white),
        ),
        title: Text(
          '${fueling.fuelType.toUpperCase()} — ${_formatCurrency(fueling.totalValue)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_formatDate(fueling.date)} • ${fueling.kilometers.toStringAsFixed(1)} km • ${fueling.liters.toStringAsFixed(1)} L',
            ),
            if (hasIndicators) ...[
              const SizedBox(height: 4),
              Text(
                'Consumo: ${fueling.consumption!.toStringAsFixed(2)} km/L | Custo: ${_formatCurrency(fueling.costPerKm!)} /km',
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
              ),
            ],
            if (!hasIndicators)
              const Text(
                'Primeiro abastecimento (referência)',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }

  Color _getFuelColor(String fuelType) {
    switch (fuelType.toLowerCase()) {
      case 'etanol':
        return Colors.green;
      case 'gasolina':
        return Colors.orange;
      case 'diesel':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  String _formatCurrency(double value) {
    return 'R\$ ${value.toStringAsFixed(2)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
