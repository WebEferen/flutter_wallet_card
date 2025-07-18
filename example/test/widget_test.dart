// This is a basic test file for the Flutter Wallet Card example app.
// You can add your widget tests here.

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_wallet_card_example/main.dart';

void main() {
  testWidgets('Flutter Wallet Card Example app smoke test',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that the app title is displayed.
    expect(find.text('Flutter Wallet Card Example'), findsOneWidget);

    // Verify that the main buttons are present.
    expect(find.text('Add apple pass'), findsWidgets);
    expect(find.text('Add apple pass (from path)'), findsOneWidget);
    expect(find.text('Validate Pass File'), findsOneWidget);
    expect(find.text('Check Pass Validity'), findsOneWidget);

    // Verify that descriptive text is present.
    expect(find.text('Apple wallet cards using URL'), findsOneWidget);
    expect(find.text('Apple wallet cards using File Path'), findsOneWidget);
    expect(find.text('iOS Enhanced Features'), findsOneWidget);
  });
}
