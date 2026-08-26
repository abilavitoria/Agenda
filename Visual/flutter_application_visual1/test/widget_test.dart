import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_visual1/main.dart';

void main() {
  testWidgets('Agenda App smoke test - verifies login screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(const AgendaApp());
    await tester.pumpAndSettle();

    expect(find.text('Agenda Prática'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
