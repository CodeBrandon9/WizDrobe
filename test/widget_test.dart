// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wizdrobe/main.dart';

void main() {
  testWidgets('Wardrobe screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const WizdrobeApp());

    expect(find.text('My Wardrobe'), findsOneWidget);
    expect(find.text('No items in your wardrobe yet.'), findsOneWidget);
    expect(find.byIcon(Icons.checkroom_outlined), findsWidgets);
  });
}
