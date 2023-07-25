import 'package:flutter_call_detector/di.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> unregisterSingletons(WidgetTester tester) async {
  await AppInjector().unregisterSingeltons();
}
