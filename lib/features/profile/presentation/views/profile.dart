import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/constants/assets.dart';
import 'package:flutter_application_1/features/profile/presentation/views/verify_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/features/authentication/presentation/views/sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'become_advertiser_screen.dart';
import 'identity_verification_screen.dart';
import 'payments_screen.dart';
import 'gerenciar_anuncios_screen.dart';

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
  bool _hasDocuments = false;

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
        await _checkDocuments(anuncianteId);
      } else if (response.statusCode == 404) {
        setState(() {
          _isAdvertiser = false;
          _anuncianteId = 0;
          _hasDocuments = false;
          _isVerified = false;
        });
      }
    } catch (e) {
      print('Erro ao verificar status de anunciante: $e');
      setState(() {
        _isAdvertiser = false;
        _anuncianteId = 0;
        _hasDocuments = false;
        _isVerified = false;
      });
    }
  }

  Future<void> _checkDocuments(int anuncianteId) async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://localhost:8080/api/documentos-verificacao/anunciante/$anuncianteId',
        ),
      );

      if (response.statusCode == 200) {
        final docs = jsonDecode(response.body) as List;
        setState(() {
          _hasDocuments = docs.isNotEmpty;
          _isVerified =
              docs.isNotEmpty && docs.any((doc) => doc['verificado'] == true);
        });
      }
    } catch (e) {
      print('Erro ao verificar documentos: $e');
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
          _credits =
              (data['informacoes_creditos']['saldo_atual'] as num?)
                  ?.toDouble() ??
              0.0;
        });
      }
    } catch (e) {
      print('Erro ao carregar créditos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          'Perfil',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header com Avatar e Info
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _visitorName.isNotEmpty
                          ? _visitorName[0].toUpperCase()
                          : 'V',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nome
                  Text(
                    _visitorName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Badge de Status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _isAdvertiser
                          ? const Color(0xFF10B981).withOpacity(0.1)
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isAdvertiser ? Icons.verified : Icons.person,
                          size: 16,
                          color: _isAdvertiser
                              ? const Color(0xFF10B981)
                              : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isAdvertiser ? 'Anunciante' : 'Visitante',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _isAdvertiser
                                ? const Color(0xFF10B981)
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Créditos e Verificação (só para anunciantes)
                  if (_isAdvertiser) ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildInfoChip(
                          icon: Icons.account_balance_wallet_outlined,
                          label: '${_credits.toStringAsFixed(2)} MZN',
                          color: const Color(0xFF10B981),
                        ),
                        if (_isVerified) ...[
                          const SizedBox(width: 12),
                          _buildInfoChip(
                            icon: Icons.verified,
                            label: 'Verificado',
                            color: const Color(0xFF3B82F6),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Cards de Ações
            if (_isAdvertiser) ...[
              // Cards para Anunciantes
              _buildActionCard(
                icon: Icons.home_work_outlined,
                title: 'Gerenciar Anúncios',
                subtitle: 'Edite e gerencie seus imóveis',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const GerenciarAnunciosScreen(),
                    ),
                  );
                },
              ),
              _buildActionCard(
                icon: Icons.payment_outlined,
                title: 'Pagamentos',
                subtitle: 'Gerencie seus pagamentos e créditos',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PaymentsScreen(),
                    ),
                  );
                },
              ),
              _buildActionCard(
                icon: _hasDocuments
                    ? (_isVerified
                          ? Icons.verified_user
                          : Icons.pending_outlined)
                    : Icons.verified_user_outlined,
                title: _hasDocuments
                    ? (_isVerified
                          ? 'Identidade Verificada'
                          : 'Verificação Pendente')
                    : 'Verificar Identidade',
                subtitle: _hasDocuments
                    ? 'Gerencie seus documentos'
                    : 'Complete sua verificação',
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const IdentityVerificationScreen(),
                    ),
                  );
                  if (_anuncianteId > 0) {
                    _checkDocuments(_anuncianteId);
                  }
                },
                iconColor: _hasDocuments
                    ? (_isVerified
                          ? const Color(0xFF10B981)
                          : const Color(0xFFF59E0B))
                    : null,
              ),
            ] else ...[
              // Card para Visitantes (não anunciantes)
              _buildActionCard(
                icon: Icons.rocket_launch_outlined,
                title: 'Tornar-se Anunciante',
                subtitle: 'Comece a anunciar seus imóveis',
                onTap: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const BecomeAdvertiserScreen(),
                    ),
                  );
                  if (result == true) {
                    _loadVisitorData();
                  }
                },
                iconColor: const Color(0xFF6366F1),
              ),
            ],

            const SizedBox(height: 12),

            // Botão de Logout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: const Text('Sair'),
                          content: const Text('Tem certeza que deseja sair?'),
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
                              child: const Text('Sair'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
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
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.logout,
                              color: Colors.red,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sair',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Encerrar sessão',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (iconColor ?? Colors.black87).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor ?? Colors.black87,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey,
                    size: 16,
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
