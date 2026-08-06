import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_3/main.dart';

void main() {
  testWidgets('App launches to HomeScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    expect(find.text('Willkommen!'), findsOneWidget);
  });
}
