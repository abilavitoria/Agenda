import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_visual1/services/voice_event_parser.dart';

void main() {
  group('VoiceEventParser Tests', () {
    test('Parses tomorrow meeting at 14:30', () {
      final result = VoiceEventParser.parse('Reunião de alinhamento com a diretoria amanhã às 14:30');

      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));

      expect(result.category, 'Trabalho');
      expect(result.time, '14:30');
      expect(result.date.year, tomorrow.year);
      expect(result.date.month, tomorrow.month);
      expect(result.date.day, tomorrow.day);
      expect(result.title.contains('Reunião'), isTrue);
    });

    test('Parses doctor appointment with specific day', () {
      final result = VoiceEventParser.parse('Consulta médica dia 15 de abril às 10 horas');

      expect(result.category, 'Saúde');
      expect(result.time, '10:00');
      expect(result.date.month, 4);
      expect(result.date.day, 15);
      expect(result.title.toLowerCase().contains('consulta'), isTrue);
    });

    test('Parses gym workout today at 8 PM', () {
      final result = VoiceEventParser.parse('Treino de perna hoje às 8 da noite');

      final now = DateTime.now();
      expect(result.category, 'Pessoal');
      expect(result.time, '20:00');
      expect(result.date.day, now.day);
      expect(result.title.toLowerCase().contains('treino'), isTrue);
    });

    test('Parses study session with test keyword', () {
      final result = VoiceEventParser.parse('Estudar para a prova de cálculo amanhã às 15h');

      expect(result.category, 'Estudo');
      expect(result.time, '15:00');
      expect(result.title.toLowerCase().contains('estudar'), isTrue);
    });

    test('Parses birthday party on saturday at 20h', () {
      final result = VoiceEventParser.parse('Aniversário do Lucas no sábado às 20 horas');

      expect(result.category, 'Social');
      expect(result.time, '20:00');
      expect(result.title.toLowerCase().contains('aniversário'), isTrue);
    });

    test('Parses lunch at noon', () {
      final result = VoiceEventParser.parse('Almoço em família amanhã ao meio dia');

      expect(result.category, 'Social');
      expect(result.time, '12:00');
    });
  });
}
