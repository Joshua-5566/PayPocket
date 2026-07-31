import 'package:flutter_test/flutter_test.dart';
import 'package:pocketpay/app.dart';

void main() {
  testWidgets('shows dashboard greeting', (tester) async {
    await tester.pumpWidget(const PocketPayApp());
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Hello Joshua 👋'), findsOneWidget);
    expect(find.text('Recent Transactions'), findsOneWidget);
  });
}
