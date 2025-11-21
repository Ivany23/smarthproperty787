import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/features/home/presentation/views/home.dart';
import 'package:flutter_application_1/features/authentication/presentation/views/login_screen.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  void initState() {
    super.initState();
    print('Wrapper screen loaded - verificando autenticação');
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 1));

    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final visitorId = prefs.getInt('visitorId');

    print('═══════════════════════════════════════');
    print('🔐 Verificação de Autenticação:');
    print('  isLoggedIn: $isLoggedIn');
    print('  visitorId: $visitorId');
    print('═══════════════════════════════════════');

    if (!mounted) return;

    if (isLoggedIn && visitorId != null) {
      print('✅ Autenticação válida - navegando para Home');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    } else if (isLoggedIn && visitorId == null) {
      print('⚠️ Login antigo detectado sem visitorId - forçando logout');
      await prefs.clear();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, faça login novamente'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } else {
      print('❌ Não autenticado - navegando para Login');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Verificando autenticação...'),
          ],
        ),
      ),
    );
  }
}
