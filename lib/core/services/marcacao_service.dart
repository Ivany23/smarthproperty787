import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MarcacaoService {
  static const String baseUrl = 'http://localhost:8080/api/marcacoes';

  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final visitorId = prefs.getInt('visitorId');
    print('📌 MarcacaoService - visitorId recuperado: $visitorId');
    return visitorId;
  }

  Future<int?> _getAnuncianteId() async {
    final prefs = await SharedPreferences.getInstance();
    final anuncianteId = prefs.getInt('anuncianteId');
    print('📌 MarcacaoService - anuncianteId recuperado: $anuncianteId');
    return anuncianteId;
  }

  Future<bool> _isAnunciante() async {
    final anuncianteId = await _getAnuncianteId();
    return anuncianteId != null;
  }

  // Criar nova marcação
  Future<Map<String, dynamic>?> criarMarcacao({
    required int idImovel,
    required DateTime dataHoraInicio,
    required DateTime dataHoraFim,
    String? observacoes,
  }) async {
    final userId = await _getUserId();
    print('📅 criarMarcacao - userId: $userId, idImovel: $idImovel');

    if (userId == null) {
      print('❌ criarMarcacao - userId é null');
      return null;
    }

    try {
      final url = '$baseUrl/criar';
      print('📅 criarMarcacao - URL: $url');

      final body = {
        'idVisitante': userId,
        'idImovel': idImovel,
        'dataHoraInicio': dataHoraInicio.toIso8601String(),
        'dataHoraFim': dataHoraFim.toIso8601String(),
        'observacoes': observacoes,
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      print('📅 criarMarcacao - Status: ${response.statusCode}');
      print('📅 criarMarcacao - Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      }
      return null;
    } catch (e) {
      print('❌ criarMarcacao - Erro: $e');
      return null;
    }
  }

  // Confirmar marcação (apenas anunciante)
  Future<bool> confirmarMarcacao(int idMarcacao) async {
    final anuncianteId = await _getAnuncianteId();
    print(
      '✅ confirmarMarcacao - anuncianteId: $anuncianteId, idMarcacao: $idMarcacao',
    );

    if (anuncianteId == null) {
      print('❌ confirmarMarcacao - anuncianteId é null');
      return false;
    }

    try {
      final url = '$baseUrl/confirmar/$idMarcacao?idAnunciante=$anuncianteId';
      print('✅ confirmarMarcacao - URL: $url');

      final response = await http.put(Uri.parse(url));

      print('✅ confirmarMarcacao - Status: ${response.statusCode}');
      print('✅ confirmarMarcacao - Body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('❌ confirmarMarcacao - Erro: $e');
      return false;
    }
  }

  // Cancelar marcação
  Future<bool> cancelarMarcacao(int idMarcacao) async {
    final userId = await _getUserId();
    final isAnunciante = await _isAnunciante();
    final anuncianteId = await _getAnuncianteId();

    print(
      '❌ cancelarMarcacao - userId: $userId, idMarcacao: $idMarcacao, isAnunciante: $isAnunciante',
    );

    if (userId == null) {
      print('❌ cancelarMarcacao - userId é null');
      return false;
    }

    try {
      final idUsuario = isAnunciante ? anuncianteId : userId;
      final url =
          '$baseUrl/cancelar/$idMarcacao?idUsuario=$idUsuario&isAnunciante=$isAnunciante';
      print('❌ cancelarMarcacao - URL: $url');

      final response = await http.put(Uri.parse(url));

      print('❌ cancelarMarcacao - Status: ${response.statusCode}');
      print('❌ cancelarMarcacao - Body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('❌ cancelarMarcacao - Erro: $e');
      return false;
    }
  }

  // Listar marcações do visitante
  Future<List<Map<String, dynamic>>> listarMinhasMarcacoes() async {
    final userId = await _getUserId();
    print('📋 listarMinhasMarcacoes - userId: $userId');

    if (userId == null) {
      print('❌ listarMinhasMarcacoes - userId é null');
      return [];
    }

    try {
      final url = '$baseUrl/visitante/$userId';
      print('📋 listarMinhasMarcacoes - URL: $url');

      final response = await http.get(Uri.parse(url));

      print('📋 listarMinhasMarcacoes - Status: ${response.statusCode}');
      print('📋 listarMinhasMarcacoes - Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('📋 listarMinhasMarcacoes - Total: ${data.length}');
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('❌ listarMinhasMarcacoes - Erro: $e');
      return [];
    }
  }

  // Listar marcações de um imóvel (para o dono)
  Future<List<Map<String, dynamic>>> listarMarcacoesImovel(int idImovel) async {
    print('🏠 listarMarcacoesImovel - idImovel: $idImovel');

    try {
      final url = '$baseUrl/imovel/$idImovel';
      print('🏠 listarMarcacoesImovel - URL: $url');

      final response = await http.get(Uri.parse(url));

      print('🏠 listarMarcacoesImovel - Status: ${response.statusCode}');
      print('🏠 listarMarcacoesImovel - Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('🏠 listarMarcacoesImovel - Total: ${data.length}');
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('❌ listarMarcacoesImovel - Erro: $e');
      return [];
    }
  }

  // Buscar marcação por ID
  Future<Map<String, dynamic>?> buscarMarcacao(int idMarcacao) async {
    print('🔍 buscarMarcacao - idMarcacao: $idMarcacao');

    try {
      final url = '$baseUrl/$idMarcacao';
      print('🔍 buscarMarcacao - URL: $url');

      final response = await http.get(Uri.parse(url));

      print('🔍 buscarMarcacao - Status: ${response.statusCode}');
      print('🔍 buscarMarcacao - Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['marcacao'];
      }
      return null;
    } catch (e) {
      print('❌ buscarMarcacao - Erro: $e');
      return null;
    }
  }
}
