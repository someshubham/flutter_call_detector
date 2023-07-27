import 'package:flutter/material.dart';
import 'package:flutter_call_detector/config/di.dart';
import 'package:flutter_call_detector/config/flavor.dart';
import 'package:flutter_call_detector/modules/call_detector/screens/phone_call_detector_page.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> theAppIsRunningWithFlavor(
    WidgetTester tester, Flavor flavor) async {
  await AppInjector().configure(flavor);
  await tester.pumpWidget(
    const MaterialApp(
      home: PhoneCallDetectorPage(),
    ),
  );
}
