import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';
import '../widgets/event_dialog.dart';
import '../widgets/voice_record_modal.dart';

class AllEventsScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;
  final String initialStatusFilter;

  const AllEventsScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
    this.initialStatusFilter = 'Todos',
  });

  @override
  State<AllEventsScreen> createState() => _AllEventsScreenState();
}

class _AllEventsScreenState extends State<AllEventsScreen> {
  String _selectedCategory = 'Todas';
  late String _statusFilter;
  String _sortOrder = 'date_asc'; // 'date_asc', 'date_desc', 'title'
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

  final List<String> _statusOptions = const [
    'Todos',
    'Pendentes',
    'Concluídos',
  ];

  @override
  void initState() {
    super.initState();
    _statusFilter = widget.initialStatusFilter;
  }

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
              final deleted = EventService().deleteEvent(event.id);
              Navigator.pop(ctx);

              if (deleted != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Evento "${event.title}" excluído'),
                    action: SnackBarAction(
                      label: 'DESFAZER',
                      textColor: Colors.amber,
                      onPressed: () {
                        EventService().restoreEvent(deleted);
                      },
                    ),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
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
        var filteredList = List<EventModel>.from(eventService.events);

        // 1. Filtro de Status (Todos, Pendentes, Concluídos)
        if (_statusFilter == 'Pendentes') {
          filteredList = filteredList.where((e) => !e.isCompleted).toList();
        } else if (_statusFilter == 'Concluídos') {
          filteredList = filteredList.where((e) => e.isCompleted).toList();
        }

        // 2. Filtro de Categoria
        if (_selectedCategory != 'Todas') {
          filteredList = filteredList
              .where((e) => e.category == _selectedCategory)
              .toList();
        }

        // 3. Filtro de Busca
        if (_searchQuery.trim().isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          filteredList = filteredList
              .where((e) =>
                  e.title.toLowerCase().contains(query) ||
                  e.description.toLowerCase().contains(query) ||
                  e.category.toLowerCase().contains(query))
              .toList();
        }

        // 4. Ordenação
        if (_sortOrder == 'date_asc') {
          filteredList.sort((a, b) => a.fullDateTime.compareTo(b.fullDateTime));
        } else if (_sortOrder == 'date_desc') {
          filteredList.sort((a, b) => b.fullDateTime.compareTo(a.fullDateTime));
        } else if (_sortOrder == 'title') {
          filteredList.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        }

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
                tooltip: 'Ditar evento por voz',
                icon: const Icon(Icons.mic),
                onPressed: () => VoiceRecordModal.show(context),
              ),
              IconButton(
                tooltip: isDark ? 'Modo Claro' : 'Modo Escuro',
                onPressed: widget.onToggleTheme,
                icon: Icon(
                  isDark ? Icons.light_mode : Icons.dark_mode,
                  color: isDark
                      ? const Color(0xFFFFD166)
                      : colorScheme.primary,
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Ordenar eventos',
                icon: const Icon(Icons.sort),
                onSelected: (val) {
                  setState(() => _sortOrder = val);
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: 'date_asc',
                    child: Row(
                      children: [
                        Icon(
                          Icons.arrow_upward,
                          size: 18,
                          color: _sortOrder == 'date_asc'
                              ? colorScheme.primary
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Mais próximos primeiro',
                          style: TextStyle(
                            fontWeight: _sortOrder == 'date_asc'
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'date_desc',
                    child: Row(
                      children: [
                        Icon(
                          Icons.arrow_downward,
                          size: 18,
                          color: _sortOrder == 'date_desc'
                              ? colorScheme.primary
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Mais distantes primeiro',
                          style: TextStyle(
                            fontWeight: _sortOrder == 'date_desc'
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'title',
                    child: Row(
                      children: [
                        Icon(
                          Icons.sort_by_alpha,
                          size: 18,
                          color: _sortOrder == 'title'
                              ? colorScheme.primary
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Ordem alfabética (A-Z)',
                          style: TextStyle(
                            fontWeight: _sortOrder == 'title'
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => EventDialog.show(context),
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
                // Barra de Busca
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    style: TextStyle(color: colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Pesquisar por título, notas ou categoria...',
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

                // Filtros de Status (Chips: Todos, Pendentes, Concluídos)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: Row(
                    children: _statusOptions.map((status) {
                      final isSelected = _statusFilter == status;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(
                            status,
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected
                                  ? Colors.white
                                  : colorScheme.onSurface,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: colorScheme.primary,
                          checkmarkColor: Colors.white,
                          backgroundColor: isDark
                              ? const Color(0xFF1F1B2C)
                              : const Color(0xFFE5DDD0),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _statusFilter = status);
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Filtros de Categoria (Chips horizontais)
                SizedBox(
                  height: 44,
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
                              fontSize: 12,
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
                const SizedBox(height: 6),

                // Contador de Resultados
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${filteredList.length} evento(s) encontrado(s)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),

                // Lista de Eventos
                Expanded(
                  child: filteredList.isEmpty
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
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            final event = filteredList[index];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                onTap: () => EventDialog.show(
                                  context,
                                  eventToEdit: event,
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
                                    Row(
                                      children: [
                                        Text(
                                          '${event.formattedDate} às ${event.time}  •  ',
                                          style: TextStyle(
                                            color: colorScheme.primary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 7,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: colorScheme.primary
                                                .withValues(alpha: 0.12),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            event.category,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: colorScheme.primary,
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
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      tooltip: event.isCompleted
                                          ? 'Marcar como pendente'
                                          : 'Marcar como concluído',
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
    return abbrs[(month - 1).clamp(0, 11)];
  }
}
