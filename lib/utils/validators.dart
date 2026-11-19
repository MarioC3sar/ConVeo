/// Validações dos campos de entrada do usuário.
class Validators {
  Validators();

  /// Valida o preço por litro: deve ser maior que zero.
  static String? validatePricePerLiter(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe o preço por litro.';
    }
    final price = double.tryParse(value);
    if (price == null) {
      return 'Valor inválido. Use ponto para decimais (ex: 5.49).';
    }
    if (price <= 0) {
      return 'O preço deve ser maior que zero.';
    }
    return null;
  }

  /// Valida a quantidade de litros: deve ser maior que zero.
  static String? validateLiters(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe a quantidade de litros.';
    }
    final liters = double.tryParse(value);
    if (liters == null) {
      return 'Valor inválido. Use ponto para decimais (ex: 45.5).';
    }
    if (liters <= 0) {
      return 'A quantidade de litros deve ser maior que zero.';
    }
    return null;
  }

  /// Valida a quilometragem: deve ser maior que zero.
  static String? validateKilometers(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe a quilometragem atual.';
    }
    final km = double.tryParse(value);
    if (km == null) {
      return 'Valor inválido. Use ponto para decimais (ex: 50000).';
    }
    if (km <= 0) {
      return 'A quilometragem deve ser maior que zero.';
    }
    return null;
  }

  /// Valida se a quilometragem é maior que a do último abastecimento.
  static String? validateKilometersGreaterThan(
    String? value,
    double lastKilometers,
  ) {
    final kmError = validateKilometers(value);
    if (kmError != null) return kmError;

    final km = double.parse(value!);
    if (km <= lastKilometers) {
      return 'A quilometragem deve ser maior que $lastKilometers km.';
    }
    return null;
  }

  /// Valida a cilindrada do motor: deve ser maior que zero.
  static String? validateEngineCapacity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe a cilindrada do motor.';
    }
    final capacity = double.tryParse(value);
    if (capacity == null) {
      return 'Valor inválido. Use ponto para decimais (ex: 1.0).';
    }
    if (capacity <= 0) {
      return 'A cilindrada deve ser maior que zero.';
    }
    return null;
  }

  /// Valida o ano do veículo: deve estar entre 1886 e o ano atual + 1.
  static String? validateYear(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe o ano do veículo.';
    }
    final year = int.tryParse(value);
    if (year == null) {
      return 'Ano inválido.';
    }
    final currentYear = DateTime.now().year;
    if (year < 1886 || year > currentYear + 1) {
      return 'O ano deve estar entre 1886 e ${currentYear + 1}.';
    }
    return null;
  }
}
