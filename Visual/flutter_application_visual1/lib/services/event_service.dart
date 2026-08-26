import 'package:flutter/material.dart';
import '../models/event_model.dart';

class EventService extends ChangeNotifier {
  static final EventService _instance = EventService._internal();
  factory EventService() => _instance;

  EventService._internal() {
    _initSampleEvents();
  }

  final List<EventModel> _events = [];

  List<EventModel> get events => List.unmodifiable(_events);

  void _initSampleEvents() {
    final now = DateTime.now();
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

  Map<String, List<EventModel>> get eventsByDate {
    final map = <String, List<EventModel>>{};
    for (final event in _events) {
      final key = event.dateKey;
      if (!map.containsKey(key)) {
        map[key] = [];
      }
      map[key]!.add(event);
    }
    return map;
  }

  List<EventModel> getEventsForDate(DateTime date) {
    final key =
        '--';
    return _events.where((e) => e.dateKey == key).toList()
      ..sort((a, b) => a.time.compareTo(b.time));
  }

  List<EventModel> getEventsForMonth(DateTime month) {
    return _events
        .where((e) => e.date.year == month.year && e.date.month == month.month)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  EventModel? getNextUpcomingEvent() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    final futureEvents = _events.where((e) {
      return !e.date.isBefore(todayStart) && !e.isCompleted;
    }).toList();

    if (futureEvents.isEmpty) return null;

    futureEvents.sort((a, b) => a.fullDateTime.compareTo(b.fullDateTime));
    return futureEvents.first;
  }

  List<EventModel> getUpcomingEvents() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    final upcoming = _events.where((e) => !e.date.isBefore(todayStart)).toList();
    upcoming.sort((a, b) => a.fullDateTime.compareTo(b.fullDateTime));
    return upcoming;
  }

  void addEvent(EventModel event) {
    _events.add(event);
    notifyListeners();
  }

  void updateEvent(EventModel updated) {
    final index = _events.indexWhere((e) => e.id == updated.id);
    if (index != -1) {
      _events[index] = updated;
      notifyListeners();
    }
  }

  void deleteEvent(String id) {
    _events.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void toggleEventCompleted(String id) {
    final index = _events.indexWhere((e) => e.id == id);
    if (index != -1) {
      final current = _events[index];
      _events[index] = current.copyWith(isCompleted: !current.isCompleted);
      notifyListeners();
    }
  }

  void addEventFromVoice({
    required String title,
    required DateTime date,
    required String time,
    String category = 'Geral',
    String description = 'Criado via comando de voz',
  }) {
    final newEvent = EventModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      date: date,
      time: time,
      category: category,
      description: description,
    );
    addEvent(newEvent);
  }
}
