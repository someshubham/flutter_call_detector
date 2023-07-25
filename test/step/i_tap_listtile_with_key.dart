import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> iTapListtileWithKey(WidgetTester tester, Key key) async {
  await tester.tap(find.byKey(key));
  await tester.pump();
}
