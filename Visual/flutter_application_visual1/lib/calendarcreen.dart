import 'package:flutter/material.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  // Exemplo de lista de eventos mapeados por data
  final Map<String, List<Map<String, String>>> _events = {
    "2026-08-15": [
      {"title": "Reunião de Alinhamento", "time": "10:00", "tag": "Trabalho"},
      {"title": "Treino na Academia", "time": "18:30", "tag": "Pessoal"},
    ],
    "2026-08-18": [
      {"title": "Consulta Médica", "time": "14:00", "tag": "Saúde"},
    ],
    "2026-08-22": [
      {"title": "Aniversário da Camila", "time": "20:00", "tag": "Social"},
    ],
  };

  final List<String> _monthNames = const [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  final List<String> _weekDays = const [
    'Dom',
    'Seg',
    'Ter',
    'Qua',
    'Qui',
    'Sex',
    'Sáb',
  ];

  void _changeMonth(int increment) {
    setState(() {
      _focusedMonth = DateTime(
        _focusedMonth.year,
        _focusedMonth.month + increment,
        1,
      );
      _selectedDate = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    });
  }

  String _formatDateKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daysInMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month + 1,
      0,
    ).day;
    final firstWeekday =
        DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday % 7;

    final selectedKey = _formatDateKey(_selectedDate);
    final selectedEvents = _events[selectedKey] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendário & Agenda'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AllEventsScreen(
                    events: _events,
                    onEventUpdate: () => setState(() {}),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Card(
                  color: theme.colorScheme.surface,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: () => _changeMonth(-1),
                            ),
                            Text(
                              '${_monthNames[_focusedMonth.month - 1]} ${_focusedMonth.year}',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: () => _changeMonth(1),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: _weekDays.map((day) {
                            return Expanded(
                              child: Center(
                                child: Text(
                                  day,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.secondary,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const Divider(height: 16),
                        Expanded(
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 7,
                                  childAspectRatio: 1.0,
                                ),
                            itemCount: daysInMonth + firstWeekday,
                            itemBuilder: (context, index) {
                              if (index < firstWeekday) {
                                return const SizedBox.shrink();
                              }

                              final dayNumber = index - firstWeekday + 1;
                              final date = DateTime(
                                _focusedMonth.year,
                                _focusedMonth.month,
                                dayNumber,
                              );
                              final isSelected =
                                  date.year == _selectedDate.year &&
                                  date.month == _selectedDate.month &&
                                  date.day == _selectedDate.day;
                              final isToday =
                                  date.year == DateTime.now().year &&
                                  date.month == DateTime.now().month &&
                                  date.day == DateTime.now().day;

                              final dateKey = _formatDateKey(date);
                              final hasEvents =
                                  _events.containsKey(dateKey) &&
                                  _events[dateKey]!.isNotEmpty;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedDate = date;
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : (isToday
                                              ? theme.colorScheme.primary
                                                    .withValues(alpha: 0.15)
                                              : Colors.transparent),
                                    borderRadius: BorderRadius.circular(10),
                                    border: isToday && !isSelected
                                        ? Border.all(
                                            color: theme.colorScheme.primary,
                                          )
                                        : null,
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Text(
                                        '$dayNumber',
                                        style: TextStyle(
                                          fontWeight: isSelected || isToday
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: isSelected
                                              ? Colors.white
                                              : theme.colorScheme.onSurface,
                                        ),
                                      ),
                                      if (hasEvents)
                                        Positioned(
                                          bottom: 4,
                                          child: Container(
                                            width: 5,
                                            height: 5,
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? theme.colorScheme.secondary
                                                  : theme.colorScheme.primary,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Eventos em ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Icon(
                          Icons.event_note,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: selectedEvents.isEmpty
                          ? Center(
                              child: Text(
                                'Nenhum evento agendado para este dia.',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: selectedEvents.length,
                              itemBuilder: (context, index) {
                                final event = selectedEvents[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  elevation: 0,
                                  color: theme.colorScheme.surface,
                                  child: ListTile(
                                    leading: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.access_time,
                                        color: theme.colorScheme.primary,
                                        size: 20,
                                      ),
                                    ),
                                    title: Text(
                                      event['title']!,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${event['time']} • ${event['tag']}',
                                    ),
                                    trailing: Icon(
                                      Icons.check_circle_outline,
                                      color: theme.colorScheme.secondary,
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AllEventsScreen extends StatefulWidget {
  final Map<String, List<Map<String, String>>> events;
  final VoidCallback onEventUpdate;

  const AllEventsScreen({
    super.key,
    required this.events,
    required this.onEventUpdate,
  });

  @override
  State<AllEventsScreen> createState() => _AllEventsScreenState();
}

class _AllEventsScreenState extends State<AllEventsScreen> {
  List<Map<String, dynamic>> _getUpcomingEvents() {
    final List<Map<String, dynamic>> upcoming = [];
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    widget.events.forEach((dateStr, eventList) {
      final parts = dateStr.split('-');
      final date = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );

      if (!date.isBefore(todayStart)) {
        for (int i = 0; i < eventList.length; i++) {
          upcoming.add({
            'dateKey': dateStr,
            'date': date,
            'index': i,
            'event': eventList[i],
          });
        }
      }
    });

    upcoming.sort(
      (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime),
    );
    return upcoming;
  }

  void _editEventDialog(
    String dateKey,
    int index,
    Map<String, String> currentEvent,
  ) {
    final titleController = TextEditingController(text: currentEvent['title']);
    final timeController = TextEditingController(text: currentEvent['time']);
    final tagController = TextEditingController(text: currentEvent['tag']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Evento'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Título'),
                ),
                TextField(
                  controller: timeController,
                  decoration: const InputDecoration(
                    labelText: 'Horário (ex: 14:00)',
                  ),
                ),
                TextField(
                  controller: tagController,
                  decoration: const InputDecoration(
                    labelText: 'Categoria / Tag',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  widget.events[dateKey]![index] = {
                    'title': titleController.text,
                    'time': timeController.text,
                    'tag': tagController.text,
                  };
                });
                widget.onEventUpdate();
                Navigator.pop(context);
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final upcomingEvents = _getUpcomingEvents();

    return Scaffold(
      appBar: AppBar(title: const Text('Próximos eventos')),
      body: upcomingEvents.isEmpty
          ? const Center(child: Text('Nenhum evento futuro encontrado'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: upcomingEvents.length,
              itemBuilder: (context, i) {
                final item = upcomingEvents[i];
                final DateTime date = item['date'];
                final Map<String, String> event = item['event'];

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text(
                        '${date.day}',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      event['title']!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} às ${event['time']} • ${event['tag']}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _editEventDialog(
                            item['dateKey'],
                            item['index'],
                            event,
                          ),
                          icon: const Icon(Icons.edit, color: Colors.blue),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              final String key = item['dateKey'];
                              widget.events[key]!.removeAt(item['index']);
                              if (widget.events[key]!.isEmpty) {
                                widget.events.remove(key);
                              }
                            });
                            widget.onEventUpdate();
                          },
                          icon: const Icon(Icons.delete, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
