import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:conveo/utils/constants.dart';

/// Classe responsável por gerenciar o banco de dados SQLite.
/// Cria as tabelas e fornece acesso ao banco para os repositórios.
class DatabaseHelper {
  DatabaseHelper();

  static final DatabaseHelper instance = DatabaseHelper();
  Database? _database;

  /// Retorna a instância do banco, inicializando se necessário.
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Inicializa o banco de dados e cria as tabelas.
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, Constants.databaseName);

    final db = await openDatabase(
      path,
      version: Constants.databaseVersion,
      onCreate: _onCreate,
    );

    return db;
  }

  /// Cria as tabelas vehicles e fuelings.
  Future<void> _onCreate(Database db, int version) async {
    // Tabela de veículos
    await db.execute('''
      CREATE TABLE vehicles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        brand TEXT NOT NULL,
        model TEXT NOT NULL,
        year INTEGER NOT NULL,
        engine_capacity REAL NOT NULL
      )
    ''');

    // Tabela de abastecimentos
    await db.execute('''
      CREATE TABLE fuelings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicle_id INTEGER NOT NULL,
        fuel_type TEXT NOT NULL,
        price_per_liter REAL NOT NULL,
        kilometers REAL NOT NULL,
        liters REAL NOT NULL,
        date TEXT NOT NULL,
        total_value REAL NOT NULL,
        FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE
      )
    ''');
  }

  /// Fecha o banco de dados.
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
