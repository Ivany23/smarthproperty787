import 'package:flutter/material.dart';
import '../../services/favorito_service.dart';

class FavoriteButton extends StatefulWidget {
  final int idImovel;
  final double size;

  const FavoriteButton({Key? key, required this.idImovel, this.size = 24})
    : super(key: key);

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  final _favoritoService = FavoritoService();
  bool _isFavorito = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkFavorito();
  }

  Future<void> _checkFavorito() async {
    final isFav = await _favoritoService.isFavorito(widget.idImovel);
    if (mounted) {
      setState(() {
        _isFavorito = isFav;
        _loading = false;
      });
    }
  }

  Future<void> _toggleFavorito() async {
    setState(() => _loading = true);

    bool success;
    if (_isFavorito) {
      success = await _favoritoService.removerFavorito(widget.idImovel);
    } else {
      success = await _favoritoService.adicionarFavorito(widget.idImovel);
    }

    if (success && mounted) {
      setState(() {
        _isFavorito = !_isFavorito;
        _loading = false;
      });
    } else if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return IconButton(
      icon: Icon(
        _isFavorito ? Icons.favorite : Icons.favorite_border,
        color: _isFavorito ? Colors.red : Colors.white,
        size: widget.size,
      ),
      onPressed: _toggleFavorito,
    );
  }
}
