import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:conveo/models/fueling.dart';

/// Gráfico de evolução do custo por quilômetro em R$/km.
class CostChart extends StatelessWidget {
  final List<Fueling> fuelings;

  const CostChart({super.key, required this.fuelings});

  @override
  Widget build(BuildContext context) {
    // Filtra apenas abastecimentos com dados de custo
    final data = fuelings.where((f) => f.costPerKm != null).toList();

    if (data.length < 2) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Adicione mais abastecimentos para ver o gráfico de custo/km.',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 1.5,
      child: LineChart(
        _buildData(data),
      ),
    );
  }

  LineChartData _buildData(List<Fueling> data) {
    final spots = <FlSpot>[];
    for (int i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[i].costPerKm!));
    }

    return LineChartData(
      gridData: FlGridData(show: true),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, _) => Text(
              'R\$${value.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 10),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, _) {
              final index = value.toInt();
              if (index >= 0 && index < data.length) {
                final d = data[index].date;
                return Text(
                  '${d.day}/${d.month}',
                  style: const TextStyle(fontSize: 10),
                );
              }
              return const Text('');
            },
          ),
        ),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(
        border: Border.all(color: Colors.grey),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Colors.red,
          barWidth: 3,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(show: false),
        ),
      ],
      minY: 0,
    );
  }
}
