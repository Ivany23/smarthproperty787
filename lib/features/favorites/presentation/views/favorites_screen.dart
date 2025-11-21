import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
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
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      }
    } catch (e) {
      print('Erro ao buscar imóvel $idImovel: $e');
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

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return '';
    }
  }

  IconData _getCategoryIcon(String? categoria) {
    switch (categoria?.toUpperCase()) {
      case 'APARTAMENTO':
        return Icons.apartment;
      case 'CASA':
        return Icons.home;
      case 'TERRENO':
        return Icons.landscape;
      case 'COMERCIAL':
        return Icons.store;
      default:
        return Icons.home_work;
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF2C3E50),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Carregando favoritos...',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            )
          : _favoritos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.favorite_border,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Nenhum favorito ainda',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Adicione imóveis aos favoritos\nclicando no ❤️',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[500]),
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
                  final dataRegistro = favorito['dataRegistro'];

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

                  return Container(
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          _showPropertyDetails(imovel);
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                  child: imovel['imagemPrincipalUrl'] != null
                                      ? Image.network(
                                          'http://localhost:8080${imovel['imagemPrincipalUrl']}',
                                          width: double.infinity,
                                          height: 200,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                                height: 200,
                                                color: Colors.grey[300],
                                                child: Icon(
                                                  _getCategoryIcon(
                                                    imovel['categoria'],
                                                  ),
                                                  size: 80,
                                                  color: Colors.grey[500],
                                                ),
                                              ),
                                        )
                                      : Container(
                                          height: 200,
                                          color: Colors.grey[300],
                                          child: Icon(
                                            _getCategoryIcon(
                                              imovel['categoria'],
                                            ),
                                            size: 80,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                ),
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                      onPressed: () =>
                                          _removerFavorito(idImovel),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 12,
                                  left: 12,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          imovel['finalidade'] == 'ARRENDAMENTO'
                                          ? Colors.blue
                                          : Colors.green,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      imovel['finalidade'] == 'ARRENDAMENTO'
                                          ? 'Arrendar'
                                          : 'Venda',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    imovel['titulo'] ?? 'Sem título',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2C3E50),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.attach_money,
                                        size: 20,
                                        color: Colors.green,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        '${imovel['precoMzn']} MZN',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  Row(
                                    children: [
                                      _buildIconInfo(
                                        Icons.square_foot,
                                        '${imovel['area']} m²',
                                      ),
                                      SizedBox(width: 16),
                                      _buildIconInfo(
                                        _getCategoryIcon(imovel['categoria']),
                                        imovel['categoria'] ?? '',
                                      ),
                                    ],
                                  ),
                                  if (dataRegistro != null) ...[
                                    SizedBox(height: 12),
                                    Divider(),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'Adicionado em ${_formatDate(dataRegistro)}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildIconInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Color(0xFF2C3E50)),
        SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showPropertyDetails(Map<String, dynamic> imovel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: EdgeInsets.all(24),
                  children: [
                    if (imovel['imagemPrincipalUrl'] != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          'http://localhost:8080${imovel['imagemPrincipalUrl']}',
                          height: 250,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    SizedBox(height: 20),
                    Text(
                      imovel['titulo'] ?? 'Detalhes do Imóvel',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.attach_money,
                            color: Colors.green,
                            size: 28,
                          ),
                          Text(
                            '${imovel['precoMzn']} MZN',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildDetailRow(
                      'Área',
                      '${imovel['area']} m²',
                      Icons.square_foot,
                    ),
                    _buildDetailRow(
                      'Categoria',
                      imovel['categoria'] ?? '',
                      _getCategoryIcon(imovel['categoria']),
                    ),
                    _buildDetailRow(
                      'Finalidade',
                      imovel['finalidade'] ?? '',
                      Icons.info_outline,
                    ),
                    if (imovel['descricao'] != null) ...[
                      SizedBox(height: 20),
                      Text(
                        'Descrição',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        imovel['descricao'],
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                    ],
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFF2C3E50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Color(0xFF2C3E50)),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
