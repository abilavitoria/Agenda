import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';
import '../services/speech_service.dart';

class EventDialog extends StatefulWidget {
  final EventModel? eventToEdit;
  final DateTime? initialDate;

  const EventDialog({
    super.key,
    this.eventToEdit,
    this.initialDate,
  });

  static Future<void> show(
    BuildContext context, {
    EventModel? eventToEdit,
    DateTime? initialDate,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EventDialog(
        eventToEdit: eventToEdit,
        initialDate: initialDate,
      ),
    );
  }

  @override
  State<EventDialog> createState() => _EventDialogState();
}

class _EventDialogState extends State<EventDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late String _selectedCategory;
  late int _selectedReminderMinutes;

  final SpeechService _speechService = SpeechService();
  bool _isDictatingTitle = false;
  bool _isDictatingDesc = false;

  final List<String> _categories = const [
    'Trabalho',
    'Pessoal',
    'Saúde',
    'Social',
    'Estudo',
    'Geral',
  ];

  @override
  void initState() {
    super.initState();
    final edit = widget.eventToEdit;

    _titleController = TextEditingController(text: edit?.title ?? '');
    _descriptionController =
        TextEditingController(text: edit?.description ?? '');

    if (edit != null) {
      _selectedDate = edit.date;
      final timeParts = edit.time.split(':');
      final hour = timeParts.isNotEmpty ? int.tryParse(timeParts[0]) ?? 12 : 12;
      final min = timeParts.length > 1 ? int.tryParse(timeParts[1]) ?? 0 : 0;
      _selectedTime = TimeOfDay(hour: hour, minute: min);
      _selectedCategory = edit.category;
      _selectedReminderMinutes = edit.reminderMinutesBefore;
    } else {
      _selectedDate = widget.initialDate ?? DateTime.now();
      _selectedTime = TimeOfDay.now();
      _selectedCategory = 'Geral';
      _selectedReminderMinutes = 30;
    }
  }

  @override
  void dispose() {
    _speechService.stopListening();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _dictateField({required bool isTitle}) async {
    if ((isTitle && _isDictatingTitle) || (!isTitle && _isDictatingDesc)) {
      await _speechService.stopListening();
      setState(() {
        _isDictatingTitle = false;
        _isDictatingDesc = false;
      });
      return;
    }

    final success = await _speechService.initSpeech();
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _speechService.errorMessage ?? 'Microfone não disponível no dispositivo.',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      if (isTitle) {
        _isDictatingTitle = true;
        _isDictatingDesc = false;
      } else {
        _isDictatingTitle = false;
        _isDictatingDesc = true;
      }
    });

    await _speechService.startListening(
      onResult: (words, isFinal) {
        if (!mounted) return;
        setState(() {
          if (isTitle) {
            _titleController.text = words;
          } else {
            _descriptionController.text = words;
          }
          if (isFinal) {
            _isDictatingTitle = false;
            _isDictatingDesc = false;
          }
        });
      },
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.colorScheme.primary,
              onPrimary: Colors.white,
              surface: theme.colorScheme.surface,
              onSurface: theme.colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.colorScheme.primary,
              onPrimary: Colors.white,
              surface: theme.colorScheme.surface,
              onSurface: theme.colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveEvent() {
    if (!_formKey.currentState!.validate()) return;

    final formattedHour = _selectedTime.hour.toString().padLeft(2, '0');
    final formattedMinute = _selectedTime.minute.toString().padLeft(2, '0');
    final timeStr = '$formattedHour:$formattedMinute';

    final eventService = EventService();

    if (widget.eventToEdit != null) {
      final updated = widget.eventToEdit!.copyWith(
        title: _titleController.text.trim(),
        date: _selectedDate,
        time: timeStr,
        category: _selectedCategory,
        description: _descriptionController.text.trim(),
        reminderMinutesBefore: _selectedReminderMinutes,
      );
      eventService.updateEvent(updated);
    } else {
      final newEvent = EventModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        date: _selectedDate,
        time: timeStr,
        category: _selectedCategory,
        description: _descriptionController.text.trim(),
        reminderMinutesBefore: _selectedReminderMinutes,
      );
      eventService.addEvent(newEvent);
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.eventToEdit != null
                    ? 'Evento atualizado com sucesso!'
                    : 'Evento cadastrado com sucesso!',
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isEditing = widget.eventToEdit != null;

    final formattedHour = _selectedTime.hour.toString().padLeft(2, '0');
    final formattedMinute = _selectedTime.minute.toString().padLeft(2, '0');
    final formattedTime = '$formattedHour:$formattedMinute';

    final formattedDate =
        '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}';

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
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barra superior de arraste
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
              const SizedBox(height: 16),

              // Cabeçalho do modal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Editar Evento' : 'Novo Evento',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
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

              // Título
              Text(
                'Título do Evento',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Ex: Reunião, Casamento, Dentista',
                  prefixIcon: const Icon(Icons.event_note),
                  suffixIcon: IconButton(
                    tooltip: 'Ditar título com microfone',
                    icon: Icon(
                      _isDictatingTitle ? Icons.mic : Icons.mic_none,
                      color: _isDictatingTitle
                          ? colorScheme.primary
                          : colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    onPressed: () => _dictateField(isTitle: true),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o título do evento';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Categoria
              Text(
                'Categoria',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected
                            ? (isDark ? Colors.black : Colors.white)
                            : colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: colorScheme.primary,
                    backgroundColor: isDark
                        ? const Color(0xFF1F1B2C)
                        : const Color(0xFFEAE3D9),
                    side: BorderSide(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface.withValues(alpha: 0.2),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Data e Horário
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Data',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: _pickDate,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1F1B2C)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 18,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    formattedDate,
                                    style: TextStyle(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Horário',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: _pickTime,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1F1B2C)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 18,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    formattedTime,
                                    style: TextStyle(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Lembrete
              Text(
                'Lembrete',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<int>(
                initialValue: _selectedReminderMinutes,
                dropdownColor: theme.cardTheme.color,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.notifications_active_outlined),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 0,
                    child: Text('No momento do evento'),
                  ),
                  DropdownMenuItem(
                    value: 15,
                    child: Text('15 minutos antes'),
                  ),
                  DropdownMenuItem(
                    value: 30,
                    child: Text('30 minutos antes'),
                  ),
                  DropdownMenuItem(
                    value: 60,
                    child: Text('1 hora antes'),
                  ),
                  DropdownMenuItem(
                    value: 1440,
                    child: Text('1 dia antes'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedReminderMinutes = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Descrição
              Text(
                'Descrição / Notas (Opcional)',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descriptionController,
                maxLines: 2,
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Adicione detalhes adicionais...',
                  prefixIcon: const Icon(Icons.notes),
                  suffixIcon: IconButton(
                    tooltip: 'Ditar notas com microfone',
                    icon: Icon(
                      _isDictatingDesc ? Icons.mic : Icons.mic_none,
                      color: _isDictatingDesc
                          ? colorScheme.primary
                          : colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    onPressed: () => _dictateField(isTitle: false),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Botão Salvar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveEvent,
                  icon: const Icon(Icons.check_circle),
                  label: Text(
                    isEditing ? 'Atualizar Evento' : 'Salvar Evento',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
