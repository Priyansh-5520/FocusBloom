import 'package:flutter_test/flutter_test.dart';
import 'package:focus_bloom/main.dart';

void main() {
  testWidgets('FocusBloomApp initial widget build smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FocusBloomApp());
    expect(find.byType(FocusBloomApp), findsOneWidget);
  });
}
