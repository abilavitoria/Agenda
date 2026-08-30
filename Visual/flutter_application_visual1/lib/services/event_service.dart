import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event_model.dart';

class EventService extends ChangeNotifier {
  static final EventService _instance = EventService._internal();
  factory EventService() => _instance;

  EventService._internal() {
    _loadEventsFromStorage();
  }

  static const String _storageKey = 'agenda_events_storage_v1';
  final List<EventModel> _events = [];
  bool _isLoaded = false;

  List<EventModel> get events => List.unmodifiable(_events);
  bool get isLoaded => _isLoaded;

  Future<void> _loadEventsFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonString);
        _events.clear();
        _events.addAll(
          decoded.map((item) => EventModel.fromMap(item as Map<String, dynamic>)),
        );
      } else {
        _initSampleEvents();
        await _saveEventsToStorage();
      }
    } catch (e) {
      debugPrint('Erro ao carregar eventos do storage: $e');
      if (_events.isEmpty) {
        _initSampleEvents();
      }
    } finally {
      _isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> _saveEventsToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _events.map((e) => e.toMap()).toList();
      await prefs.setString(_storageKey, jsonEncode(list));
    } catch (e) {
      debugPrint('Erro ao salvar eventos no storage: $e');
    }
  }

  void _initSampleEvents() {
    final now = DateTime.now();
    _events.clear();
    _events.addAll([
      EventModel(
        id: '1',
        title: 'Reunião de Alinhamento',
        date: DateTime(now.year, now.month, (now.day + 1).clamp(1, 28)),
        time: '10:00',
        category: 'Trabalho',
        description: 'Alinhamento semanal de metas e sprints.',
        reminderMinutesBefore: 15,
      ),
      EventModel(
        id: '2',
        title: 'Consulta Médica com Cardiologista',
        date: DateTime(now.year, now.month, (now.day + 3).clamp(1, 28)),
        time: '14:30',
        category: 'Saúde',
        description: 'Exames de rotina no Hospital Central.',
        reminderMinutesBefore: 60,
      ),
      EventModel(
        id: '3',
        title: 'Treino na Academia',
        date: DateTime(now.year, now.month, now.day),
        time: '18:00',
        category: 'Pessoal',
        description: 'Treino de membros superiores e cardio.',
        reminderMinutesBefore: 30,
      ),
      EventModel(
        id: '4',
        title: 'Aniversário da Camila',
        date: DateTime(now.year, now.month, (now.day + 7).clamp(1, 28)),
        time: '20:00',
        category: 'Social',
        description: 'Jantar com amigos no restaurante italiano.',
        reminderMinutesBefore: 120,
      ),
      EventModel(
        id: '5',
        title: 'Casamento',
        date: DateTime(now.year + 1, 4, 20),
        time: '16:00',
        category: 'Social',
        description: 'Casamento especial da família.',
        reminderMinutesBefore: 1440,
      ),
    ]);
  }

  // Consulta por data específica
  List<EventModel> getEventsForDate(DateTime date) {
    return _events.where((e) {
      return e.date.year == date.year &&
          e.date.month == date.month &&
          e.date.day == date.day;
    }).toList()
      ..sort((a, b) => a.time.compareTo(b.time));
  }

  // Consulta por mês
  List<EventModel> getEventsForMonth(DateTime month) {
    return _events.where((e) {
      return e.date.year == month.year && e.date.month == month.month;
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  // Próximo evento futuro
  EventModel? getNextUpcomingEvent() {
    final now = DateTime.now();

    final futureEvents = _events.where((e) {
      return e.fullDateTime.isAfter(now) && !e.isCompleted;
    }).toList();

    if (futureEvents.isEmpty) {
      // Se não houver estritamente futuro, procura evento de hoje não concluído
      final todayEvents = _events.where((e) => e.isToday && !e.isCompleted).toList();
      if (todayEvents.isNotEmpty) {
        todayEvents.sort((a, b) => a.time.compareTo(b.time));
        return todayEvents.first;
      }
      return null;
    }

    futureEvents.sort((a, b) => a.fullDateTime.compareTo(b.fullDateTime));
    return futureEvents.first;
  }

  // Todos os eventos futuros
  List<EventModel> getUpcomingEvents() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    final upcoming = _events.where((e) => !e.date.isBefore(todayStart)).toList();
    upcoming.sort((a, b) => a.fullDateTime.compareTo(b.fullDateTime));
    return upcoming;
  }

  // Buscar evento por ID
  EventModel? getEventById(String id) {
    try {
      return _events.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  // Cadastrar Evento
  void addEvent(EventModel event) {
    _events.add(event);
    _saveEventsToStorage();
    notifyListeners();
  }

  // Atualizar Evento
  bool updateEvent(EventModel updated) {
    final index = _events.indexWhere((e) => e.id == updated.id);
    if (index != -1) {
      _events[index] = updated;
      _saveEventsToStorage();
      notifyListeners();
      return true;
    }
    return false;
  }

  // Deletar Evento (retorna o evento deletado para permitir Desfazer/Undo)
  EventModel? deleteEvent(String id) {
    final index = _events.indexWhere((e) => e.id == id);
    if (index != -1) {
      final removed = _events.removeAt(index);
      _saveEventsToStorage();
      notifyListeners();
      return removed;
    }
    return null;
  }

  // Restaurar Evento (para Desfazer Exclusão)
  void restoreEvent(EventModel event) {
    if (!_events.any((e) => e.id == event.id)) {
      _events.add(event);
      _saveEventsToStorage();
      notifyListeners();
    }
  }

  // Alternar Status de Concluído
  void toggleEventCompleted(String id) {
    final index = _events.indexWhere((e) => e.id == id);
    if (index != -1) {
      final current = _events[index];
      _events[index] = current.copyWith(isCompleted: !current.isCompleted);
      _saveEventsToStorage();
      notifyListeners();
    }
  }

  // Cadastro Rápido por Voz
  EventModel addEventFromVoice({
    required String title,
    required DateTime date,
    required String time,
    String category = 'Geral',
    String description = 'Criado via comando de voz',
    int reminderMinutesBefore = 30,
  }) {
    final newEvent = EventModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      date: date,
      time: time,
      category: category,
      description: description,
      reminderMinutesBefore: reminderMinutesBefore,
    );
    addEvent(newEvent);
    return newEvent;
  }
}
