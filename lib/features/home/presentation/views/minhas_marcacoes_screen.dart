import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/services/marcacao_service.dart';
import 'package:intl/intl.dart';

class MinhasMarcacoesScreen extends StatefulWidget {
  const MinhasMarcacoesScreen({Key? key}) : super(key: key);

  @override
  State<MinhasMarcacoesScreen> createState() => _MinhasMarcacoesScreenState();
}

class _MinhasMarcacoesScreenState extends State<MinhasMarcacoesScreen> {
  final _marcacaoService = MarcacaoService();
  List<Map<String, dynamic>> _marcacoes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarMarcacoes();
  }

  Future<void> _carregarMarcacoes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final marcacoes = await _marcacaoService.listarMinhasMarcacoes();
      setState(() {
        _marcacoes = marcacoes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar marcações: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _cancelarMarcacao(int idMarcacao) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancelar Marcação'),
        content: const Text('Tem certeza que deseja cancelar esta marcação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Não'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Sim, Cancelar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _marcacaoService.cancelarMarcacao(idMarcacao);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Marcação cancelada com sucesso'),
              backgroundColor: Colors.green,
            ),
          );
          _carregarMarcacoes();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao cancelar marcação'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDENTE':
        return const Color(0xFFF59E0B);
      case 'CONFIRMADA':
        return const Color(0xFF10B981);
      case 'CANCELADA':
        return const Color(0xFFEF4444);
      case 'CONCLUIDA':
        return const Color(0xFF6366F1);
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'PENDENTE':
        return Icons.schedule_rounded;
      case 'CONFIRMADA':
        return Icons.check_circle_rounded;
      case 'CANCELADA':
        return Icons.cancel_rounded;
      case 'CONCLUIDA':
        return Icons.task_alt_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'PENDENTE':
        return 'Pendente';
      case 'CONFIRMADA':
        return 'Confirmada';
      case 'CANCELADA':
        return 'Cancelada';
      case 'CONCLUIDA':
        return 'Concluída';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Minhas Marcações',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.black),
            onPressed: _carregarMarcacoes,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : _marcacoes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.event_busy_rounded,
                      size: 64,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Nenhuma marcação encontrada',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Agende uma visita a um imóvel',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _carregarMarcacoes,
              color: Colors.black,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _marcacoes.length,
                itemBuilder: (context, index) {
                  final marcacao = _marcacoes[index];
                  final status = marcacao['status'] ?? 'PENDENTE';
                  final dataInicio = DateTime.parse(marcacao['dataHoraInicio']);
                  final dataFim = DateTime.parse(marcacao['dataHoraFim']);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Header com status
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _getStatusColor(status).withOpacity(0.1),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _getStatusIcon(status),
                                color: Colors.black87,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _getStatusText(status),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'ID: ${marcacao['id']}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Conteúdo
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Data e hora
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.calendar_today_rounded,
                                      color: Colors.black87,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          DateFormat(
                                            'dd/MM/yyyy',
                                          ).format(dataInicio),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${DateFormat('HH:mm').format(dataInicio)} - ${DateFormat('HH:mm').format(dataFim)}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              if (marcacao['observacoes'] != null &&
                                  marcacao['observacoes']
                                      .toString()
                                      .isNotEmpty) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.notes_rounded,
                                        color: Colors.black54,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          marcacao['observacoes'],
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              // Botão de cancelar (apenas se não estiver cancelada)
                              if (status != 'CANCELADA' &&
                                  status != 'CONCLUIDA') ...[
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () =>
                                        _cancelarMarcacao(marcacao['id']),
                                    icon: const Icon(
                                      Icons.cancel_outlined,
                                      size: 20,
                                    ),
                                    label: const Text('Cancelar Marcação'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      side: const BorderSide(color: Colors.red),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
