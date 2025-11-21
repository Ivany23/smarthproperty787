import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/constants/assets.dart';
import 'package:flutter_application_1/core/constants/colors.dart';
import 'package:flutter_application_1/core/shared/widgets/custom_input.dart';
import 'package:flutter_application_1/core/shared/widgets/favorite_button.dart';
import 'package:flutter_application_1/features/home/presentation/views/offers_details.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class OffersView extends StatefulWidget {
  const OffersView({super.key});

  @override
  State<OffersView> createState() => _OffersViewState();
}

class _OffersViewState extends State<OffersView> {
  String welcomeMessage = "Olá!";
  String avatarLetter = "D";
  List<dynamic> _anuncios = [];
  bool _isLoading = true;

  late final TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    _loadVisitorData();
    _loadAnuncios();
  }

  Future<void> _loadVisitorData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('visitorName') ?? 'Visitante';
    if (!mounted) return;
    setState(() {
      welcomeMessage = 'Olá, $name!';
      avatarLetter = name.isNotEmpty ? name[0].toUpperCase() : 'V';
    });
  }

  Future<void> _loadAnuncios() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/imovel/listar'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('Imóveis carregados: ${data.length}');
        if (data.isNotEmpty) {
          print('Primeiro imóvel: ${data[0]}');
        }
        setState(() {
          _anuncios = data;
          _isLoading = false;
        });
      } else {
        print('Erro ao carregar imóveis: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erro ao carregar imóveis: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: kToolbarHeight + 10,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        leading: Container(
          margin: const EdgeInsets.only(left: 20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.fromBorderSide(
              BorderSide(width: 1, color: AppColors.primary),
            ),
          ),
          child: CircleAvatar(
            backgroundColor: const Color(0XFFD9D9D9),
            radius: 25,
            child: Text(avatarLetter, style: const TextStyle(fontSize: 22)),
          ),
        ),
        actions: [
          InkWell(
            onTap: () {},
            child: const Icon(
              Icons.location_searching_sharp,
              color: Colors.black45,
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(20),
            child: Image(image: AssetImage(AppIcons.notification)),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(welcomeMessage, style: const TextStyle(fontSize: 24)),
                CustomInput(
                  controller: searchController,
                  iconUri: AppIcons.search,
                  iconSize: 6,
                  placeholder: "Pesquisar imóveis...",
                  isPassword: false,
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: quickOptions.map((element) {
                    return Container(
                      height: 75,
                      width: 75,
                      decoration: BoxDecoration(
                        boxShadow: const [
                          BoxShadow(
                            offset: Offset(0, 4),
                            blurRadius: 10,
                            color: Colors.black12,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Image(
                            image: AssetImage(AppIcons.rent),
                            width: 30,
                          ),
                          Text(element),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 30),
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_anuncios.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Text(
                        'Nenhum imóvel disponível no momento',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  )
                else
                  OfferViewPropertyList(
                    title: "Imóveis Disponíveis",
                    anuncios: _anuncios,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OfferViewPropertyList extends StatefulWidget {
  const OfferViewPropertyList({
    super.key,
    required this.title,
    required this.anuncios,
  });

  final String title;
  final List<dynamic> anuncios;

  @override
  State<OfferViewPropertyList> createState() => _OfferViewPropertyListState();
}

class _OfferViewPropertyListState extends State<OfferViewPropertyList> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          widget.title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        Column(
          children: widget.anuncios
              .where((imovel) {
                return imovel != null;
              })
              .map((imovel) {
                final imovelId = imovel['id'];
                final imageUrl = imovel['imagemPrincipalUrl'] ?? '';
                final titulo = imovel['titulo'] ?? 'Sem título';
                final descricao = imovel['descricao'] ?? '';

                var preco = imovel['precoMzn'] ?? 0;
                var area = imovel['area'] ?? 0;

                final finalidade = imovel['finalidade'] ?? 'VENDA';
                final categoria = imovel['categoria'] ?? 'Casa';

                double precoDouble = 0.0;
                if (preco is int) {
                  precoDouble = preco.toDouble();
                } else if (preco is double) {
                  precoDouble = preco;
                } else if (preco is num) {
                  precoDouble = preco.toDouble();
                }

                double areaDouble = 0.0;
                if (area is int) {
                  areaDouble = area.toDouble();
                } else if (area is double) {
                  areaDouble = area;
                } else if (area is num) {
                  areaDouble = area.toDouble();
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: PropertyCard(
                    imovelId: imovelId is int ? imovelId : null,
                    imageUrl: imageUrl,
                    titulo: titulo,
                    descricao: descricao,
                    preco: precoDouble,
                    area: areaDouble,
                    finalidade: finalidade,
                    categoria: categoria,
                  ),
                );
              })
              .toList(),
        ),
      ],
    );
  }
}

class PropertyCard extends StatefulWidget {
  final int? imovelId;
  final String imageUrl;
  final String titulo;
  final String descricao;
  final double preco;
  final double area;
  final String finalidade;
  final String categoria;

  const PropertyCard({
    super.key,
    this.imovelId,
    required this.imageUrl,
    required this.titulo,
    required this.descricao,
    required this.preco,
    required this.area,
    required this.finalidade,
    required this.categoria,
  });

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  bool isFavorite = false;

  String _formatPrice(double price) {
    return 'MZN ${price.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
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
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          builder: (context) {
            return OfferDetails(
              imovelId: widget.imovelId,
              titulo: widget.titulo,
              descricao: widget.descricao,
              preco: widget.preco,
              area: widget.area,
              finalidade: widget.finalidade,
              categoria: widget.categoria,
              imageUrl: widget.imageUrl,
            );
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(left: 10, right: 10, bottom: 16, top: 5),
        padding: const EdgeInsets.only(bottom: 10, left: 4, right: 4, top: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              offset: Offset(0, 4),
              blurRadius: 10,
              color: Colors.black12,
            ),
            BoxShadow(
              offset: Offset(0, 0),
              blurRadius: 0,
              spreadRadius: 0.5,
              color: Colors.black12,
            ),
          ],
        ),
        constraints: const BoxConstraints(minHeight: 230),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: widget.imageUrl.isNotEmpty
                      ? Image.network(
                          'http://localhost:8080${widget.imageUrl}',
                          fit: BoxFit.cover,
                          height: 118,
                          width: double.maxFinite,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 118,
                              width: double.maxFinite,
                              color: Colors.grey[300],
                              child: Icon(
                                _getCategoryIcon(),
                                size: 50,
                                color: Colors.grey,
                              ),
                            );
                          },
                        )
                      : Container(
                          height: 118,
                          width: double.maxFinite,
                          color: Colors.grey[300],
                          child: Icon(
                            _getCategoryIcon(),
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                ),
                if (widget.imovelId != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: FavoriteButton(
                        idImovel: widget.imovelId!,
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    widget.finalidade == 'ARRENDAMENTO'
                        ? "Para arrendar"
                        : "Para venda",
                    style: const TextStyle(fontSize: 8),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: _formatPrice(widget.preco),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: widget.finalidade == 'ARRENDAMENTO' ? '/mês' : '',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Text(
                widget.titulo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Text(
                widget.descricao,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[600], fontSize: 8),
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Wrap(
                direction: Axis.horizontal,
                spacing: 5,
                runSpacing: 5.0,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _buildAttribute(Icons.category, widget.categoria),
                  if (widget.area > 0)
                    _buildAttribute(
                      Icons.square_foot,
                      '${widget.area.toInt()}m²',
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttribute(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.grey[600]),
        const SizedBox(width: 2),
        Text(value, style: TextStyle(fontSize: 8, color: Colors.grey[600])),
      ],
    );
  }
}

class HeartCirclePainter extends CustomPainter {
  final bool isFavorite;

  HeartCirclePainter(this.isFavorite);

  Path _createFavoritePath(Size size) {
    final double scaleX = size.width / 24.0;
    final double scaleY = size.height / 24.0;

    Path path = Path();

    path.moveTo(12 * scaleX, 21.35 * scaleY);
    path.lineTo(10.55 * scaleX, 20.03 * scaleY);

    path.cubicTo(
      5.4 * scaleX,
      15.36 * scaleY,
      2 * scaleX,
      12.28 * scaleY,
      2 * scaleX,
      8.5 * scaleY,
    );

    path.cubicTo(
      2 * scaleX,
      5.42 * scaleY,
      4.42 * scaleX,
      3 * scaleY,
      7.5 * scaleX,
      3 * scaleY,
    );

    path.cubicTo(
      9.24 * scaleX,
      3 * scaleY,
      10.91 * scaleX,
      3.81 * scaleY,
      12 * scaleX,
      5.09 * scaleY,
    );
    path.cubicTo(
      13.09 * scaleX,
      3.81 * scaleY,
      14.76 * scaleX,
      3 * scaleY,
      16.5 * scaleX,
      3 * scaleY,
    );

    path.cubicTo(
      19.58 * scaleX,
      3 * scaleY,
      22 * scaleX,
      5.42 * scaleY,
      22 * scaleX,
      8.5 * scaleY,
    );

    path.cubicTo(
      22 * scaleX,
      12.28 * scaleY,
      18.6 * scaleX,
      15.36 * scaleY,
      13.45 * scaleX,
      20.04 * scaleY,
    );
    path.lineTo(12 * scaleX, 21.35 * scaleY);
    path.close();

    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Paint whitePaint = Paint()..color = Colors.white;
    final Paint redPaint = Paint()..color = Colors.red;

    double radius = min(size.width / 1.1, size.height / 1.1);
    final circlePath = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(size.width / 2.1, size.height / 2.2),
          radius: radius,
        ),
      );

    Path heartPath = _createFavoritePath(size);

    if (isFavorite) {
      canvas.drawPath(circlePath, whitePaint);
      canvas.drawPath(heartPath, redPaint);
    } else {
      Path finalPath = Path.combine(
        PathOperation.difference,
        circlePath,
        heartPath,
      );
      canvas.drawPath(finalPath, whitePaint);
    }
  }

  @override
  bool shouldRepaint(covariant HeartCirclePainter oldDelegate) {
    return oldDelegate.isFavorite != isFavorite;
  }
}

class HeartCircleButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onTap;

  const HeartCircleButton({
    super.key,
    required this.isFavorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: HeartCirclePainter(isFavorite),
        child: const SizedBox(width: 18, height: 18),
      ),
    );
  }
}

const List<String> quickOptions = ["Arrendar", "Comprar", "Vender"];
