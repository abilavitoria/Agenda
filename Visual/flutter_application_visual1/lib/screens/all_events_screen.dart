import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';
import '../widgets/event_dialog.dart';

class AllEventsScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const AllEventsScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<AllEventsScreen> createState() => _AllEventsScreenState();
}

class _AllEventsScreenState extends State<AllEventsScreen> {
  String _selectedCategory = 'Todas';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = const [
    'Todas',
    'Trabalho',
    'Pessoal',
    'Saúde',
    'Social',
    'Estudo',
    'Geral',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

    return ListenableBuilder(
      listenable: eventService,
      builder: (context, _) {
        var allEvents = List<EventModel>.from(eventService.events);

        // Filtro de Categoria
        if (_selectedCategory != 'Todas') {
          allEvents = allEvents
              .where((e) => e.category == _selectedCategory)
              .toList();
        }

        // Filtro de Busca
        if (_searchQuery.trim().isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          allEvents = allEvents
              .where((e) =>
                  e.title.toLowerCase().contains(query) ||
                  e.description.toLowerCase().contains(query))
              .toList();
        }

        // Ordenação por data/hora
        allEvents.sort((a, b) => a.fullDateTime.compareTo(b.fullDateTime));

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: const Text('Todos os Eventos'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                onPressed: widget.onToggleTheme,
                icon: Icon(
                  isDark ? Icons.light_mode : Icons.dark_mode,
                  color: isDark
                      ? const Color(0xFFFFD166)
                      : colorScheme.primary,
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => EventDialog.show(context),
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
            child: const Icon(Icons.add),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Barra de Busca
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    style: TextStyle(color: colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Pesquisar eventos...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                    ),
                  ),
                ),

                // Filtros de Categoria (Chips horizontais)
                SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = _selectedCategory == cat;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ChoiceChip(
                          label: Text(
                            cat,
                            style: TextStyle(
                              color: isSelected
                                  ? (isDark ? Colors.black : Colors.white)
                                  : colorScheme.onSurface,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
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
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),

                // Lista de Eventos
                Expanded(
                  child: allEvents.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 52,
                                color: colorScheme.primary
                                    .withValues(alpha: 0.4),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Nenhum evento encontrado',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tente outro termo ou categoria',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: allEvents.length,
                          itemBuilder: (context, index) {
                            final event = allEvents[index];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                leading: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: colorScheme.primary
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${event.date.day}',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.primary,
                                          ),
                                        ),
                                        Text(
                                          _getMonthAbbr(event.date.month),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: colorScheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                title: Text(
                                  event.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
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
                                    Text(
                                      '${event.formattedDate} às ${event.time} • ${event.category}',
                                      style: TextStyle(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                    if (event.description.isNotEmpty) ...[
                                      const SizedBox(height: 3),
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
                                        eventService.toggleEventCompleted(
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
                                              Icon(Icons.edit, size: 18),
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
        );
      },
    );
  }

  String _getMonthAbbr(int month) {
    const abbrs = [
      'JAN',
      'FEV',
      'MAR',
      'ABR',
      'MAI',
      'JUN',
      'JUL',
      'AGO',
      'SET',
      'OUT',
      'NOV',
      'DEZ',
    ];
    return abbrs[month - 1];
  }
}
