import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> iSeeListtileWidgetIsSelected(WidgetTester tester) async {
  Finder finder = find.byWidgetPredicate((w) => w is ListTile && w.selected);
  expect(finder, findsOneWidget);
}
