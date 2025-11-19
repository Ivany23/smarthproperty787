
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

    Future.delayed(const Duration(seconds: 2), (){
      navigate();
    });
  }
  void navigate(){
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=> const HomeScreen()));
  }
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
