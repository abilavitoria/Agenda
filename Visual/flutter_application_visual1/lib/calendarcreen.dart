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
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
  ];

  final List<String> _weekDays = const ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];

  void _changeMonth(int increment) {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + increment, 1);
      _selectedDate = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    });
  }

  String _formatDateKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final firstWeekday = DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday % 7;

    final selectedKey = _formatDateKey(_selectedDate);
    final selectedEvents = _events[selectedKey] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendário & Agenda'),
        centerTitle: true,
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
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              childAspectRatio: 1.0,
                            ),
                            itemCount: daysInMonth + firstWeekday,
                            itemBuilder: (context, index) {
                              if (index < firstWeekday) {
                                return const SizedBox.shrink();
                              }

                              final dayNumber = index - firstWeekday + 1;
                              final date = DateTime(_focusedMonth.year, _focusedMonth.month, dayNumber);
                              final isSelected = date.year == _selectedDate.year &&
                                  date.month == _selectedDate.month &&
                                  date.day == _selectedDate.day;
                              final isToday = date.year == DateTime.now().year &&
                                  date.month == DateTime.now().month &&
                                  date.day == DateTime.now().day;

                              final dateKey = _formatDateKey(date);
                              final hasEvents = _events.containsKey(dateKey) && _events[dateKey]!.isNotEmpty;

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
                                            ? theme.colorScheme.primary.withValues(alpha: 0.15)
                                            : Colors.transparent),
                                    borderRadius: BorderRadius.circular(10),
                                    border: isToday && !isSelected
                                        ? Border.all(color: theme.colorScheme.primary)
                                        : null,
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Text(
                                        '$dayNumber',
                                        style: TextStyle(
                                          fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
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
                                              color: isSelected ? theme.colorScheme.secondary : theme.colorScheme.primary,
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
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: selectedEvents.length,
                              itemBuilder: (context, index) {
                                final event = selectedEvents[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  elevation: 0,
                                  color: theme.colorScheme.surface,
                                  child: ListTile(
                                    leading: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
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
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text('${event['time']} • ${event['tag']}'),
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