import 'package:flutter/material.dart';
import 'package:flutter_call_detector/modules/call_detector/screens/phone_call_detector_page.dart';
import 'package:flutter_test/flutter_test.dart';


Future<void> theAppIsRunning(WidgetTester tester) async {
  await tester.pumpWidget(
    const MaterialApp(
      home: PhoneCallDetectorPage(),
    ),
  );
}
