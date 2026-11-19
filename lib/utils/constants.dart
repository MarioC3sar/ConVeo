/// Constantes usadas em todo o aplicativo.
class Constants {
  Constants();

  /// Tipos de combustível disponíveis.
  static const List<String> fuelTypes = ['etanol', 'gasolina', 'diesel'];

  /// URL base da BrasilAPI para consulta FIPE.
  static const String fipeBaseUrl = 'https://brasilapi.com.br/api/fipe';

  /// Nome do banco de dados SQLite.
  static const String databaseName = 'fuel_control.db';

  /// Versão do banco de dados.
  static const int databaseVersion = 1;
}
