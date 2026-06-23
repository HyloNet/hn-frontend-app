import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hyperlocal_news/main.dart';

void main() {
  testWidgets('App builds without error', (WidgetTester tester) async {
    await tester.pumpWidget(const HyperlocalNewsApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
