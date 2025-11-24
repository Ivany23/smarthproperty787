import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/features/home/presentation/views/criar_marcacao_screen.dart';

class OfferDetails extends StatefulWidget {
  final int? imovelId;
  final String titulo;
  final String descricao;
  final double preco;
  final double area;
  final String finalidade;
  final String categoria;
  final String imageUrl;

  const OfferDetails({
    super.key,
    this.imovelId,
    required this.titulo,
    required this.descricao,
    required this.preco,
    required this.area,
    required this.finalidade,
    required this.categoria,
    required this.imageUrl,
  });

  @override
  State<OfferDetails> createState() => _OfferDetailsState();
}

class _OfferDetailsState extends State<OfferDetails> {
  Map<String, dynamic>? _localizacao;
  bool _loadingLocation = true;

  @override
  void initState() {
    super.initState();
    if (widget.imovelId != null) {
      _loadLocalizacao();
    } else {
      setState(() => _loadingLocation = false);
    }
  }

  Future<void> _loadLocalizacao() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/localizacao/listar'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> localizacoes = jsonDecode(response.body);
        final loc = localizacoes.firstWhere(
          (l) => l['idImovel'] == widget.imovelId,
          orElse: () => null,
        );
        setState(() {
          _localizacao = loc;
          _loadingLocation = false;
        });
      } else {
        setState(() => _loadingLocation = false);
      }
    } catch (e) {
      print('Erro ao carregar localização: $e');
      setState(() => _loadingLocation = false);
    }
  }

  String _formatPrice(double price) {
    return price
        .toStringAsFixed(2)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  IconData _getCategoryIcon() {
    switch (widget.categoria.toLowerCase()) {
      case 'apartamento':
        return Icons.apartment;
      case 'casa':
        return Icons.home;
      case 'terreno':
        return Icons.landscape;
      case 'comercial':
        return Icons.store;
      default:
        return Icons.home;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                widget.imageUrl.isNotEmpty
                    ? Image.network(
                        'http://localhost:8080${widget.imageUrl}',
                        width: double.infinity,
                        height: 300,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: double.infinity,
                            height: 300,
                            color: Colors.grey[300],
                            child: Icon(
                              _getCategoryIcon(),
                              size: 80,
                              color: Colors.grey[600],
                            ),
                          );
                        },
                      )
                    : Container(
                        width: double.infinity,
                        height: 300,
                        color: Colors.grey[300],
                        child: Icon(
                          _getCategoryIcon(),
                          size: 80,
                          color: Colors.grey[600],
                        ),
                      ),
                Positioned(
                  top: 40,
                  left: 16,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(Icons.arrow_back, color: Colors.black),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 16,
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(Icons.share, color: Colors.black),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(Icons.favorite_border, color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.titulo,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: widget.finalidade == 'ARRENDAMENTO'
                          ? Colors.blue.shade50
                          : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: widget.finalidade == 'ARRENDAMENTO'
                            ? Colors.blue.shade200
                            : Colors.green.shade200,
                      ),
                    ),
                    child: Text(
                      widget.finalidade == 'ARRENDAMENTO'
                          ? 'Para Arrendar'
                          : 'Para Venda',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: widget.finalidade == 'ARRENDAMENTO'
                            ? Colors.blue.shade700
                            : Colors.green.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'MZN ${_formatPrice(widget.preco)}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      if (widget.finalidade == 'ARRENDAMENTO')
                        const Text(
                          '/mês',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Características',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildAttribute(_getCategoryIcon(), widget.categoria),
                      if (widget.area > 0)
                        _buildAttribute(
                          Icons.square_foot,
                          '${widget.area.toInt()}m²',
                        ),
                      _buildAttribute(
                        widget.finalidade == 'ARRENDAMENTO'
                            ? Icons.key
                            : Icons.sell,
                        widget.finalidade == 'ARRENDAMENTO'
                            ? 'Arrendar'
                            : 'Venda',
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Descrição',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.descricao.isNotEmpty
                        ? widget.descricao
                        : 'Sem descrição disponível.',
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Localização',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_loadingLocation)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_localizacao != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          _buildLocationRow(
                            Icons.public,
                            'País',
                            _localizacao!['pais'] ?? 'Moçambique',
                          ),
                          const Divider(height: 20),
                          _buildLocationRow(
                            Icons.location_city,
                            'Província',
                            _localizacao!['provincia'] ?? 'N/A',
                          ),
                          const Divider(height: 20),
                          _buildLocationRow(
                            Icons.location_on,
                            'Cidade',
                            _localizacao!['cidade'] ?? 'N/A',
                          ),
                          if (_localizacao!['bairro'] != null &&
                              _localizacao!['bairro']
                                  .toString()
                                  .isNotEmpty) ...[
                            const Divider(height: 20),
                            _buildLocationRow(
                              Icons.place,
                              'Bairro',
                              _localizacao!['bairro'],
                            ),
                          ],
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.location_off, color: Colors.grey[600]),
                          const SizedBox(width: 12),
                          const Text(
                            'Localização não disponível',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 28),
                  const Text(
                    'Contacto',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.message, size: 20),
                          label: const Text('Mensagem'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blue.shade600,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.call, size: 20),
                          label: const Text('Ligar'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.green.shade600,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: widget.imovelId != null
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CriarMarcacaoScreen(
                        idImovel: widget.imovelId!,
                        tituloImovel: widget.titulo,
                      ),
                    ),
                  );
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Agendar Visita',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttribute(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Colors.black),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.black),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
