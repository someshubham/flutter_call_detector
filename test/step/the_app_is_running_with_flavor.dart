import 'package:flutter/material.dart';
import 'package:flutter_call_detector/di.dart';
import 'package:flutter_call_detector/flavor.dart';
import 'package:flutter_call_detector/main.dart';
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
