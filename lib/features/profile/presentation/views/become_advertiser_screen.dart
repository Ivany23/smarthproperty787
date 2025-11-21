import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BecomeAdvertiserScreen extends StatefulWidget {
  const BecomeAdvertiserScreen({super.key});

  @override
  State<BecomeAdvertiserScreen> createState() => _BecomeAdvertiserScreenState();
}

class _BecomeAdvertiserScreenState extends State<BecomeAdvertiserScreen> {
  final _valorController = TextEditingController(text: '500');
  String _metodoPagamento = 'MPESA';
  bool _loading = false;

  @override
  void dispose() {
    _valorController.dispose();
    super.dispose();
  }

  Future<void> _processarPagamento() async {
    final prefs = await SharedPreferences.getInstance();
    final visitorId = prefs.getInt('visitorId');

    if (visitorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro: ID do visitante não encontrado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/api/pagamentos/processar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'visitanteId': visitorId,
          'valor': double.parse(_valorController.text),
          'metodoPagamento': _metodoPagamento,
        }),
      );

      setState(() => _loading = false);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Salvar anuncianteId
        if (data['anunciante'] != null && data['anunciante']['id'] != null) {
          await prefs.setInt('anuncianteId', data['anunciante']['id']);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '✅ Pagamento processado! Você agora é um anunciante!',
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
          Navigator.pop(context, true); // Retorna true para atualizar o perfil
        }
      } else {
        final error = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro: ${error['error'] ?? 'Erro desconhecido'}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao processar pagamento: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFF2C3E50),
        title: const Text(
          'Tornar-se Anunciante',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Ícone
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Color(0xFF2C3E50).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_add,
                      size: 50,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Título
                  const Text(
                    'Torne-se um Anunciante',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Descrição
                  Text(
                    'Anuncie suas propriedades e alcance milhares de potenciais compradores',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),

                  // Benefícios
                  _buildBenefit('✅ Publique imóveis ilimitados'),
                  _buildBenefit('✅ Destaque seus anúncios'),
                  _buildBenefit('✅ Receba contatos diretos'),
                  _buildBenefit('✅ Painel de controle completo'),
                  const SizedBox(height: 32),

                  // Valor
                  TextField(
                    controller: _valorController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Valor (MT)',
                      prefixIcon: const Icon(Icons.attach_money),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Método de Pagamento
                  DropdownButtonFormField<String>(
                    value: _metodoPagamento,
                    decoration: InputDecoration(
                      labelText: 'Método de Pagamento',
                      prefixIcon: const Icon(Icons.payment),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'MPESA', child: Text('M-PESA')),
                      DropdownMenuItem(value: 'EMOLA', child: Text('E-MOLA')),
                      DropdownMenuItem(value: 'CARTAO', child: Text('Cartão')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _metodoPagamento = value);
                      }
                    },
                  ),
                  const SizedBox(height: 32),

                  // Botão de Pagamento
                  ElevatedButton(
                    onPressed: _processarPagamento,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2C3E50),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Processar Pagamento',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildBenefit(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
