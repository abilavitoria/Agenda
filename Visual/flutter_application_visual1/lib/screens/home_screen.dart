import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/auth_service.dart';
import '../services/event_service.dart';
import '../widgets/event_dialog.dart';
import '../widgets/voice_record_modal.dart';
import 'all_events_screen.dart';
import 'calendar_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const HomeScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _openVoiceModal() {
    VoiceRecordModal.show(context);
  }

  void _openCalendar() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CalendarScreen(
          onToggleTheme: widget.onToggleTheme,
          isDarkMode: widget.isDarkMode,
        ),
      ),
    );
  }

  void _openAllEvents({String? initialFilter}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllEventsScreen(
          onToggleTheme: widget.onToggleTheme,
          isDarkMode: widget.isDarkMode,
          initialStatusFilter: initialFilter ?? 'Todos',
        ),
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Encerrar Sessão'),
        content: const Text('Deseja realmente sair da sua conta?'),
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
              AuthService().logout();
              Navigator.pop(ctx);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginScreen(
                    onToggleTheme: widget.onToggleTheme,
                    isDarkMode: widget.isDarkMode,
                  ),
                ),
              );
            },
            child: const Text('Sair'),
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
    final authService = AuthService();
    final userName = authService.currentUser?.name ?? 'Usuário';

    return ListenableBuilder(
      listenable: eventService,
      builder: (context, _) {
        final nextEvent = eventService.getNextUpcomingEvent();
        final allEvents = eventService.events;
        final completedCount = allEvents.where((e) => e.isCompleted).length;
        final pendingCount = allEvents.length - completedCount;
        final todayEvents = allEvents.where((e) => e.isToday).length;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.calendar_today_rounded,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Minha Agenda',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            actions: [
              // Botão Alternar Tema
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

              // Botão Acessar Calendário Mensal
              IconButton(
                tooltip: 'Calendário',
                onPressed: _openCalendar,
                icon: Icon(Icons.calendar_month, color: colorScheme.primary),
              ),

              // Menu de Opções
              PopupMenuButton<String>(
                tooltip: 'Menu',
                icon: Icon(
                  Icons.more_vert,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                onSelected: (value) {
                  if (value == 'all_events') {
                    _openAllEvents();
                  } else if (value == 'calendar') {
                    _openCalendar();
                  } else if (value == 'logout') {
                    _handleLogout();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'all_events',
                    child: Row(
                      children: [
                        Icon(Icons.list_alt, size: 18),
                        SizedBox(width: 10),
                        Text('Todos os Eventos'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'calendar',
                    child: Row(
                      children: [
                        Icon(Icons.calendar_month, size: 18),
                        SizedBox(width: 10),
                        Text('Ver Calendário'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red, size: 18),
                        SizedBox(width: 10),
                        Text(
                          'Sair da Conta',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 6),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => EventDialog.show(context),
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
            tooltip: 'Adicionar Evento Manualmente',
            child: const Icon(Icons.add),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 12.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Banner de Boas-vindas
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Olá, $userName 👋',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Toque no botão central para ditar seu evento por voz',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Botão Central de Gravação de Voz (Pulsante e Elegante)
                  Center(
                    child: GestureDetector(
                      onTap: _openVoiceModal,
                      child: Builder(
                        builder: (context) {
                          final double size = MediaQuery.of(context).size.width * 0.4;
                          final double finalSize = size > 160 ? 160 : size;
                          
                          return Container(
                            width: finalSize,
                            height: finalSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colorScheme.primary,
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withValues(
                                    alpha: isDark ? 0.55 : 0.35,
                                  ),
                                  blurRadius: isDark ? 36 : 24,
                                  spreadRadius: isDark ? 8 : 4,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.mic,
                              size: finalSize * 0.5,
                              color: Colors.white,
                            ),
                          );
                        }
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Texto de Instrução do Microfone
                  InkWell(
                    onTap: _openVoiceModal,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            color: colorScheme.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Toque no microfone para ditar seu evento',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),

                  // Próximo Evento Agendado (Card Dinâmico)
                  _buildNextEventCard(
                    context,
                    nextEvent,
                    colorScheme,
                    isDark,
                    eventService,
                  ),
                  const SizedBox(height: 18),

                  // Estatísticas Rápidas
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'Pendentes',
                          value: '$pendingCount',
                          icon: Icons.pending_actions,
                          colorScheme: colorScheme,
                          isDark: isDark,
                          onTap: () => _openAllEvents(initialFilter: 'Pendentes'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Hoje',
                          value: '$todayEvents',
                          icon: Icons.today,
                          colorScheme: colorScheme,
                          isDark: isDark,
                          onTap: _openCalendar,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Concluídos',
                          value: '$completedCount',
                          icon: Icons.task_alt,
                          colorScheme: colorScheme,
                          isDark: isDark,
                          onTap: () => _openAllEvents(initialFilter: 'Concluídos'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Botão de Ver Todos os Eventos
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _openAllEvents(),
                      icon: const Icon(Icons.list_alt),
                      label: const Text('Ver Lista Completa de Eventos'),
                    ),
                  ),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNextEventCard(
    BuildContext context,
    EventModel? nextEvent,
    ColorScheme colorScheme,
    bool isDark,
    EventService eventService,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF14121E) : const Color(0xFFF3EFEA),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: isDark ? 0.4 : 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: nextEvent == null
          ? Row(
              children: [
                Icon(
                  Icons.event_available,
                  color: colorScheme.primary,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nenhum evento pendente',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sua agenda está livre!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : InkWell(
              onTap: () => EventDialog.show(context, eventToEdit: nextEvent),
              borderRadius: BorderRadius.circular(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.event_note,
                      color: colorScheme.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Próximo evento:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                nextEvent.category,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          nextEvent.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${nextEvent.formattedDate} às ${nextEvent.time}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Concluir evento',
                    icon: Icon(
                      nextEvent.isCompleted
                          ? Icons.check_circle
                          : Icons.check_circle_outline,
                      color: nextEvent.isCompleted
                          ? Colors.green
                          : colorScheme.primary,
                    ),
                    onPressed: () {
                      eventService.toggleEventCompleted(nextEvent.id);
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required ColorScheme colorScheme,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF14121E) : const Color(0xFFF3EFEA),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.2),
            width: 1.2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: colorScheme.primary, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}