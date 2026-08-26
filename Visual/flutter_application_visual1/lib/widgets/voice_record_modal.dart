import 'package:flutter/material.dart';
import '../services/event_service.dart';

class VoiceRecordModal extends StatefulWidget {
  const VoiceRecordModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const VoiceRecordModal(),
    );
  }

  @override
  State<VoiceRecordModal> createState() => _VoiceRecordModalState();
}

class _VoiceRecordModalState extends State<VoiceRecordModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final TextEditingController _textController = TextEditingController();
  bool _isListening = true;

  final List<Map<String, dynamic>> _quickSuggestions = [
    {
      'label': 'Casamento dia 20 de Abril às 16:00',
      'title': 'Casamento',
      'category': 'Social',
      'month': 4,
      'day': 20,
      'time': '16:00',
    },
    {
      'label': 'Reunião com equipe amanhã às 10:00',
      'title': 'Reunião com equipe',
      'category': 'Trabalho',
      'offsetDays': 1,
      'time': '10:00',
    },
    {
      'label': 'Consulta Médica na sexta às 14:30',
      'title': 'Consulta Médica',
      'category': 'Saúde',
      'offsetDays': 3,
      'time': '14:30',
    },
    {
      'label': 'Treino de Academia hoje às 19:00',
      'title': 'Treino de Academia',
      'category': 'Pessoal',
      'offsetDays': 0,
      'time': '19:00',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _createEventFromData({
    required String title,
    required DateTime date,
    required String time,
    required String category,
  }) {
    EventService().addEventFromVoice(
      title: title,
      date: date,
      time: time,
      category: category,
      description: 'Criado rapidamente via comando de voz',
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Evento "$title" adicionado à agenda!',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _handleCustomConfirm() {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Digite ou fale o evento para salvar'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final now = DateTime.now();
    _createEventFromData(
      title: text,
      date: DateTime(now.year, now.month, now.day + 1),
      time: '14:00',
      category: 'Geral',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Barra de arraste
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Ícone animado do microfone
            GestureDetector(
              onTap: () {
                setState(() {
                  _isListening = !_isListening;
                  if (_isListening) {
                    _animationController.repeat(reverse: true);
                  } else {
                    _animationController.stop();
                  }
                });
              },
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.primary,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(
                          alpha: isDark ? 0.6 : 0.35,
                        ),
                        blurRadius: isDark ? 28 : 16,
                        spreadRadius: isDark ? 6 : 3,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isListening ? Icons.mic : Icons.mic_off,
                    size: 46,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              _isListening ? 'Ouvindo seu evento...' : 'Toque para falar',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Diga o título, data e horário ou selecione uma sugestão rápida',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 20),

            // Campo para digitar ou ver a transcrição
            TextField(
              controller: _textController,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Ou digite: "Dentista amanhã às 15h"',
                prefixIcon: const Icon(Icons.record_voice_over),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _handleCustomConfirm,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Sugestões rápidas
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Sugestões rápidas:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ),
            const SizedBox(height: 8),

            ..._quickSuggestions.map((sug) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: InkWell(
                  onTap: () {
                    final now = DateTime.now();
                    DateTime targetDate;
                    if (sug.containsKey('month')) {
                      final year = now.month > sug['month']
                          ? now.year + 1
                          : now.year;
                      targetDate = DateTime(year, sug['month'], sug['day']);
                    } else {
                      final offset = sug['offsetDays'] as int;
                      targetDate = DateTime(
                        now.year,
                        now.month,
                        now.day + offset,
                      );
                    }

                    _createEventFromData(
                      title: sug['title'],
                      date: targetDate,
                      time: sug['time'],
                      category: sug['category'],
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1B1728)
                          : const Color(0xFFEFE9DF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          color: colorScheme.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            sug['label'],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleCustomConfirm,
                child: const Text('Confirmar e Salvar Evento'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
