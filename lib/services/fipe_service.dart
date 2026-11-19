import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:conveo/utils/constants.dart';

/// Modelo simples para uma marca de veículo da API.
class FipeBrand {
  final String code;
  final String name;

  FipeBrand({required this.code, required this.name});

  factory FipeBrand.fromJson(Map<String, dynamic> json) {
    return FipeBrand(
      code: json['valor'] as String,
      name: json['nome'] as String,
    );
  }
}

/// Modelo simples para um modelo de veículo da API.
class FipeModel {
  final String code;
  final String name;

  FipeModel({required this.code, required this.name});

  factory FipeModel.fromJson(Map<String, dynamic> json) {
    return FipeModel(
      code: json['valor'] as String,
      name: json['modelo'] as String,
    );
  }
}

/// Serviço para consultar a BrasilAPI (FIPE).
/// Retorna marcas e modelos de veículos para cadastro.
class FipeService {
  final http.Client _client;

  FipeService({http.Client? client}) : _client = client ?? http.Client();

  /// Consulta a lista de marcas de carros.
  Future<List<FipeBrand>> getBrands() async {
    final response = await _client.get(
      Uri.parse('${Constants.fipeBaseUrl}/marcas/v1/carros'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body) as List<dynamic>;
      return data.map((item) => FipeBrand.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Erro ao carregar marcas: HTTP ${response.statusCode}');
    }
  }

  /// Consulta os modelos de uma marca específica.
  Future<List<FipeModel>> getModels(String brandCode) async {
    final response = await _client.get(
      Uri.parse('${Constants.fipeBaseUrl}/veiculos/v1/carros/$brandCode'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body) as List<dynamic>;
      return data.map((item) => FipeModel.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Erro ao carregar modelos: HTTP ${response.statusCode}');
    }
  }
}
