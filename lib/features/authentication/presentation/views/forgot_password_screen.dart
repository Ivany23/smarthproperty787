import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_application_1/core/constants/colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _novaSenhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController =
      TextEditingController();

  bool _isLoading = false;
  int _currentStep = 0; // 0: Email, 1: Código exibido, 2: Nova Senha
  String _codigoVerificacao = '';

  Future<void> _solicitarCodigo() async {
    if (_emailController.text.isEmpty) {
      _showMessage('Por favor, insira seu email');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/api/auth/solicitar-codigo'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': _emailController.text}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _codigoVerificacao = data['codigoVerificacao'];
          _currentStep = 1;
        });
        _showMessage('Código de verificação encontrado!');
      } else {
        final errorData = json.decode(response.body);
        _showMessage(errorData['error'] ?? 'Email não encontrado');
      }
    } catch (e) {
      _showMessage('Erro ao conectar com o servidor');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _validarCodigo() async {
    if (_codigoController.text.isEmpty) {
      _showMessage('Por favor, insira o código');
      return;
    }

    if (_codigoController.text != _codigoVerificacao) {
      _showMessage('Código inválido');
      return;
    }

    setState(() => _currentStep = 2);
    _showMessage('Código validado! Defina sua nova senha');
  }

  Future<void> _redefinirSenha() async {
    if (_novaSenhaController.text.isEmpty ||
        _confirmarSenhaController.text.isEmpty) {
      _showMessage('Por favor, preencha todos os campos');
      return;
    }

    if (_novaSenhaController.text != _confirmarSenhaController.text) {
      _showMessage('As senhas não coincidem');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/api/auth/recuperar-senha'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _emailController.text,
          'codigoVerificacao': _codigoController.text,
          'novaSenha': _novaSenhaController.text,
        }),
      );

      if (response.statusCode == 200) {
        _showMessage('Senha redefinida com sucesso!');
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        final errorData = json.decode(response.body);
        _showMessage(errorData['error'] ?? 'Erro ao redefinir senha');
      }
    } catch (e) {
      _showMessage('Erro ao conectar com o servidor');
    }

    setState(() => _isLoading = false);
  }

  void _copiarCodigo() {
    Clipboard.setData(ClipboardData(text: _codigoVerificacao));
    _showMessage('Código copiado!');
  }

  void _showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF830BD1), Color(0xFF6200B3)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  // Ícone
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _currentStep == 0
                          ? Icons.lock_reset
                          : _currentStep == 1
                          ? Icons.verified_user
                          : Icons.lock_open,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Título
                  Text(
                    _currentStep == 0
                        ? 'Recuperar senha'
                        : _currentStep == 1
                        ? 'Código de verificação'
                        : 'Nova senha',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtítulo
                  Text(
                    _currentStep == 0
                        ? 'Insira seu email para obter o código'
                        : _currentStep == 1
                        ? 'Copie o código abaixo e cole no campo'
                        : 'Defina sua nova senha',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Conteúdo baseado na etapa
                  if (_currentStep == 0) ...[
                    // Etapa 1: Email
                    _buildTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ] else if (_currentStep == 1) ...[
                    // Etapa 2: Exibir código e campo para inserir
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Seu código de verificação:',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _codigoVerificacao,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 4,
                                ),
                              ),
                              const SizedBox(width: 16),
                              IconButton(
                                onPressed: _copiarCodigo,
                                icon: const Icon(
                                  Icons.copy,
                                  color: Colors.white,
                                ),
                                tooltip: 'Copiar código',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(
                      controller: _codigoController,
                      hintText: 'Cole o código aqui',
                      icon: Icons.vpn_key,
                      keyboardType: TextInputType.text,
                    ),
                  ] else ...[
                    // Etapa 3: Nova senha
                    _buildTextField(
                      controller: _novaSenhaController,
                      hintText: 'Nova senha',
                      icon: Icons.lock,
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _confirmarSenhaController,
                      hintText: 'Confirmar nova senha',
                      icon: Icons.lock_outline,
                      obscureText: true,
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Botão de ação
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              if (_currentStep == 0) {
                                _solicitarCodigo();
                              } else if (_currentStep == 1) {
                                _validarCodigo();
                              } else {
                                _redefinirSenha();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : Text(
                              _currentStep == 0
                                  ? 'Obter código'
                                  : _currentStep == 1
                                  ? 'Validar código'
                                  : 'Redefinir senha',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Link para voltar
                  TextButton(
                    onPressed: () {
                      if (_currentStep > 0) {
                        setState(() => _currentStep--);
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.arrow_back,
                          color: Colors.white.withValues(alpha: 0.8),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _currentStep > 0 ? 'Voltar' : 'Voltar para login',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
          prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.8)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        obscureText: obscureText,
        keyboardType: keyboardType,
      ),
    );
  }
}
