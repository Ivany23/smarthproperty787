import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FavoritoService {
  static const String baseUrl = 'http://localhost:8080/api/favoritos';

  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final visitorId = prefs.getInt('visitorId');
    print('📌 _getUserId - visitorId recuperado: $visitorId');
    return visitorId;
  }

  Future<bool> adicionarFavorito(int idImovel) async {
    final userId = await _getUserId();
    print('🔵 adicionarFavorito - userId: $userId, idImovel: $idImovel');

    if (userId == null) {
      print('❌ adicionarFavorito - userId é null');
      return false;
    }

    try {
      final url = '$baseUrl/adicionar?idVisitante=$userId&idImovel=$idImovel';
      print('🔵 adicionarFavorito - URL: $url');

      final response = await http.post(Uri.parse(url));

      print('🔵 adicionarFavorito - Status: ${response.statusCode}');
      print('🔵 adicionarFavorito - Body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('❌ adicionarFavorito - Erro: $e');
      return false;
    }
  }

  Future<bool> removerFavorito(int idImovel) async {
    final userId = await _getUserId();
    print('🔴 removerFavorito - userId: $userId, idImovel: $idImovel');

    if (userId == null) {
      print('❌ removerFavorito - userId é null');
      return false;
    }

    try {
      final url = '$baseUrl/remover?idVisitante=$userId&idImovel=$idImovel';
      print('🔴 removerFavorito - URL: $url');

      final response = await http.delete(Uri.parse(url));

      print('🔴 removerFavorito - Status: ${response.statusCode}');
      print('🔴 removerFavorito - Body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('❌ removerFavorito - Erro: $e');
      return false;
    }
  }

  Future<bool> isFavorito(int idImovel) async {
    final userId = await _getUserId();
    print('🟢 isFavorito - userId: $userId, idImovel: $idImovel');

    if (userId == null) {
      print('❌ isFavorito - userId é null');
      return false;
    }

    try {
      final url = '$baseUrl/verificar?idVisitante=$userId&idImovel=$idImovel';
      print('🟢 isFavorito - URL: $url');

      final response = await http.get(Uri.parse(url));

      print('🟢 isFavorito - Status: ${response.statusCode}');
      print('🟢 isFavorito - Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final result = data['isFavorito'] == true;
        print('🟢 isFavorito - Resultado: $result');
        return result;
      }
      return false;
    } catch (e) {
      print('❌ isFavorito - Erro: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> listarFavoritos() async {
    final userId = await _getUserId();
    print('📋 listarFavoritos - userId: $userId');

    if (userId == null) {
      print('❌ listarFavoritos - userId é null');
      return [];
    }

    try {
      final url = '$baseUrl/visitante/$userId';
      print('📋 listarFavoritos - URL: $url');

      final response = await http.get(Uri.parse(url));

      print('📋 listarFavoritos - Status: ${response.statusCode}');
      print('📋 listarFavoritos - Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('📋 listarFavoritos - Total de favoritos: ${data.length}');
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('❌ listarFavoritos - Erro: $e');
      return [];
    }
  }
}
