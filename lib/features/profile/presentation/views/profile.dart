import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/constants/assets.dart';
import 'package:flutter_application_1/core/constants/colors.dart';
import 'package:flutter_application_1/features/profile/presentation/views/verify_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/features/authentication/presentation/views/sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'become_advertiser_screen.dart';
import 'identity_verification_screen.dart';
import 'payments_screen.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  String _visitorName = 'Visitante';
  int _visitorId = 0;
  int _anuncianteId = 0;
  double _credits = 0.0;
  bool _isAdvertiser = false;
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    _loadVisitorData();
  }

  Future<void> _loadVisitorData() async {
    final prefs = await SharedPreferences.getInstance();
    final visitorId = prefs.getInt('visitorId') ?? 0;
    final name = prefs.getString('visitorName') ?? 'Visitante';

    setState(() {
      _visitorId = visitorId;
      _visitorName = name;
    });

    if (visitorId > 0) {
      await _checkAdvertiserStatus(visitorId);
    }
  }

  Future<void> _checkAdvertiserStatus(int visitorId) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/anunciante/visitante/$visitorId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final anuncianteId = data['id'];
        setState(() {
          _isAdvertiser = true;
          _anuncianteId = anuncianteId;
          _isVerified = data['verificado'] ?? false;
        });
        await _loadCredits(anuncianteId);
      } else if (response.statusCode == 404) {
        setState(() {
          _isAdvertiser = false;
        });
      }
    } catch (e) {
      print('Erro ao verificar status de anunciante: $e');
      setState(() {
        _isAdvertiser = false;
      });
    }
  }

  Future<void> _loadCredits(int anuncianteId) async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://localhost:8080/api/anunciante/$anuncianteId/creditos',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _credits = (data['informacoes_creditos']['saldo_atual'] as num?)?.toDouble() ?? 0.0;
        });
      }
    } catch (e) {
      print('Erro ao carregar créditos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text('Perfil'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: const Color(0XFF949AA8),
                    shape: BoxShape.circle,
                    boxShadow: [
                      const BoxShadow(
                        offset: Offset(0, 10),
                        color: Colors.black12,
                        blurRadius: 14,
                        spreadRadius: 10,
                      ),
                      BoxShadow(
                        offset: const Offset(0, 0),
                        color: AppColors.primary.withAlpha(100),
                        spreadRadius: 6,
                      ),
                      const BoxShadow(
                        offset: Offset(0, 0),
                        color: Colors.white,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _visitorName.isNotEmpty
                        ? _visitorName[0].toUpperCase()
                        : 'V',
                    style: const TextStyle(color: Colors.white, fontSize: 64),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              _visitorName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            if (_isAdvertiser)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Créditos: ${_credits.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16, color: Colors.green),
                    ),
                    const SizedBox(width: 20),
                    if (_isVerified)
                      const Row(
                        children: [
                          Icon(Icons.verified, color: Colors.blue),
                          SizedBox(width: 5),
                          Text(
                            'Verificado',
                            style: TextStyle(fontSize: 16, color: Colors.blue),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                if (!_isAdvertiser)
                  _buildProfileIcon(
                    icon: Icons.person_add,
                    label: 'Tornar-se Anunciante',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const BecomeAdvertiserScreen(),
                        ),
                      );
                    },
                  ),
                if (_isAdvertiser)
                  _buildProfileIcon(
                    icon: Icons.payment,
                    label: 'Pagamentos',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const PaymentsScreen(),
                        ),
                      );
                    },
                  ),
                _buildProfileIcon(
                  icon: Icons.verified_user,
                  label: 'Verificação de Identidade',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const IdentityVerificationScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 40),
            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ElevatedButton.icon(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('visitorName');
                  await prefs.remove('visitorId');
                  await prefs.setBool('isLoggedIn', false);
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const SignInScreen(),
                      ),
                      (route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  'Sair',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileIcon(
      {required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 40, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
