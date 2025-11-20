import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/constants/assets.dart';
import 'package:flutter_application_1/core/constants/colors.dart';
import 'package:flutter_application_1/core/shared/widgets/custom_button.dart';
import 'package:flutter_application_1/core/shared/widgets/custom_input.dart';
import 'package:flutter_application_1/features/authentication/presentation/views/sign_up.dart';
import 'package:flutter_application_1/wrapper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  Future<void> _signIn() async {
    print('Sign in button pressed');
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      const String apiUrl = "http://localhost:8080/api/auth/login";
      print('Making request to $apiUrl');
      print('Email: ${_emailController.text}');
      print('Password: ${_passwordController.text}');
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(<String, String>{
          'email': _emailController.text,
          'senha': _passwordController.text,
        }),
      );

      print('Response received - status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (!mounted) return;
      Navigator.pop(context);

      print('Checking if status code is 200...');
      if (response.statusCode == 200) {
        print('✅ Login successful! Processing response data...');
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('Parsed login data: $data');
        final int visitanteId = data['visitanteId'];

        // Fetch visitor details to get name
        print(
          '📞 Fetching visitor details from /api/visitante/buscar/$visitanteId',
        );
        final visitorResponse = await http.get(
          Uri.parse('http://localhost:8080/api/visitante/buscar/$visitanteId'),
        );

        String visitorName = 'Visitante';
        if (visitorResponse.statusCode == 200) {
          final visitorData = jsonDecode(visitorResponse.body);
          print('Visitor data received: $visitorData');
          visitorName = visitorData['nomeCompleto'] ?? 'Visitante';
        }

        // Check if visitor is an advertiser
        print(
          '📞 Checking if visitor is advertiser from /api/anunciante/visitante/$visitanteId',
        );
        final advertiserResponse = await http.get(
          Uri.parse(
            'http://localhost:8080/api/anunciante/visitante/$visitanteId',
          ),
        );

        bool isAdvertiser = false;
        int? anuncianteId;
        if (advertiserResponse.statusCode == 200) {
          final advertiserData = jsonDecode(advertiserResponse.body);
          print('Advertiser data received: $advertiserData');
          isAdvertiser = true;
          anuncianteId = advertiserData['id'];
        } else {
          print('Not an advertiser (status: ${advertiserResponse.statusCode})');
        }

        // Save all data to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('visitorId', visitanteId);
        await prefs.setString('visitorName', visitorName);
        await prefs.setBool('isAdvertiser', isAdvertiser);
        if (isAdvertiser && anuncianteId != null) {
          await prefs.setInt('anuncianteId', anuncianteId);
        }
        await prefs.setBool('isLoggedIn', true);
        print('✅ Saved to SharedPreferences:');
        print('   - visitorId: $visitanteId');
        print('   - visitorName: $visitorName');
        print('   - isAdvertiser: $isAdvertiser');
        if (isAdvertiser) print('   - anuncianteId: $anuncianteId');

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bem-vindo, $visitorName!'),
            backgroundColor: Colors.green,
          ),
        );
        if (!mounted) return;
        print('🚀 Navigating to Wrapper...');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Wrapper()),
        );
        print('Navigation to Wrapper completed');
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Falha no login. Código: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ocorreu um erro: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.05),
              Colors.white,
              AppColors.primary.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  // Título moderno
                  Text(
                    "Bem-vindo",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Entre na sua conta",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 50),
                  // Card com sombra para os inputs
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        CustomInput(
                          controller: _emailController,
                          iconUri: AppIcons.email,
                          label: "Email",
                          placeholder: "Digite seu email",
                          isPassword: false,
                        ),
                        const SizedBox(height: 20),
                        CustomInput(
                          controller: _passwordController,
                          iconUri: AppIcons.lock,
                          label: "Senha",
                          placeholder: "Digite sua senha",
                          isPassword: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Botão moderno com gradiente
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0XFF333333).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: CustomButton(
                      onPressed: _signIn,
                      backgroundColor: const Color(0XFF333333),
                      text: 'Entrar',
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Link para cadastro
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SignUpScreen(),
                          ),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                          ),
                          children: [
                            const TextSpan(text: "Não tem uma conta? "),
                            TextSpan(
                              text: "Cadastre-se",
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
