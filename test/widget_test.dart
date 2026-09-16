import 'package:flutter_test/flutter_test.dart';
import 'package:readysafe/app/app.dart';

void main() {
  testWidgets('home exposes emergency preparation sections', (tester) async {
    await tester.pumpWidget(const ReadySafeApp());
    await tester.pumpAndSettle();
    expect(find.text('READYSAFE'), findsOneWidget);
    expect(find.text('Urgences'), findsOneWidget);
    expect(find.text('Kit d’urgence'), findsOneWidget);
  });
}
