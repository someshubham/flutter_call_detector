import 'package:flutter_call_detector/di.dart';
import 'package:flutter_call_detector/flavor.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> theAppIsConfiguredWithFlavor(
    WidgetTester tester, Flavor flavor) async {
  await AppInjector().configure(flavor);
}
