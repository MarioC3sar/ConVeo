import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:conveo/providers/vehicle_provider.dart';
import 'package:conveo/providers/fueling_provider.dart';
import 'package:conveo/widgets/main_navigation.dart';
import 'dart:io' show Platform;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Inicializa o SQLite FFI para plataformas desktop (Linux/macOS/Windows).
/// No Android/iOS, o sqflite nativo já funciona sem configuração extra.
Future<void> initDatabase() async {
  if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDatabase();
  runApp(const MyApp());
}

/// Ponto de entrada do aplicativo.
/// Configura os providers e o tema global.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VehicleProvider()),
        ChangeNotifierProvider(create: (_) => FuelingProvider()),
      ],
      child: MaterialApp(
        title: 'ConVeo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const MainNavigation(),
      ),
    );
  }
}
