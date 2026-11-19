import 'package:flutter/material.dart';
import 'package:conveo/screens/dashboard_screen.dart';
import 'package:conveo/screens/vehicle_screen.dart';
import 'package:conveo/screens/fueling_screen.dart';
import 'package:conveo/screens/history_screen.dart';

/// Callback para trocar de aba, passada para as telas filhas.
typedef TabChangeCallback = void Function(int index);

/// Widget de navegação inferior que conecta as 4 telas principais.
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  /// Troca a aba ativa e notifica as telas filhas.
  void _switchTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _buildScreens();
  }

  void _buildScreens() {
    _screens = [
      DashboardScreen(onSwitchTab: _switchTab),
      const VehicleScreen(),
      const FuelingScreen(),
      const HistoryScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _switchTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_car),
            label: 'Veículo',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_gas_station),
            label: 'Abastecer',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'Histórico',
          ),
        ],
      ),
    );
  }
}
