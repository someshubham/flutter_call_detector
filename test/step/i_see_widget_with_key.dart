import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> iSeeWidgetWithKey(WidgetTester tester, Key key) async {
  expect(find.byKey(key), findsOneWidget);
}
