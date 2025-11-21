import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/services/favorito_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _favoritoService = FavoritoService();
  List<Map<String, dynamic>> _favoritos = [];
  Map<int, Map<String, dynamic>> _imoveisData = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFavoritos();
  }

  Future<void> _loadFavoritos() async {
    print('🔄 _loadFavoritos - Iniciando carregamento...');
    setState(() => _loading = true);

    try {
      final favoritos = await _favoritoService.listarFavoritos();
      print('🔄 _loadFavoritos - Favoritos recebidos: ${favoritos.length}');

      Map<int, Map<String, dynamic>> tempImoveisData = {};

      for (var fav in favoritos) {
        try {
          final idImovelDynamic = fav['idImovel'];
          int idImovel;

          if (idImovelDynamic is int) {
            idImovel = idImovelDynamic;
          } else if (idImovelDynamic is String) {
            idImovel = int.parse(idImovelDynamic);
          } else {
            idImovel = idImovelDynamic as int;
          }

          print('🔄 _loadFavoritos - Buscando dados do imóvel ID: $idImovel');
          final imovelData = await _fetchImovelData(idImovel);
          if (imovelData != null) {
            tempImoveisData[idImovel] = imovelData;
            print('✅ _loadFavoritos - Dados do imóvel $idImovel carregados');
          } else {
            print('⚠️ _loadFavoritos - Dados do imóvel $idImovel são null');
          }
        } catch (e) {
          print('❌ _loadFavoritos - Erro ao processar favorito: $e');
          continue;
        }
      }

      print(
        '🔄 _loadFavoritos - Total de imóveis carregados: ${tempImoveisData.length}',
      );

      if (mounted) {
        setState(() {
          _favoritos = favoritos;
          _imoveisData = tempImoveisData;
          _loading = false;
        });
      }
    } catch (e) {
      print('❌ _loadFavoritos - Erro ao carregar favoritos: $e');
      if (mounted) {
        setState(() {
          _favoritos = [];
          _imoveisData = {};
          _loading = false;
        });
      }
    }
  }

  Future<Map<String, dynamic>?> _fetchImovelData(int idImovel) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/imovel/buscar/$idImovel'),
      );

      print('📦 _fetchImovelData - Status: ${response.statusCode}');
      print('📦 _fetchImovelData - Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // O backend retorna {success: true, imovel: {...}}
        if (data['imovel'] != null) {
          return data['imovel'];
        }
        return data;
      }
    } catch (e) {
      print('❌ Erro ao buscar imóvel $idImovel: $e');
      return null;
    }
    return null;
  }

  Future<void> _removerFavorito(int idImovel) async {
    final success = await _favoritoService.removerFavorito(idImovel);
    if (success) {
      _loadFavoritos();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Removido dos favoritos'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFF2C3E50),
        title: Row(
          children: [
            Icon(Icons.favorite, color: Colors.red, size: 24),
            SizedBox(width: 8),
            Text(
              'Meus Favoritos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          if (_favoritos.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_favoritos.length}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2C3E50)),
              ),
            )
          : _favoritos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Nenhum favorito ainda',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Adicione imóveis aos favoritos\nclicando no ❤️',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadFavoritos,
              color: Color(0xFF2C3E50),
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: _favoritos.length,
                itemBuilder: (context, index) {
                  final favorito = _favoritos[index];
                  final idImovelDynamic = favorito['idImovel'];

                  int idImovel;
                  try {
                    if (idImovelDynamic is int) {
                      idImovel = idImovelDynamic;
                    } else if (idImovelDynamic is String) {
                      idImovel = int.parse(idImovelDynamic);
                    } else {
                      idImovel = idImovelDynamic as int;
                    }
                  } catch (e) {
                    return SizedBox.shrink();
                  }

                  final imovel = _imoveisData[idImovel];

                  if (imovel == null) {
                    return SizedBox.shrink();
                  }

                  // CARD MODERNO COM TÍTULO, PREÇO E FINALIDADE
                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Imagem
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                          child: imovel['imagemPrincipalUrl'] != null
                              ? Image.network(
                                  'http://localhost:8080${imovel['imagemPrincipalUrl']}',
                                  width: 110,
                                  height: 110,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 110,
                                    height: 110,
                                    color: Colors.grey[200],
                                    child: Icon(
                                      Icons.home,
                                      size: 40,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                )
                              : Container(
                                  width: 110,
                                  height: 110,
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.home,
                                    size: 40,
                                    color: Colors.grey[400],
                                  ),
                                ),
                        ),
                        // Informações
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Título
                                Text(
                                  imovel['titulo'] ?? 'Sem título',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2C3E50),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 6),
                                // Badge de Finalidade
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        imovel['finalidade'] == 'ARRENDAMENTO'
                                        ? Colors.blue[50]
                                        : Colors.green[50],
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color:
                                          imovel['finalidade'] == 'ARRENDAMENTO'
                                          ? Colors.blue
                                          : Colors.green,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    imovel['finalidade'] == 'ARRENDAMENTO'
                                        ? 'Arrendamento'
                                        : 'Venda',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          imovel['finalidade'] == 'ARRENDAMENTO'
                                          ? Colors.blue[700]
                                          : Colors.green[700],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                // Preço
                                Text(
                                  '${imovel['preco'] ?? '0'} MT',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Botão de remover
                        IconButton(
                          icon: Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 28,
                          ),
                          onPressed: () => _removerFavorito(idImovel),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
