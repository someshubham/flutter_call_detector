import 'package:flutter_test/flutter_test.dart';

Future<void> iSeeWidgetTimes(WidgetTester tester, Type type, int n) async {
  expect(find.byType(type), findsNWidgets(n));
}
