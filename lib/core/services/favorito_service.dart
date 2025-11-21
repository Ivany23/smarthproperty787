import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FavoritoService {
  static const String baseUrl = 'http://localhost:8080/api/favoritos';

  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  Future<bool> adicionarFavorito(int idImovel) async {
    final userId = await _getUserId();
    if (userId == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/adicionar?idVisitante=$userId&idImovel=$idImovel'),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removerFavorito(int idImovel) async {
    final userId = await _getUserId();
    if (userId == null) return false;

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/remover?idVisitante=$userId&idImovel=$idImovel'),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isFavorito(int idImovel) async {
    final userId = await _getUserId();
    if (userId == null) return false;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/verificar?idVisitante=$userId&idImovel=$idImovel'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['isFavorito'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> listarFavoritos() async {
    final userId = await _getUserId();
    if (userId == null) return [];

    try {
      final response = await http.get(Uri.parse('$baseUrl/visitante/$userId'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
