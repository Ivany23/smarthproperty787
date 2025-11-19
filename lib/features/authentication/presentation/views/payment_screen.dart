import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/constants/assets.dart';
import 'package:flutter_application_1/core/constants/colors.dart';
import 'package:flutter_application_1/core/shared/widgets/custom_button.dart';
import 'package:flutter_application_1/core/shared/widgets/custom_input.dart';
import 'package:flutter_application_1/features/authentication/presentation/views/sign_in.dart';
import 'package:flutter_application_1/wrapper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class PaymentEmbedded extends StatefulWidget {
  final VoidCallback onBack;

  const PaymentEmbedded({super.key, required this.onBack});

  @override
  State<PaymentEmbedded> createState() => _PaymentEmbeddedState();
}

class _PaymentEmbeddedState extends State<PaymentEmbedded> {
  late TextEditingController _amountController;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  String _selectedMethod = 'MPESA';

  Map<String, dynamic>? _paymentData;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: '25.00'); // Default amount
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _loadUserData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('visitorName') ?? '';
    final email =
        prefs.getString('visitorEmail') ??
        prefs.getString('email') ??
        ''; // Assume email stored
    _nameController.text = name;
    _emailController.text = email;
  }

  Future<void> _processPayment() async {
    final prefs = await SharedPreferences.getInstance();
    final visitorId = prefs.getInt('visitorId');
    if (visitorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ID do visitante não encontrado.'),
          backgroundColor: Colors.red,
        ),
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
      const String apiUrl = "http://localhost:8080/api/pagamentos/processar";
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(<String, dynamic>{
          'visitanteId': visitorId,
          'valor': double.parse(_amountController.text),
          'metodoPagamento': _selectedMethod,
        }),
      );

      if (!mounted) return;
      Navigator.pop(context);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _paymentData = data;
        });
        // Update prefs to advertiser
        await prefs.setBool('isAdvertiser', true);
        await prefs.setInt('anuncianteId', data['anunciante']['id']);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pagamento processado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Erro desconhecido';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $error'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro de conexão: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _listPayments() async {
    final prefs = await SharedPreferences.getInstance();
    final anuncianteId = prefs.getInt('anuncianteId');
    if (anuncianteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ID do anunciante não encontrado.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final String apiUrl =
          "http://localhost:8080/api/pagamentos?anuncianteId=$anuncianteId";
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Pagamentos'),
              content: SingleChildScrollView(
                child: Column(
                  children: data.map<Widget>((item) {
                    return ListTile(
                      leading: Icon(Icons.payment),
                      title: Text('Valor: ${item['valor']}'),
                      subtitle: Text(
                        'Método: ${item['metodoPagamento']} | Status: ${item['statusPagamento']}',
                      ),
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Fechar'),
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao listar pagamentos.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro de conexão: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> _shouldShowBack() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final isAdvertiser = prefs.getBool('isAdvertiser') ?? false;
    return isLoggedIn && !isAdvertiser;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: FutureBuilder<bool>(
              future: _shouldShowBack(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data == true) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: widget.onBack,
                        child: Text(
                          "Voltar",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (_paymentData != null)
                        TextButton(
                          onPressed: _listPayments,
                          child: Text(
                            "Listar Pagamentos",
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  );
                } else {
                  if (_paymentData != null) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _listPayments,
                          child: Text(
                            "Listar Pagamentos",
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }
              },
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Image.asset(AppIcons.userTwo, width: 24, height: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _nameController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Image.asset(AppIcons.email, width: 24, height: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _emailController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: CustomInput(
              controller: _amountController,
              iconUri: AppIcons.coinOne,
              label: "Valor (MZN)",
              placeholder: "Digite o valor",
              isPassword: false,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: DropdownButtonFormField<String>(
              value: _selectedMethod,
              decoration: const InputDecoration(
                labelText: 'Método de Pagamento',
              ),
              items: ['MPESA', 'EMOLA'].map((method) {
                return DropdownMenuItem<String>(
                  value: method,
                  child: Text(method),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedMethod = value!;
                });
              },
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: CustomButton(
                    onPressed: _processPayment,
                    backgroundColor: const Color(0XFF333333),
                    text: 'Processar Pagamento',
                  ),
                ),
              ),
            ],
          ),
          if (_paymentData != null) ...[
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 10),
                        Text(
                          'Anunciante: ${_paymentData!['anunciante']['nomeVisitante']}',
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.credit_card, color: Colors.green),
                        const SizedBox(width: 10),
                        Text(
                          'Créditos: ${_paymentData!['credito']?['saldo'] ?? '0.00'}',
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.payment, color: Colors.green),
                        const SizedBox(width: 10),
                        Text(
                          'Pagamento: ${_paymentData!['pagamento']['valor']} via ${_paymentData!['pagamento']['metodoPagamento']}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: CustomButton(
                      onPressed: widget.onBack,
                      backgroundColor: Colors.green,
                      text: 'Continuar',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PaymentScreenState extends State<PaymentScreen> {
  late TextEditingController _amountController;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  String _selectedMethod = 'MPESA';

  Map<String, dynamic>? _paymentData;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: '25.00'); // Default amount
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _loadUserData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('visitorName') ?? '';
    final email =
        prefs.getString('visitorEmail') ??
        prefs.getString('email') ??
        ''; // Assume email stored
    _nameController.text = name;
    _emailController.text = email;
  }

  Future<void> _processPayment() async {
    final prefs = await SharedPreferences.getInstance();
    final visitorId = prefs.getInt('visitorId');
    if (visitorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ID do visitante não encontrado.'),
          backgroundColor: Colors.red,
        ),
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
      const String apiUrl = "http://localhost:8080/api/pagamentos/processar";
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(<String, dynamic>{
          'visitanteId': visitorId,
          'valor': double.parse(_amountController.text),
          'metodoPagamento': _selectedMethod,
        }),
      );

      if (!mounted) return;
      Navigator.pop(context);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _paymentData = data;
        });
        // Update prefs to advertiser
        await prefs.setBool('isAdvertiser', true);
        await prefs.setInt('anuncianteId', data['anunciante']['id']);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pagamento processado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final error = jsonDecode(response.body)['error'] ?? 'Erro desconhecido';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $error'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro de conexão: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _listPayments() async {
    final prefs = await SharedPreferences.getInstance();
    final anuncianteId = prefs.getInt('anuncianteId');
    if (anuncianteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ID do anunciante não encontrado.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final String apiUrl =
          "http://localhost:8080/api/pagamentos?anuncianteId=$anuncianteId";
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Pagamentos'),
              content: SingleChildScrollView(
                child: Column(
                  children: data.map<Widget>((item) {
                    return ListTile(
                      leading: Icon(Icons.payment),
                      title: Text('Valor: ${item['valor']}'),
                      subtitle: Text(
                        'Método: ${item['metodoPagamento']} | Status: ${item['statusPagamento']}',
                      ),
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Fechar'),
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao listar pagamentos.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro de conexão: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const Wrapper(),
                          ),
                        );
                      },
                      child: Text(
                        "Voltar",
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (_paymentData != null)
                      TextButton(
                        onPressed: _listPayments,
                        child: Text(
                          "Listar Pagamentos",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Image.asset(AppIcons.userTwo, width: 24, height: 24),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _nameController,
                              readOnly: true,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Image.asset(AppIcons.email, width: 24, height: 24),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _emailController,
                              readOnly: true,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: CustomInput(
                  controller: _amountController,
                  iconUri: AppIcons.coinOne,
                  label: "Valor (MZN)",
                  placeholder: "Digite o valor",
                  isPassword: false,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: DropdownButtonFormField<String>(
                  value: _selectedMethod,
                  decoration: const InputDecoration(
                    labelText: 'Método de Pagamento',
                  ),
                  items: ['MPESA', 'EMOLA'].map((method) {
                    return DropdownMenuItem<String>(
                      value: method,
                      child: Text(method),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedMethod = value!;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: CustomButton(
                        onPressed: _processPayment,
                        backgroundColor: const Color(0XFF333333),
                        text: 'Processar Pagamento',
                      ),
                    ),
                  ),
                ],
              ),
              if (_paymentData != null) ...[
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 10),
                            Text(
                              'Anunciante: ${_paymentData!['anunciante']['nomeVisitante']}',
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.credit_card, color: Colors.green),
                            const SizedBox(width: 10),
                            Text(
                              'Créditos: ${_paymentData!['credito']?['saldo'] ?? '0.00'}',
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.payment, color: Colors.green),
                            const SizedBox(width: 10),
                            Text(
                              'Pagamento: ${_paymentData!['pagamento']['valor']} via ${_paymentData!['pagamento']['metodoPagamento']}',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: CustomButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const Wrapper(),
                              ),
                            );
                          },
                          backgroundColor: Colors.green,
                          text: 'Continuar',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
