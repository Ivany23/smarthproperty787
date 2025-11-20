import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/home/presentation/views/home.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  void initState() {
    super.initState();
    print('Wrapper screen loaded - starting delay');

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        print('Wrapper delay complete - navigating to HomeScreen');
        navigate();
      }
    });
  }

  void navigate() {
    print('Navigating from Wrapper to HomeScreen');
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    print('Wrapper building');
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
