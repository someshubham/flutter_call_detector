import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_call_detector/main.dart';

Future<void> theAppIsRunning(WidgetTester tester) async {
  await tester.pumpWidget(
    const MaterialApp(
      home: PhoneCallDetectorPage(),
    ),
  );
}
