import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class PublishProperty extends StatefulWidget {
  const PublishProperty({super.key});

  @override
  State<PublishProperty> createState() => _PublishPropertyState();
}

class _PublishPropertyState extends State<PublishProperty> {
  bool _isAdvertiser = false;
  int? _anuncianteId;
  double _credits = 0.0;

  @override
  void initState() {
    super.initState();
    _checkAdvertiserStatus();
  }

  Future<void> _checkAdvertiserStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final visitorId = prefs.getInt('visitorId');

    if (visitorId == null) {
      _showError('Você precisa estar logado');
      Navigator.pop(context);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/anunciante/visitante/$visitorId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _isAdvertiser = true;
          _anuncianteId = data['id'];
        });
        await _loadCredits();
      } else {
        _showError('Apenas anunciantes podem publicar propriedades');
        Navigator.pop(context);
      }
    } catch (e) {
      _showError('Erro ao verificar status: $e');
      Navigator.pop(context);
    }
  }

  Future<void> _loadCredits() async {
    if (_anuncianteId == null) return;

    try {
      final response = await http.get(
        Uri.parse(
          'http://localhost:8080/api/creditos/anunciante/$_anuncianteId',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _credits = (data['saldo_creditos'] ?? 0).toDouble();
        });

        if (_credits < 50) {
          _showError(
            'Créditos insuficientes. Necessário: 50, Disponível: ${_credits.toStringAsFixed(0)}',
          );
          Navigator.pop(context);
        } else {
          // Navegar para a primeira tela
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PublishStep1Screen(
                anuncianteId: _anuncianteId!,
                credits: _credits,
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('Erro ao carregar créditos: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator(color: Colors.black87)),
    );
  }
}

class PublishStep1Screen extends StatefulWidget {
  final int anuncianteId;
  final double credits;

  const PublishStep1Screen({
    super.key,
    required this.anuncianteId,
    required this.credits,
  });

  @override
  State<PublishStep1Screen> createState() => _PublishStep1ScreenState();
}

class _PublishStep1ScreenState extends State<PublishStep1Screen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _precoController = TextEditingController();
  final _areaController = TextEditingController();
  String _finalidade = 'VENDA';
  String _categoria = 'Casa';
  XFile? _imagemPrincipal;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagemPrincipal = pickedFile;
      });
    }
  }

  void _continuar() {
    if (!_formKey.currentState!.validate()) return;

    if (_tituloController.text.isEmpty ||
        _precoController.text.isEmpty ||
        _areaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha todos os campos obrigatórios'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PublishStep2Screen(
          anuncianteId: widget.anuncianteId,
          credits: widget.credits,
          titulo: _tituloController.text,
          descricao: _descricaoController.text,
          preco: _precoController.text,
          area: _areaController.text,
          finalidade: _finalidade,
          categoria: _categoria,
          imagemPrincipal: _imagemPrincipal,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Dados do Imóvel',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card de créditos
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.purple.shade50, Colors.blue.shade50],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.purple.shade100),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.account_balance_wallet,
                              color: Colors.purple.shade600,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Saldo Disponível',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${widget.credits.toStringAsFixed(0)} créditos',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 14,
                                  color: Colors.orange.shade700,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Custo: 50',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Campos do formulário
                    _buildTextField(
                      controller: _tituloController,
                      label: 'Título *',
                      icon: Icons.title,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Campo obrigatório';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _descricaoController,
                      label: 'Descrição',
                      icon: Icons.description,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _precoController,
                      label: 'Preço (MZN) *',
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Campo obrigatório';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _areaController,
                      label: 'Área (m²) *',
                      icon: Icons.square_foot,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Campo obrigatório';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown(
                      label: 'Finalidade',
                      value: _finalidade,
                      icon: Icons.business_center,
                      items: const ['VENDA', 'ARRENDAMENTO'],
                      onChanged: (value) =>
                          setState(() => _finalidade = value!),
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown(
                      label: 'Categoria',
                      value: _categoria,
                      icon: Icons.home,
                      items: const [
                        'Casa',
                        'Apartamento',
                        'Terreno',
                        'Comercial',
                      ],
                      onChanged: (value) => setState(() => _categoria = value!),
                    ),
                    const SizedBox(height: 24),
                    _buildImagePicker(),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _continuar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Continuar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.black87),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black87, width: 2),
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
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.black87),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black87, width: 2),
        ),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildImagePicker() {
    return InkWell(
      onTap: _pickImage,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _imagemPrincipal != null
                ? Colors.green.shade300
                : Colors.grey.shade300,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(
              _imagemPrincipal != null
                  ? Icons.check_circle
                  : Icons.add_photo_alternate,
              size: 48,
              color: _imagemPrincipal != null ? Colors.green : Colors.grey,
            ),
            const SizedBox(height: 12),
            Text(
              _imagemPrincipal != null
                  ? 'Imagem Selecionada'
                  : 'Adicionar Imagem Principal',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _imagemPrincipal != null ? Colors.green : Colors.black87,
              ),
            ),
            if (_imagemPrincipal != null) ...[
              const SizedBox(height: 4),
              Text(
                _imagemPrincipal!.name,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _precoController.dispose();
    _areaController.dispose();
    super.dispose();
  }
}

class PublishStep2Screen extends StatefulWidget {
  final int anuncianteId;
  final double credits;
  final String titulo;
  final String descricao;
  final String preco;
  final String area;
  final String finalidade;
  final String categoria;
  final XFile? imagemPrincipal;

  const PublishStep2Screen({
    super.key,
    required this.anuncianteId,
    required this.credits,
    required this.titulo,
    required this.descricao,
    required this.preco,
    required this.area,
    required this.finalidade,
    required this.categoria,
    this.imagemPrincipal,
  });

  @override
  State<PublishStep2Screen> createState() => _PublishStep2ScreenState();
}

class _PublishStep2ScreenState extends State<PublishStep2Screen> {
  final _formKey = GlobalKey<FormState>();
  final _paisController = TextEditingController(text: 'Moçambique');
  final _provinciaController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _bairroController = TextEditingController();

  void _continuar() {
    if (!_formKey.currentState!.validate()) return;

    if (_provinciaController.text.isEmpty || _cidadeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha Província e Cidade'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PublishStep3Screen(
          anuncianteId: widget.anuncianteId,
          credits: widget.credits,
          titulo: widget.titulo,
          descricao: widget.descricao,
          preco: widget.preco,
          area: widget.area,
          finalidade: widget.finalidade,
          categoria: widget.categoria,
          imagemPrincipal: widget.imagemPrincipal,
          pais: _paisController.text,
          provincia: _provinciaController.text,
          cidade: _cidadeController.text,
          bairro: _bairroController.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Localização',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _paisController,
                      label: 'País',
                      icon: Icons.public,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _provinciaController,
                      label: 'Província *',
                      icon: Icons.location_city,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Campo obrigatório';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _cidadeController,
                      label: 'Cidade *',
                      icon: Icons.location_on,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Campo obrigatório';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _bairroController,
                      label: 'Bairro',
                      icon: Icons.place,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _continuar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Continuar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.black87),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black87, width: 2),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _paisController.dispose();
    _provinciaController.dispose();
    _cidadeController.dispose();
    _bairroController.dispose();
    super.dispose();
  }
}

class PublishStep3Screen extends StatefulWidget {
  final int anuncianteId;
  final double credits;
  final String titulo;
  final String descricao;
  final String preco;
  final String area;
  final String finalidade;
  final String categoria;
  final XFile? imagemPrincipal;
  final String pais;
  final String provincia;
  final String cidade;
  final String bairro;

  const PublishStep3Screen({
    super.key,
    required this.anuncianteId,
    required this.credits,
    required this.titulo,
    required this.descricao,
    required this.preco,
    required this.area,
    required this.finalidade,
    required this.categoria,
    this.imagemPrincipal,
    required this.pais,
    required this.provincia,
    required this.cidade,
    required this.bairro,
  });

  @override
  State<PublishStep3Screen> createState() => _PublishStep3ScreenState();
}

class _PublishStep3ScreenState extends State<PublishStep3Screen> {
  XFile? _documentoImovel;
  String _tipoDocumento = 'ESCRITURA';
  bool _isLoading = false;

  Future<void> _pickDocument() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _documentoImovel = pickedFile;
      });
    }
  }

  Future<void> _publicar() async {
    setState(() => _isLoading = true);

    try {
      // 1. Criar Imóvel
      final imovelId = await _createImovel();
      print('Imóvel criado com ID: $imovelId');

      // 2. Criar Localização
      await _createLocalizacao(imovelId);
      print('Localização criada');

      // 3. Upload Documento (Desabilitado temporariamente devido a constraint do banco)
      // if (_documentoImovel != null) {
      //   await _uploadDocumento(imovelId);
      //   print('Documento enviado');
      // }

      // 4. Criar Anúncio
      await _createAnuncio(imovelId);
      print('Anúncio criado');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Propriedade publicada com sucesso! 50 créditos debitados.',
            ),
            backgroundColor: Colors.green,
          ),
        );
        // Voltar para a tela inicial
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      print('Erro no fluxo de publicação: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<int> _createImovel() async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:8080/api/imovel/criar'),
    );

    request.fields['titulo'] = widget.titulo;
    request.fields['descricao'] = widget.descricao;
    request.fields['precoMzn'] = widget.preco
        .replaceAll(',', '.')
        .replaceAll(' ', '');
    request.fields['area'] = widget.area
        .replaceAll(',', '.')
        .replaceAll(' ', '');
    request.fields['finalidade'] = widget.finalidade;
    request.fields['categoria'] = widget.categoria;
    request.fields['idAnunciante'] = widget.anuncianteId.toString();

    if (widget.imagemPrincipal != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'imagemPrincipal',
          await widget.imagemPrincipal!.readAsBytes(),
          filename: widget.imagemPrincipal!.name,
          contentType: MediaType(
            'image',
            _getImageExtension(widget.imagemPrincipal!.name),
          ),
        ),
      );
    }

    final response = await request.send();
    final responseData = await response.stream.bytesToString();
    final data = jsonDecode(responseData);

    if (response.statusCode == 200 && data['success'] == true) {
      return data['imovel']['id'];
    } else {
      throw Exception(data['error'] ?? 'Erro ao criar imóvel');
    }
  }

  Future<void> _createLocalizacao(int imovelId) async {
    final response = await http.post(
      Uri.parse('http://localhost:8080/api/localizacao/criar'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'pais': widget.pais,
        'provincia': widget.provincia,
        'cidade': widget.cidade,
        'bairro': widget.bairro,
        'idImovel': imovelId,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(data['error'] ?? 'Erro ao criar localização');
    }
  }

  Future<void> _uploadDocumento(int imovelId) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:8080/api/documento_imovel/criar'),
    );

    request.fields['idImovel'] = imovelId.toString();
    request.fields['tipoDocumento'] = _tipoDocumento;

    request.files.add(
      http.MultipartFile.fromBytes(
        'documento',
        await _documentoImovel!.readAsBytes(),
        filename: _documentoImovel!.name,
        contentType: MediaType(
          'image',
          _getImageExtension(_documentoImovel!.name),
        ),
      ),
    );

    final response = await request.send();

    if (response.statusCode != 200) {
      final responseData = await response.stream.bytesToString();
      final data = jsonDecode(responseData);
      throw Exception(data['error'] ?? 'Erro ao fazer upload do documento');
    }
  }

  Future<void> _createAnuncio(int imovelId) async {
    final response = await http.post(
      Uri.parse('http://localhost:8080/api/anuncio/criar?idImovel=$imovelId'),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(data['error'] ?? 'Erro ao criar anúncio');
    }
  }

  String _getImageExtension(String filename) {
    final extension = filename.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'jpeg';
      case 'png':
        return 'png';
      case 'gif':
        return 'gif';
      case 'bmp':
        return 'bmp';
      case 'webp':
        return 'webp';
      default:
        return 'jpeg';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Documento (Opcional)',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildDropdown(),
                  const SizedBox(height: 24),
                  _buildDocumentPicker(),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'O documento é opcional. Você pode publicar sem ele.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _publicar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Publicar Propriedade',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _tipoDocumento,
      decoration: InputDecoration(
        labelText: 'Tipo de Documento',
        prefixIcon: const Icon(Icons.description, color: Colors.black87),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black87, width: 2),
        ),
      ),
      items:
          [
            'ESCRITURA',
            'CERTIDAO_DE_REGISTO_PREDIAL',
            'LICENCA_DE_CONSTRUCAO',
            'PLANTA_CROQUIS',
            'BI',
            'NUIT',
            'DUAT',
            'OUTRO',
          ].map((String value) {
            String displayName = value;
            if (value == 'CERTIDAO_DE_REGISTO_PREDIAL') {
              displayName = 'Certidão de Registo Predial';
            } else if (value == 'LICENCA_DE_CONSTRUCAO') {
              displayName = 'Licença de Construção';
            } else if (value == 'PLANTA_CROQUIS') {
              displayName = 'Planta/Croquis';
            }
            return DropdownMenuItem<String>(
              value: value,
              child: Text(displayName),
            );
          }).toList(),
      onChanged: (value) => setState(() => _tipoDocumento = value!),
    );
  }

  Widget _buildDocumentPicker() {
    return InkWell(
      onTap: _pickDocument,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _documentoImovel != null
                ? Colors.green.shade300
                : Colors.grey.shade300,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(
              _documentoImovel != null ? Icons.check_circle : Icons.upload_file,
              size: 48,
              color: _documentoImovel != null ? Colors.green : Colors.grey,
            ),
            const SizedBox(height: 12),
            Text(
              _documentoImovel != null
                  ? 'Documento Selecionado'
                  : 'Adicionar Documento',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _documentoImovel != null ? Colors.green : Colors.black87,
              ),
            ),
            if (_documentoImovel != null) ...[
              const SizedBox(height: 4),
              Text(
                _documentoImovel!.name,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
