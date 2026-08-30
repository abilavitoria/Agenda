import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';
import '../services/speech_service.dart';
import '../services/voice_event_parser.dart';
import 'event_dialog.dart';

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
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _waveController;

  final TextEditingController _textController = TextEditingController();
  final SpeechService _speechService = SpeechService();

  ParsedVoiceEvent? _parsedEvent;
  bool _isListening = false;
  String _recognizedText = '';
  String? _statusMessage;

  final List<Map<String, String>> _sampleVoicePhrases = [
    {
      'title': 'Reunião de equipe',
      'phrase': 'Reunião com equipe amanhã às 10:00',
    },
    {
      'title': 'Consulta médica',
      'phrase': 'Consulta médica sexta-feira às 14:30',
    },
    {
      'title': 'Treino de academia',
      'phrase': 'Treino de academia hoje às 19:00',
    },
    {
      'title': 'Aniversário',
      'phrase': 'Aniversário do Lucas no sábado às 20 horas',
    },
  ];

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.22).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _textController.addListener(_onTextChanged);

    // Inicia escuta automática com pequeno delay para fluidez de abertura do modal
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startListening();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _textController.dispose();
    _speechService.stopListening();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _parsedEvent = VoiceEventParser.parse(text);
      });
    } else {
      setState(() {
        _parsedEvent = null;
      });
    }
  }

  Future<void> _startListening() async {
    setState(() {
      _isListening = true;
      _statusMessage = 'Ouvindo... Fale seu compromisso';
    });

    final success = await _speechService.initSpeech();
    if (!success && mounted) {
      setState(() {
        _isListening = false;
        _statusMessage =
            _speechService.errorMessage ?? 'Microfone não disponível. Você pode digitar ou usar os exemplos.';
      });
      return;
    }

    if (!mounted) return;

    await _speechService.startListening(
      onResult: (words, isFinal) {
        if (!mounted) return;
        setState(() {
          _recognizedText = words;
          _textController.text = words;
          _parsedEvent = VoiceEventParser.parse(words);

          if (isFinal) {
            _isListening = false;
            _statusMessage = 'Voz reconhecida com sucesso!';
          }
        });
      },
    );
  }

  Future<void> _stopListening() async {
    await _speechService.stopListening();
    if (mounted) {
      setState(() {
        _isListening = false;
        _statusMessage = _recognizedText.isNotEmpty
            ? 'Processado!'
            : 'Gravação finalizada';
      });
    }
  }

  void _toggleListening() {
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  void _applySamplePhrase(String phrase) {
    _speechService.stopListening();
    setState(() {
      _isListening = false;
      _recognizedText = phrase;
      _textController.text = phrase;
      _parsedEvent = VoiceEventParser.parse(phrase);
      _statusMessage = 'Exemplo selecionado!';
    });
  }

  void _saveEvent() {
    if (_parsedEvent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Fale ou digite seu evento antes de salvar.'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final parsed = _parsedEvent!;
    EventService().addEventFromVoice(
      title: parsed.title,
      date: parsed.date,
      time: parsed.time,
      category: parsed.category,
      description: 'Criado via comando de voz: "${parsed.originalText}"',
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Evento "${parsed.title}" adicionado à agenda!',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _openInEventDialog() {
    if (_parsedEvent == null) return;
    final parsed = _parsedEvent!;
    final tempEvent = EventModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: parsed.title,
      date: parsed.date,
      time: parsed.time,
      category: parsed.category,
      description: 'Criado via voz: "${parsed.originalText}"',
    );

    Navigator.pop(context);
    EventDialog.show(context, eventToEdit: tempEvent);
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
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Barra de arraste
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),

            // Cabeçalho do modal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.mic, color: colorScheme.primary, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Criar Evento por Voz',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Botão Animado do Microfone
            GestureDetector(
              onTap: _toggleListening,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  final scale = _isListening ? _pulseAnimation.value : 1.0;
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isListening
                            ? colorScheme.primary
                            : (isDark ? const Color(0xFF2C243B) : const Color(0xFFDDD4C7)),
                        boxShadow: _isListening
                            ? [
                                BoxShadow(
                                  color: colorScheme.primary.withValues(
                                    alpha: isDark ? 0.6 : 0.4,
                                  ),
                                  blurRadius: 28,
                                  spreadRadius: 6,
                                ),
                              ]
                            : [],
                      ),
                      child: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        size: 44,
                        color: _isListening ? Colors.white : colorScheme.primary,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),

            // Status Text
            Text(
              _statusMessage ??
                  (_isListening
                      ? 'Ouvindo... Pode falar!'
                      : 'Toque no microfone para falar'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _isListening
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Ex: "Dentista amanhã às 14 horas" ou "Reunião de alinhamento dia 20 às 15:30"',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 18),

            // Campo de Transcrição e Edição
            TextField(
              controller: _textController,
              style: TextStyle(color: colorScheme.onSurface, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'O que você falar aparecerá aqui...',
                prefixIcon: Icon(
                  Icons.record_voice_over,
                  color: colorScheme.primary,
                ),
                suffixIcon: _textController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _textController.clear();
                          setState(() {
                            _recognizedText = '';
                            _parsedEvent = null;
                          });
                        },
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),

            // Card de Evento Reconhecido (Preview Inteligente)
            if (_parsedEvent != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1B1728)
                      : const Color(0xFFEBE3D6),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              color: colorScheme.primary,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Evento Identificado',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _parsedEvent!.category,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _parsedEvent!.title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _parsedEvent!.formattedDate,
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurface.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _parsedEvent!.time,
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurface.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Botões de Ação
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _openInEventDialog,
                      icon: const Icon(Icons.edit_note, size: 18),
                      label: const Text('Editar Campos'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _saveEvent,
                      icon: const Icon(Icons.check_circle, size: 18),
                      label: const Text('Salvar Evento'),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Sugestões Rápidas de Frases
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Ou toque em um exemplo rápido:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _sampleVoicePhrases.map((sample) {
                  return InkWell(
                    onTap: () => _applySamplePhrase(sample['phrase']!),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1F1B2C)
                            : const Color(0xFFEDE5D9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.mic_external_on,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            sample['phrase']!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
