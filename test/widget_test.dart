import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buddy/app/app.dart';

void main() {
  testWidgets('Buddy app launches', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: BuddyApp()));
    expect(find.text('Buddy'), findsOneWidget);
  });
}
