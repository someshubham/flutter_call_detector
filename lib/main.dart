import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_call_detector/config/di.dart';
import 'package:flutter_call_detector/config/flavor.dart';
import 'package:flutter_call_detector/constants/hive_constants.dart';
import 'package:flutter_call_detector/modules/call_detector/screens/phone_call_detector_page.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  await Hive.initFlutter();
  await Hive.openBox(HiveConstants.phoneDataBox);
  AppInjector().configure(Flavor.prod);
  runApp(
    const MaterialApp(
      home: PhoneCallDetectorPage(),
    ),
  );
}
