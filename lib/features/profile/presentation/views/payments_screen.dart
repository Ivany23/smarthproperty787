import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/constants/assets.dart';
import 'package:flutter_application_1/core/constants/colors.dart';
import 'package:flutter_application_1/core/shared/widgets/custom_button.dart';
import 'package:flutter_application_1/core/shared/widgets/custom_input.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  late TextEditingController _amountController;
  double _currentCredits = 0.0;
  int _visitorId = 0;
  int _anuncianteId = 0;
  bool _isLoading = true;
  String _selectedMethod = 'MPESA';

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _loadUserData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _visitorId = prefs.getInt('visitorId') ?? 0;
    _anuncianteId = prefs.getInt('anuncianteId') ?? 0;

    if (_anuncianteId > 0) {
      await _loadCredits();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadCredits() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://localhost:8080/api/creditos/anunciante/$_anuncianteId',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _currentCredits = (data['saldo_creditos'] as num?)?.toDouble() ?? 0.0;
        });
      }
    } catch (e) {
      print('Erro ao carregar créditos: $e');
    }
  }

  Future<void> _buyCredits() async {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira um valor')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount < 1 || amount > 1000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Valor deve ser entre 1 e 1000 MZN')),
      );
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
      final response = await http.post(
        Uri.parse(
          'http://localhost:8080/api/creditos/comprar/anunciante/$_anuncianteId?idVisitante=$_visitorId&metodoPagamento=$_selectedMethod&valorPago=$amount',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (!mounted) return;
      Navigator.pop(context);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _currentCredits =
              (data['saldo_atual'] as num?)?.toDouble() ?? _currentCredits;
        });
        _amountController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Créditos comprados com sucesso!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao comprar créditos: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: const Text('Créditos'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current Credits Balance
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          Image.asset(AppIcons.coinOne, width: 40, height: 40),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Saldo Atual',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${_currentCredits.toStringAsFixed(2)} Créditos',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Buy Credits Section
                    const Text(
                      'Comprar Créditos',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '1 MZN = 1 Crédito',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Amount Input
                    CustomInput(
                      controller: _amountController,
                      iconUri: AppIcons.coinOne,
                      label: "Valor (MZN)",
                      placeholder: "Ex: 100",
                      isPassword: false,
                    ),
                    const SizedBox(height: 20),

                    // Payment Method Selection
                    const Text(
                      'Método de Pagamento',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedMethod = 'MPESA';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _selectedMethod == 'MPESA'
                                      ? AppColors.primary
                                      : Colors.grey.shade300,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                color: _selectedMethod == 'MPESA'
                                    ? AppColors.primary.withOpacity(0.1)
                                    : Colors.transparent,
                              ),
                              child: Column(
                                children: [
                                  Image.asset(
                                    AppIcons.mpesa,
                                    width: 30,
                                    height: 30,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'MPESA',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: _selectedMethod == 'MPESA'
                                          ? AppColors.primary
                                          : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedMethod = 'EMOLA';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _selectedMethod == 'EMOLA'
                                      ? AppColors.primary
                                      : Colors.grey.shade300,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                color: _selectedMethod == 'EMOLA'
                                    ? AppColors.primary.withOpacity(0.1)
                                    : Colors.transparent,
                              ),
                              child: Column(
                                children: [
                                  Image.asset(
                                    AppIcons.emola,
                                    width: 30,
                                    height: 30,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'EMOLA',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: _selectedMethod == 'EMOLA'
                                          ? AppColors.primary
                                          : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Buy Button
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        onPressed: _buyCredits,
                        backgroundColor: const Color(0XFF333333),
                        text: 'Comprar Créditos',
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
