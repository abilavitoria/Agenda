import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';
import '../widgets/event_dialog.dart';
import '../widgets/voice_record_modal.dart';
import 'all_events_screen.dart';

class CalendarScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const CalendarScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _focusedMonth;
  late DateTime _selectedDate;

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

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month, 1);
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

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

  void _goToToday() {
    final now = DateTime.now();
    setState(() {
      _focusedMonth = DateTime(now.year, now.month, 1);
      _selectedDate = DateTime(now.year, now.month, now.day);
    });
  }

  void _deleteEventConfirm(BuildContext context, EventModel event) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Evento'),
        content: Text('Deseja realmente excluir "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              EventService().deleteEvent(event.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Evento excluído com sucesso'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = widget.isDarkMode;
    final eventService = EventService();

    final daysInMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month + 1,
      0,
    ).day;

    final firstWeekday =
        DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday % 7;

    return ListenableBuilder(
      listenable: eventService,
      builder: (context, _) {
        final selectedDayEvents =
            eventService.getEventsForDate(_selectedDate);

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: const Text('Calendário Mensal'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                tooltip: 'Ir para hoje',
                icon: const Icon(Icons.today),
                onPressed: _goToToday,
              ),
              IconButton(
                tooltip: 'Todos os eventos',
                icon: const Icon(Icons.format_list_bulleted),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AllEventsScreen(
                        onToggleTheme: widget.onToggleTheme,
                        isDarkMode: widget.isDarkMode,
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                tooltip: 'Ditar evento',
                icon: const Icon(Icons.mic),
                onPressed: () => VoiceRecordModal.show(context),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => EventDialog.show(
              context,
              initialDate: _selectedDate,
            ),
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text(
              'Novo Evento',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Calendário Mensal
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14.0,
                    vertical: 8.0,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF14121E)
                          : const Color(0xFFF3EFEA),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.25),
                        width: 1.2,
                      ),
                    ),
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Navegação do Mês / Ano
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left, size: 28),
                              color: colorScheme.primary,
                              onPressed: () => _changeMonth(-1),
                            ),
                            Text(
                              '${_monthNames[_focusedMonth.month - 1]} ${_focusedMonth.year}',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right, size: 28),
                              color: colorScheme.primary,
                              onPressed: () => _changeMonth(1),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Cabeçalho dos dias da semana
                        Row(
                          children: _weekDays.map((day) {
                            final isWeekend = day == 'Dom' || day == 'Sáb';
                            return Expanded(
                              child: Center(
                                child: Text(
                                  day,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isWeekend
                                        ? colorScheme.primary
                                        : colorScheme.onSurface.withValues(
                                            alpha: 0.8,
                                          ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 6),
                        Divider(
                          color: colorScheme.primary.withValues(alpha: 0.15),
                          height: 1,
                        ),
                        const SizedBox(height: 8),

                        // Grade dos dias do mês
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            childAspectRatio: 1.15,
                            crossAxisSpacing: 4,
                            mainAxisSpacing: 4,
                          ),
                          itemCount: daysInMonth + firstWeekday,
                          itemBuilder: (context, index) {
                            if (index < firstWeekday) {
                              return const SizedBox.shrink();
                            }

                            final dayNumber = index - firstWeekday + 1;
                            final cellDate = DateTime(
                              _focusedMonth.year,
                              _focusedMonth.month,
                              dayNumber,
                            );

                            final isSelected =
                                cellDate.year == _selectedDate.year &&
                                cellDate.month == _selectedDate.month &&
                                cellDate.day == _selectedDate.day;

                            final now = DateTime.now();
                            final isToday =
                                cellDate.year == now.year &&
                                cellDate.month == now.month &&
                                cellDate.day == now.day;

                            final dayEvents =
                                eventService.getEventsForDate(cellDate);
                            final hasEvents = dayEvents.isNotEmpty;

                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedDate = cellDate;
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? colorScheme.primary
                                      : (isToday
                                          ? colorScheme.primary
                                              .withValues(alpha: 0.15)
                                          : Colors.transparent),
                                  borderRadius: BorderRadius.circular(12),
                                  border: isToday && !isSelected
                                      ? Border.all(
                                          color: colorScheme.primary,
                                          width: 1.5,
                                        )
                                      : null,
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Text(
                                      '$dayNumber',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isSelected || isToday
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? Colors.white
                                            : colorScheme.onSurface,
                                      ),
                                    ),
                                    if (hasEvents)
                                      Positioned(
                                        bottom: 3,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: List.generate(
                                            dayEvents.length.clamp(1, 3),
                                            (i) => Container(
                                              width: 5,
                                              height: 5,
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 1,
                                              ),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: isSelected
                                                    ? Colors.white
                                                    : colorScheme.primary,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Seção de Eventos do Dia Selecionado
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF14121E)
                          : const Color(0xFFF3EFEA),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                      border: Border(
                        top: BorderSide(
                          color: colorScheme.primary.withValues(alpha: 0.25),
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cabeçalho da Lista do Dia
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Eventos em ${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primary
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${selectedDayEvents.length} evento(s)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Lista de Eventos ou Mensagem Vazia
                        Expanded(
                          child: selectedDayEvents.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.event_available,
                                        size: 48,
                                        color: colorScheme.primary
                                            .withValues(alpha: 0.4),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Nenhum evento para este dia',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.onSurface
                                              .withValues(alpha: 0.7),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Toque em "Novo Evento" para agendar',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: colorScheme.onSurface
                                              .withValues(alpha: 0.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.only(bottom: 80),
                                  itemCount: selectedDayEvents.length,
                                  itemBuilder: (context, index) {
                                    final event = selectedDayEvents[index];
                                    return Card(
                                      margin:
                                          const EdgeInsets.only(bottom: 10),
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 6,
                                        ),
                                        leading: Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: colorScheme.primary
                                                .withValues(alpha: 0.15),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            Icons.access_time_filled,
                                            color: colorScheme.primary,
                                            size: 22,
                                          ),
                                        ),
                                        title: Text(
                                          event.title,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            decoration: event.isCompleted
                                                ? TextDecoration.lineThrough
                                                : null,
                                            color: event.isCompleted
                                                ? colorScheme.onSurface
                                                    .withValues(alpha: 0.5)
                                                : colorScheme.onSurface,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Text(
                                                  '${event.time}  •  ',
                                                  style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.w600,
                                                    color: colorScheme.primary,
                                                  ),
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: colorScheme.primary
                                                        .withValues(alpha: 0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      8,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    event.category,
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          colorScheme.primary,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (event.description.isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                event.description,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: colorScheme.onSurface
                                                      .withValues(alpha: 0.7),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                event.isCompleted
                                                    ? Icons.check_circle
                                                    : Icons.check_circle_outline,
                                                color: event.isCompleted
                                                    ? Colors.green
                                                    : colorScheme.primary,
                                              ),
                                              onPressed: () {
                                                eventService
                                                    .toggleEventCompleted(
                                                  event.id,
                                                );
                                              },
                                            ),
                                            PopupMenuButton<String>(
                                              icon: Icon(
                                                Icons.more_vert,
                                                color: colorScheme.onSurface,
                                              ),
                                              onSelected: (val) {
                                                if (val == 'edit') {
                                                  EventDialog.show(
                                                    context,
                                                    eventToEdit: event,
                                                  );
                                                } else if (val == 'delete') {
                                                  _deleteEventConfirm(
                                                    context,
                                                    event,
                                                  );
                                                }
                                              },
                                              itemBuilder: (ctx) => [
                                                const PopupMenuItem(
                                                  value: 'edit',
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.edit,
                                                        size: 18,
                                                      ),
                                                      SizedBox(width: 8),
                                                      Text('Editar'),
                                                    ],
                                                  ),
                                                ),
                                                const PopupMenuItem(
                                                  value: 'delete',
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.delete,
                                                        size: 18,
                                                        color: Colors.red,
                                                      ),
                                                      SizedBox(width: 8),
                                                      Text(
                                                        'Excluir',
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
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
              ],
            ),
          ),
        );
      },
    );
  }
}
