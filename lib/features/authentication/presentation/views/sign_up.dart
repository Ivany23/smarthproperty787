
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:html' as html; // Importa a biblioteca para aceder à URL do navegador

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Função para construir a URL da API dinamicamente
  String _getApiUrl() {
    final uri = Uri.parse(html.window.location.href);
    // Usa o mesmo hostname da página atual, mas força a porta 8080 para o backend
    return '${uri.scheme}://${uri.host.replaceAll(uri.port.toString(), '8080')}/api/auth/register';
  }

  Future<void> _signUp() async {
      if (!_formKey.currentState!.validate()) {
      return;
    }

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );
  
      try {
        final String apiUrl = _getApiUrl(); // Usa a função para obter a URL dinâmica
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'nomeCompleto': _nameController.text,
            'email': _emailController.text,
            'telefone': _phoneController.text,
            'senha': _passwordController.text, 
          }),
        );
  
        if (!mounted) return;
        Navigator.pop(context); // Fecha o loading indicator
  
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registro realizado com sucesso!')),
          );
          // TODO: Navegar para a tela de login ou dashboard
        } else {
          final responseBody = jsonDecode(response.body);
          final errorMessage = responseBody['error'] ?? 'Ocorreu um erro desconhecido.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro no registro: $errorMessage')),
          );
        }
      } catch (e) {
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível conectar ao servidor: $e')),
        );
      }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Conta')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome Completo'),
                validator: (value) => value!.isEmpty ? 'Por favor, insira o seu nome' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'E-mail'),
                 validator: (value) => value!.isEmpty || !value.contains('@') ? 'Insira um e-mail válido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Telefone'),
                 validator: (value) => value!.isEmpty ? 'Por favor, insira o seu telefone' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
                 validator: (value) => value!.length < 6 ? 'A senha deve ter no mínimo 6 caracteres' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _signUp,
                child: const Text('Registrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

