import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/constants/assets.dart';
import 'package:flutter_application_1/core/constants/colors.dart';
import 'package:flutter_application_1/features/profile/presentation/views/verify_profile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class IdentityVerificationScreen extends StatefulWidget {
  const IdentityVerificationScreen({super.key});

  @override
  State<IdentityVerificationScreen> createState() =>
      _IdentityVerificationScreenState();
}

class _IdentityVerificationScreenState
    extends State<IdentityVerificationScreen> {
  bool _isLoading = true;
  bool _isVerified = false;
  bool _isAdvertiser = false;
  List<dynamic> _documents = [];
  int? _anuncianteId;

  @override
  void initState() {
    super.initState();
    _loadVerificationStatus();
  }

  Future<void> _loadVerificationStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final visitorId = prefs.getInt('visitorId');

      if (visitorId == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final advertiserResponse = await http.get(
        Uri.parse('http://localhost:8080/api/anunciante/visitante/$visitorId'),
      );

      if (advertiserResponse.statusCode == 200) {
        final advertiserData = jsonDecode(advertiserResponse.body);
        _anuncianteId = advertiserData['id'];
        _isAdvertiser = true;

        final docsResponse = await http.get(
          Uri.parse(
            'http://localhost:8080/api/documentos-verificacao/anunciante/$_anuncianteId',
          ),
        );

        if (docsResponse.statusCode == 200) {
          final docs = jsonDecode(docsResponse.body) as List;
          setState(() {
            _documents = docs;
            _isVerified =
                docs.isNotEmpty && docs.any((doc) => doc['verificado'] == true);
          });
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar status de verificação: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteDocument(int docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Deseja realmente deletar este documento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await http.delete(
        Uri.parse(
          'http://localhost:8080/api/documentos-verificacao/remover/$docId',
        ),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Documento deletado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadVerificationStatus();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao deletar documento'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Erro ao deletar documento: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao deletar documento'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Verificação de Identidade',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: _isVerified
                            ? Colors.green.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isVerified ? Colors.green : Colors.grey,
                          width: 3,
                        ),
                      ),
                      child: Icon(
                        _isVerified ? Icons.verified : Icons.verified_user,
                        size: 60,
                        color: _isVerified ? Colors.green : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      _isVerified
                          ? 'Identidade Verificada'
                          : 'Verificar Identidade',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _isVerified
                          ? 'Sua identidade foi verificada com sucesso!'
                          : _isAdvertiser
                          ? 'Envie seus documentos para verificação'
                          : 'Torne-se anunciante para verificar sua identidade',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 40),
                    if (_isAdvertiser && _documents.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Documentos Enviados',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ..._documents.map((doc) {
                              final isVerified = doc['verificado'] == true;
                              final docId = doc['id'];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12.0),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isVerified
                                        ? Colors.green.withOpacity(0.3)
                                        : Colors.orange.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isVerified
                                          ? Icons.check_circle
                                          : Icons.pending,
                                      color: isVerified
                                          ? Colors.green
                                          : Colors.orange,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            doc['tipoDocumento'] ?? 'Documento',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            isVerified
                                                ? 'Verificado'
                                                : 'Pendente',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      onPressed: () => _deleteDocument(docId),
                                      tooltip: 'Deletar',
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    if (_isAdvertiser)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const VerifyProfile(),
                              ),
                            );
                            _loadVerificationStatus();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF333333),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                AppIcons.shield,
                                width: 24,
                                height: 24,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _documents.isEmpty
                                    ? 'Enviar Documentos'
                                    : 'Adicionar Mais Documentos',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
