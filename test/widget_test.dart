import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/app.dart';

void main() {
  testWidgets('Schedule page renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    expect(find.text('Schedule'), findsOneWidget);
  });
}
