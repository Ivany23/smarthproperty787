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
  int _currentStep = 0;
  bool _isLoading = false;
  bool _isAdvertiser = false;
  int? _anuncianteId;
  double _credits = 0.0;

  // Etapa 1: Dados do Imóvel
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _precoController = TextEditingController();
  final _areaController = TextEditingController();
  String _finalidade = 'VENDA';
  String _categoria = 'Casa';
  XFile? _imagemPrincipal;

  // Etapa 2: Localização
  final _paisController = TextEditingController(text: 'Moçambique');
  final _provinciaController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _bairroController = TextEditingController();

  // Etapa 3: Documento do Imóvel
  XFile? _documentoImovel;
  String _tipoDocumento = 'ESCRITURA';

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
        }
      }
    } catch (e) {
      print('Erro ao carregar créditos: $e');
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagemPrincipal = pickedFile;
      });
    }
  }

  Future<void> _pickDocument() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _documentoImovel = pickedFile;
      });
    }
  }

  Future<void> _submitStep() async {
    // Etapa 1: Validação Dados do Imóvel
    if (_currentStep == 0) {
      if (_tituloController.text.isEmpty ||
          _precoController.text.isEmpty ||
          _areaController.text.isEmpty) {
        _showError('Preencha Título, Preço e Área para continuar');
        return;
      }
      setState(() => _currentStep++);
    }
    // Etapa 2: Validação Localização
    else if (_currentStep == 1) {
      if (_provinciaController.text.isEmpty || _cidadeController.text.isEmpty) {
        _showError('Preencha Província e Cidade para continuar');
        return;
      }
      setState(() => _currentStep++);
    }
    // Etapa 3: Publicar Tudo
    else if (_currentStep == 2) {
      await _publishAll();
    }
  }

  Future<void> _publishAll() async {
    if (_anuncianteId == null) {
      _showError('Erro de sessão: Anunciante não identificado.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Criar Imóvel e obter ID
      final imovelId = await _createImovelAction();
      print('Imóvel criado com ID: $imovelId');

      // 2. Criar Localização
      await _createLocalizacaoAction(imovelId);
      print('Localização criada');

      // 3. Upload Documento (Opcional)
      if (_documentoImovel != null) {
        await _uploadDocumentoAction(imovelId);
        print('Documento enviado');
      }

      // 4. Criar Anúncio
      await _createAnuncioAction(imovelId);
      print('Anúncio criado');

      _showSuccess('Propriedade publicada com sucesso! 50 créditos debitados.');
      Navigator.pop(context);
    } catch (e) {
      print('Erro no fluxo de publicação: $e');
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<int> _createImovelAction() async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:8080/api/imovel/criar'),
    );

    request.fields['titulo'] = _tituloController.text;
    request.fields['descricao'] = _descricaoController.text;
    request.fields['precoMzn'] = _precoController.text
        .replaceAll(',', '.')
        .replaceAll(' ', '');
    request.fields['area'] = _areaController.text
        .replaceAll(',', '.')
        .replaceAll(' ', '');
    request.fields['finalidade'] = _finalidade;
    request.fields['categoria'] = _categoria;
    request.fields['idAnunciante'] = _anuncianteId.toString();

    if (_imagemPrincipal != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'imagemPrincipal',
          await _imagemPrincipal!.readAsBytes(),
          filename: _imagemPrincipal!.name,
          contentType: MediaType(
            'image',
            _getImageExtension(_imagemPrincipal!.name),
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

  Future<void> _createLocalizacaoAction(int imovelId) async {
    final response = await http.post(
      Uri.parse('http://localhost:8080/api/localizacao/criar'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'pais': _paisController.text,
        'provincia': _provinciaController.text,
        'cidade': _cidadeController.text,
        'bairro': _bairroController.text,
        'idImovel': imovelId,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(data['error'] ?? 'Erro ao criar localização');
    }
  }

  Future<void> _uploadDocumentoAction(int imovelId) async {
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

  Future<void> _createAnuncioAction(int imovelId) async {
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
    // Mapear extensões para subtipos MIME corretos
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
        return 'jpeg'; // fallback
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Publicar Propriedade',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Créditos disponíveis
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Créditos: ${_credits.toStringAsFixed(0)} | Custo: 50',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Stepper
          Expanded(
            child: Stepper(
              currentStep: _currentStep,
              onStepContinue: _isLoading ? null : _submitStep,
              onStepCancel: _currentStep > 0
                  ? () => setState(() => _currentStep--)
                  : null,
              controlsBuilder: (context, details) {
                return Row(
                  children: [
                    ElevatedButton(
                      onPressed: _isLoading ? null : details.onStepContinue,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_currentStep == 2 ? 'Publicar' : 'Continuar'),
                    ),
                    if (_currentStep > 0) ...[
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: details.onStepCancel,
                        child: const Text('Voltar'),
                      ),
                    ],
                  ],
                );
              },
              steps: [_buildStep1(), _buildStep2(), _buildStep3()],
            ),
          ),
        ],
      ),
    );
  }

  Step _buildStep1() {
    return Step(
      title: const Text('Dados do Imóvel'),
      content: Column(
        children: [
          TextField(
            controller: _tituloController,
            decoration: const InputDecoration(
              labelText: 'Título *',
              prefixIcon: Icon(Icons.title, color: Colors.black),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descricaoController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Descrição',
              prefixIcon: Icon(Icons.description, color: Colors.black),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _precoController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Preço (MZN) *',
              prefixIcon: Icon(Icons.attach_money, color: Colors.black),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _areaController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Área (m²) *',
              prefixIcon: Icon(Icons.square_foot, color: Colors.black),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _finalidade,
            decoration: const InputDecoration(
              labelText: 'Finalidade',
              prefixIcon: Icon(Icons.business_center, color: Colors.black),
              border: OutlineInputBorder(),
            ),
            items: ['VENDA', 'ARRENDAMENTO'].map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            onChanged: (value) => setState(() => _finalidade = value!),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _categoria,
            decoration: const InputDecoration(
              labelText: 'Categoria',
              prefixIcon: Icon(Icons.home, color: Colors.black),
              border: OutlineInputBorder(),
            ),
            items: ['Casa', 'Apartamento', 'Terreno', 'Comercial'].map((
              String value,
            ) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            onChanged: (value) => setState(() => _categoria = value!),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.image, color: Colors.black),
            label: Text(
              _imagemPrincipal == null
                  ? 'Adicionar Imagem'
                  : 'Imagem Selecionada',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
      isActive: _currentStep >= 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildStep2() {
    return Step(
      title: const Text('Localização'),
      content: Column(
        children: [
          TextField(
            controller: _paisController,
            decoration: const InputDecoration(
              labelText: 'País',
              prefixIcon: Icon(Icons.public, color: Colors.black),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _provinciaController,
            decoration: const InputDecoration(
              labelText: 'Província *',
              prefixIcon: Icon(Icons.location_city, color: Colors.black),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _cidadeController,
            decoration: const InputDecoration(
              labelText: 'Cidade *',
              prefixIcon: Icon(Icons.location_on, color: Colors.black),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bairroController,
            decoration: const InputDecoration(
              labelText: 'Bairro',
              prefixIcon: Icon(Icons.place, color: Colors.black),
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      isActive: _currentStep >= 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildStep3() {
    return Step(
      title: const Text('Documento (Opcional)'),
      content: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _tipoDocumento,
            decoration: const InputDecoration(
              labelText: 'Tipo de Documento',
              prefixIcon: Icon(Icons.description, color: Colors.black),
              border: OutlineInputBorder(),
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
                  // Exibir nome amigável mas enviar valor do enum
                  String displayName = value;
                  if (value == 'CERTIDAO_DE_REGISTO_PREDIAL') {
                    displayName = 'Certidão de Registo Predial';
                  } else if (value == 'LICENCA_DE_CONSTRUCAO') {
                    displayName = 'Licença de Construção';
                  } else if (value == 'PLANTA_CROQUIS') {
                    displayName = 'Planta/Croquis';
                  } else {
                    displayName = value;
                  }
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(displayName),
                  );
                }).toList(),
            onChanged: (value) => setState(() => _tipoDocumento = value!),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _pickDocument,
            icon: const Icon(Icons.upload_file, color: Colors.black),
            label: Text(
              _documentoImovel == null
                  ? 'Adicionar Documento'
                  : 'Documento Selecionado',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'O documento é opcional. Clique em "Publicar" para finalizar.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      isActive: _currentStep >= 2,
      state: StepState.indexed,
    );
  }

  @override
  void dispose() {
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
}
