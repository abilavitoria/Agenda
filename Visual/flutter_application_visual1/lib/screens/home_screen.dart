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

  void _openAllEvents() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllEventsScreen(
          onToggleTheme: widget.onToggleTheme,
          isDarkMode: widget.isDarkMode,
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

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Row(
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
                const SizedBox(width: 10),
                Text(
                  'Minha Agenda',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
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
              Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: TextButton.icon(
                  onPressed: _openCalendar,
                  icon: Icon(Icons.calendar_month, color: colorScheme.primary),
                  label: Text(
                    'Calendário',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor:
                        colorScheme.primary.withValues(alpha: 0.12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),

              // Botão Logout
              IconButton(
                tooltip: 'Sair da conta',
                icon: Icon(
                  Icons.logout,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  size: 20,
                ),
                onPressed: _handleLogout,
              ),
              const SizedBox(width: 4),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => EventDialog.show(context),
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
            tooltip: 'Adicionar Evento',
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
                      child: Container(
                        width: 160,
                        height: 160,
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
                        child: const Icon(
                          Icons.mic,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Texto de Instrução do Microfone
                  Text(
                    'Toque no microfone para ditar seu evento',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Próximo Evento Agendado (Card Dinâmico)
                  _buildNextEventCard(
                    context,
                    nextEvent,
                    colorScheme,
                    isDark,
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
                          onTap: _openAllEvents,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Concluídos',
                          value: '$completedCount',
                          icon: Icons.task_alt,
                          colorScheme: colorScheme,
                          isDark: isDark,
                          onTap: _openAllEvents,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Calendário',
                          value: '${allEvents.length}',
                          icon: Icons.calendar_month,
                          colorScheme: colorScheme,
                          isDark: isDark,
                          onTap: _openCalendar,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Botão de Ver Todos os Eventos
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _openAllEvents,
                      icon: const Icon(Icons.list_alt),
                      label: const Text('Ver Lista Completa de Eventos'),
                    ),
                  ),
                  const SizedBox(height: 40),
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
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
                        'Nenhum evento futuro',
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
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Próximo evento:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${nextEvent.title} - ${nextEvent.formattedDate}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Horário: ${nextEvent.time} • ${nextEvent.category}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
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
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
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
