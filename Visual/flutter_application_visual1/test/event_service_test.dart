import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_visual1/models/event_model.dart';
import 'package:flutter_application_visual1/services/event_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('EventModel and EventService CRUD Tests', () {
    test('EventModel correctly formats dates and dateKey', () {
      final event = EventModel(
        id: 'test-1',
        title: 'Dentista',
        date: DateTime(2026, 4, 15),
        time: '14:30',
        category: 'Saúde',
      );

      expect(event.dateKey, '2026-04-15');
      expect(event.formattedDate, '15/04/2026');
      expect(event.fullDateTime, DateTime(2026, 4, 15, 14, 30));
    });

    test('EventService CRUD operations work properly', () {
      final service = EventService();

      // Create
      final newEvent = EventModel(
        id: 'crud-1',
        title: 'Entrevista de Emprego',
        date: DateTime(2026, 9, 10),
        time: '09:00',
        category: 'Trabalho',
        description: 'Vaga sênior',
      );
      service.addEvent(newEvent);

      final found = service.getEventById('crud-1');
      expect(found, isNotNull);
      expect(found!.title, 'Entrevista de Emprego');

      // Read / Query
      final dateEvents = service.getEventsForDate(DateTime(2026, 9, 10));
      expect(dateEvents.any((e) => e.id == 'crud-1'), isTrue);

      // Update
      final updated = newEvent.copyWith(title: 'Entrevista de Emprego Remota');
      service.updateEvent(updated);
      expect(service.getEventById('crud-1')!.title, 'Entrevista de Emprego Remota');

      // Toggle Complete
      service.toggleEventCompleted('crud-1');
      expect(service.getEventById('crud-1')!.isCompleted, isTrue);

      // Delete
      final deleted = service.deleteEvent('crud-1');
      expect(deleted, isNotNull);
      expect(service.getEventById('crud-1'), isNull);

      // Restore (Undo)
      service.restoreEvent(deleted!);
      expect(service.getEventById('crud-1'), isNotNull);
    });
  });
}
