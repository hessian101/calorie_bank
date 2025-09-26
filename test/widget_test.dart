import 'package:flutter_test/flutter_test.dart';

import 'package:calorie_bank_app/main.dart';

void main() {
  testWidgets('App loads and shows home screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CalorieBankApp());

    // Verify that the app title and navigation are present
    expect(find.text('カロリー貯金'), findsOneWidget);
    expect(find.text('ホーム'), findsOneWidget);
    expect(find.text('入金'), findsOneWidget);
    expect(find.text('引き落とし'), findsOneWidget);
    expect(find.text('履歴'), findsOneWidget);
    expect(find.text('設定'), findsOneWidget);
  });

  testWidgets('Navigation works between screens', (WidgetTester tester) async {
    await tester.pumpWidget(const CalorieBankApp());

    // Tap on deposit screen
    await tester.tap(find.text('入金'));
    await tester.pump();

    // Verify we're on the deposit screen
    expect(find.text('カロリー入金'), findsOneWidget);

    // Tap on withdrawal screen
    await tester.tap(find.text('引き落とし'));
    await tester.pump();

    // Verify we're on the withdrawal screen
    expect(find.text('カロリー引き落とし'), findsOneWidget);
  });
}
