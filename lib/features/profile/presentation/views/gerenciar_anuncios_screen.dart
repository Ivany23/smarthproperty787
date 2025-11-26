import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class GerenciarAnunciosScreen extends StatefulWidget {
  const GerenciarAnunciosScreen({Key? key}) : super(key: key);

  @override
  State<GerenciarAnunciosScreen> createState() =>
      _GerenciarAnunciosScreenState();
}

class _GerenciarAnunciosScreenState extends State<GerenciarAnunciosScreen> {
  List<Map<String, dynamic>> _imoveis = [];
  bool _isLoading = true;
  int? _anuncianteId;

  @override
  void initState() {
    super.initState();
    _carregarAnuncios();
  }

  Future<void> _carregarAnuncios() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      _anuncianteId = prefs.getInt('anuncianteId');

      if (_anuncianteId == null) {
        throw Exception('Anunciante não encontrado');
      }

      final response = await http.get(
        Uri.parse('http://localhost:8080/api/imovel/anunciante/$_anuncianteId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _imoveis = data.map((e) => e as Map<String, dynamic>).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Erro ao carregar anúncios');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar anúncios: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deletarImovel(int idImovel) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Eliminar Anúncio'),
        content: const Text(
          'Tem certeza que deseja eliminar este anúncio? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final response = await http.delete(
          Uri.parse('http://localhost:8080/api/imovel/deletar/$idImovel'),
        );

        if (response.statusCode == 200) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Anúncio eliminado com sucesso'),
                backgroundColor: Colors.green,
              ),
            );
            _carregarAnuncios();
          }
        } else {
          throw Exception('Erro ao eliminar anúncio');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao eliminar anúncio: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _editarImovel(Map<String, dynamic> imovel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarImovelScreen(imovel: imovel),
      ),
    ).then((_) => _carregarAnuncios());
  }

  void _verDetalhes(Map<String, dynamic> imovel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DetalhesImovelSheet(imovel: imovel),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Gerenciar Anúncios',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _carregarAnuncios,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : _imoveis.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _carregarAnuncios,
              color: Colors.black,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _imoveis.length,
                itemBuilder: (context, index) {
                  final imovel = _imoveis[index];
                  return _buildImovelCard(imovel);
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.home_work_outlined,
              size: 64,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Nenhum anúncio encontrado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Crie seu primeiro anúncio',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildImovelCard(Map<String, dynamic> imovel) {
    final formatter = NumberFormat.currency(locale: 'pt_MZ', symbol: 'MZN');
    final preco = imovel['precoMzn'] != null
        ? formatter.format(imovel['precoMzn'])
        : 'N/A';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagem Principal
          if (imovel['imagemPrincipal'] != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
              child: Image.network(
                'http://localhost:8080${imovel['imagemPrincipal']}',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image_not_supported, size: 64),
                ),
              ),
            ),

          // Conteúdo
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Text(
                  imovel['titulo'] ?? 'Sem título',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Preço
                Text(
                  preco,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),

                // Categoria e Finalidade
                Row(
                  children: [
                    _buildChip(
                      imovel['categoria'] ?? 'N/A',
                      Icons.category_outlined,
                    ),
                    const SizedBox(width: 8),
                    _buildChip(
                      imovel['finalidade'] ?? 'N/A',
                      Icons.business_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Botões de Ação
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        label: 'Ver Detalhes',
                        icon: Icons.visibility_outlined,
                        onPressed: () => _verDetalhes(imovel),
                        backgroundColor: Colors.grey.shade100,
                        textColor: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildActionButton(
                        label: 'Editar',
                        icon: Icons.edit_outlined,
                        onPressed: () => _editarImovel(imovel),
                        backgroundColor: Colors.grey.shade100,
                        textColor: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildIconButton(
                      icon: Icons.delete_outline,
                      onPressed: () => _deletarImovel(imovel['id']),
                      color: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.black54),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: textColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}

// Sheet de Detalhes do Imóvel
class DetalhesImovelSheet extends StatelessWidget {
  final Map<String, dynamic> imovel;

  const DetalhesImovelSheet({Key? key, required this.imovel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Título
                  Text(
                    imovel['titulo'] ?? 'Sem título',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Descrição
                  _buildDetailSection(
                    'Descrição',
                    imovel['descricao'] ?? 'Sem descrição',
                    Icons.description_outlined,
                  ),

                  // Preço
                  _buildDetailSection(
                    'Preço',
                    NumberFormat.currency(
                      locale: 'pt_MZ',
                      symbol: 'MZN',
                    ).format(imovel['precoMzn'] ?? 0),
                    Icons.attach_money,
                  ),

                  // Categoria
                  _buildDetailSection(
                    'Categoria',
                    imovel['categoria'] ?? 'N/A',
                    Icons.category_outlined,
                  ),

                  // Finalidade
                  _buildDetailSection(
                    'Finalidade',
                    imovel['finalidade'] ?? 'N/A',
                    Icons.business_outlined,
                  ),

                  // Data de Criação
                  if (imovel['dataCriacao'] != null)
                    _buildDetailSection(
                      'Data de Criação',
                      DateFormat(
                        'dd/MM/yyyy HH:mm',
                      ).format(DateTime.parse(imovel['dataCriacao'])),
                      Icons.calendar_today_outlined,
                    ),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Fechar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailSection(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.black54),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

// Tela de Edição de Imóvel
class EditarImovelScreen extends StatefulWidget {
  final Map<String, dynamic> imovel;

  const EditarImovelScreen({Key? key, required this.imovel}) : super(key: key);

  @override
  State<EditarImovelScreen> createState() => _EditarImovelScreenState();
}

class _EditarImovelScreenState extends State<EditarImovelScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;

  // Controllers do Imóvel
  late TextEditingController _tituloController;
  late TextEditingController _descricaoController;
  late TextEditingController _precoController;
  late TextEditingController _areaController;
  late String _categoria;
  late String _finalidade;

  // Controllers de Localização
  late TextEditingController _paisController;
  late TextEditingController _provinciaController;
  late TextEditingController _cidadeController;
  late TextEditingController _bairroController;

  bool _isLoading = false;
  Map<String, dynamic>? _localizacao;
  List<Map<String, dynamic>> _documentos = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Inicializar dados do imóvel
    _tituloController = TextEditingController(text: widget.imovel['titulo']);
    _descricaoController = TextEditingController(
      text: widget.imovel['descricao'],
    );
    _precoController = TextEditingController(
      text: widget.imovel['precoMzn']?.toString(),
    );
    _areaController = TextEditingController(
      text: widget.imovel['area']?.toString() ?? '0',
    );

    // Função auxiliar para Title Case
    String toTitleCase(String text) {
      if (text.isEmpty) return text;
      return text[0].toUpperCase() + text.substring(1).toLowerCase();
    }

    // Normalizar categoria
    final categoriaFromBackend =
        widget.imovel['categoria']?.toString() ?? 'Apartamento';
    final categoriaNormalizada = toTitleCase(categoriaFromBackend);

    final categoriasValidas = [
      'Apartamento',
      'Casa',
      'Terreno',
      'Comercial',
      'Outro',
    ];
    _categoria = categoriasValidas.contains(categoriaNormalizada)
        ? categoriaNormalizada
        : 'Apartamento';

    // Normalizar finalidade (Banco exige UPPERCASE)
    final finalidadeFromBackend =
        widget.imovel['finalidade']?.toString().toUpperCase() ?? 'VENDA';

    final finalidadesValidas = ['VENDA', 'ARRENDAMENTO'];
    _finalidade = finalidadesValidas.contains(finalidadeFromBackend)
        ? finalidadeFromBackend
        : 'VENDA';

    // Inicializar controllers de localização
    _paisController = TextEditingController(text: 'Moçambique');
    _provinciaController = TextEditingController();
    _cidadeController = TextEditingController();
    _bairroController = TextEditingController();

    _carregarDadosAdicionais();
  }

  Future<void> _carregarDadosAdicionais() async {
    await _carregarLocalizacao();
    await _carregarDocumentos();
  }

  Future<void> _carregarLocalizacao() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://localhost:8080/api/imovel/buscar/${widget.imovel['id']}',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['imovel'] != null && data['imovel']['localizacao'] != null) {
          setState(() {
            _localizacao = data['imovel']['localizacao'];
            _paisController.text = _localizacao!['pais'] ?? 'Moçambique';
            _provinciaController.text = _localizacao!['provincia'] ?? '';
            _cidadeController.text = _localizacao!['cidade'] ?? '';
            _bairroController.text = _localizacao!['bairro'] ?? '';
          });
        }
      }
    } catch (e) {
      print('Erro ao carregar localização: $e');
    }
  }

  Future<void> _carregarDocumentos() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://localhost:8080/api/documento_imovel/imovel/${widget.imovel['id']}',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _documentos = data.map((e) => e as Map<String, dynamic>).toList();
        });
      }
    } catch (e) {
      print('Erro ao carregar documentos: $e');
    }
  }

  String _formatNumberForBackend(String value) {
    if (value.isEmpty) return '0';
    // Remove tudo que não for dígito, ponto ou vírgula
    String cleaned = value.replaceAll(RegExp(r'[^0-9.,]'), '');

    // Se tiver vírgula, assume que é decimal
    if (cleaned.contains(',')) {
      // Remove pontos de milhar (ex: 1.000,00 -> 1000,00)
      cleaned = cleaned.replaceAll('.', '');
      // Troca vírgula por ponto
      cleaned = cleaned.replaceAll(',', '.');
    }
    return cleaned;
  }

  Future<void> _atualizarImovel() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse(
          'http://localhost:8080/api/imovel/atualizar/${widget.imovel['id']}',
        ),
      );

      request.fields['titulo'] = _tituloController.text;
      request.fields['descricao'] = _descricaoController.text;

      // Formatar números para o formato aceito pelo backend (BigDecimal com ponto)
      request.fields['precoMzn'] = _formatNumberForBackend(
        _precoController.text,
      );
      request.fields['area'] = _formatNumberForBackend(_areaController.text);

      request.fields['categoria'] = _categoria;
      request.fields['finalidade'] = _finalidade;

      print('Enviando dados: ${request.fields}'); // Log para debug

      final response = await request.send();

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Imóvel atualizado com sucesso'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Erro ao atualizar imóvel');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _atualizarLocalizacao() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final localizacaoData = {
        'pais': _paisController.text,
        'provincia': _provinciaController.text,
        'cidade': _cidadeController.text,
        'bairro': _bairroController.text,
        'idImovel': widget.imovel['id'],
      };

      http.Response response;

      if (_localizacao != null && _localizacao!['id'] != null) {
        // Atualizar localização existente
        response = await http.put(
          Uri.parse(
            'http://localhost:8080/api/localizacao/atualizar/${_localizacao!['id']}',
          ),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(localizacaoData),
        );
      } else {
        // Criar nova localização
        response = await http.post(
          Uri.parse('http://localhost:8080/api/localizacao/criar'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(localizacaoData),
        );
      }

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Localização atualizada com sucesso'),
              backgroundColor: Colors.green,
            ),
          );
          await _carregarLocalizacao();
        }
      } else {
        throw Exception('Erro ao atualizar localização');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deletarDocumento(int idDocumento) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Eliminar Documento'),
        content: const Text('Tem certeza que deseja eliminar este documento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final response = await http.delete(
          Uri.parse(
            'http://localhost:8080/api/documento_imovel/deletar/$idDocumento',
          ),
        );

        if (response.statusCode == 200) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Documento eliminado com sucesso'),
                backgroundColor: Colors.green,
              ),
            );
            await _carregarDocumentos();
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao eliminar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tituloController.dispose();
    _descricaoController.dispose();
    _precoController.dispose();
    _areaController.dispose();
    _paisController.dispose();
    _provinciaController.dispose();
    _cidadeController.dispose();
    _bairroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Editar Anúncio',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.black,
          tabs: const [
            Tab(text: 'Imóvel'),
            Tab(text: 'Localização'),
            Tab(text: 'Documentos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildImovelTab(),
          _buildLocalizacaoTab(),
          _buildDocumentosTab(),
        ],
      ),
    );
  }

  Widget _buildImovelTab() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTextField(
            controller: _tituloController,
            label: 'Título',
            icon: Icons.title,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira um título';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _descricaoController,
            label: 'Descrição',
            icon: Icons.description_outlined,
            maxLines: 4,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira uma descrição';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _precoController,
            label: 'Preço (MZN)',
            icon: Icons.attach_money,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira um preço';
              }
              if (double.tryParse(value) == null) {
                return 'Por favor, insira um valor válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _areaController,
            label: 'Área (m²)',
            icon: Icons.square_foot,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira a área';
              }
              if (double.tryParse(value) == null) {
                return 'Por favor, insira um valor válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            label: 'Categoria',
            value: _categoria,
            icon: Icons.category_outlined,
            items: const [
              'Apartamento',
              'Casa',
              'Terreno',
              'Comercial',
              'Outro',
            ],
            onChanged: (value) {
              setState(() {
                _categoria = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            label: 'Finalidade',
            value: _finalidade,
            icon: Icons.business_outlined,
            items: const ['VENDA', 'ARRENDAMENTO'],
            onChanged: (value) {
              setState(() {
                _finalidade = value!;
              });
            },
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _atualizarImovel,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Salvar Alterações',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocalizacaoTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildTextField(
          controller: _paisController,
          label: 'País',
          icon: Icons.public,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _provinciaController,
          label: 'Província',
          icon: Icons.location_city,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _cidadeController,
          label: 'Cidade',
          icon: Icons.location_on_outlined,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _bairroController,
          label: 'Bairro',
          icon: Icons.home_outlined,
        ),
        const SizedBox(height: 32),
        SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _atualizarLocalizacao,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Salvar Localização',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentosTab() {
    return _documentos.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Nenhum documento cadastrado',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _documentos.length,
            itemBuilder: (context, index) {
              final doc = _documentos[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.description_outlined,
                      color: Colors.black87,
                    ),
                  ),
                  title: Text(
                    doc['tipoDocumento'] ?? 'Documento',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'ID: ${doc['id']}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _deletarDocumento(doc['id']),
                  ),
                ),
              );
            },
          );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.black54),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required IconData icon,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.black54),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(value: item, child: Text(item));
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
