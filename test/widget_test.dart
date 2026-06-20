import 'package:flutter_test/flutter_test.dart';

import 'package:popishop_flutter/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PopiDigicamApp());
    expect(find.byType(PopiDigicamApp), findsOneWidget);
  });
}
