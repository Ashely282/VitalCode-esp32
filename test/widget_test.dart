import 'package:flutter_test/flutter_test.dart';
import 'package:alt1/main.dart';

void main() {
  testWidgets('App renders Healthcare Companion App', (WidgetTester tester) async {
    await tester.pumpWidget(const HealthcareCompanionApp());
    expect(find.byType(HealthcareCompanionApp), findsOneWidget);
  });
}
