// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_import, directives_ordering

import 'package:flutter_call_detector/flavor.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/the_app_is_configured_with_flavor.dart';
import './step/unregister_singletons.dart';
import './step/the_app_is_running.dart';
import './step/i_see_widget.dart';
import './step/i_wait.dart';
import './step/i_see_widget_with_key.dart';
import './step/i_enter_into_input_field.dart';
import './step/i_tap_text.dart';
import './step/i_see_widget_times.dart';
import './step/i_tap_listtile_with_key.dart';
import './step/i_see_listtile_widget_is_selected.dart';
import './step/i_see_text.dart';

void main() {
  group('''Phone Call Detector Page''', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await theAppIsConfiguredWithFlavor(tester, Flavor.mock);
    }
    Future<void> bddTearDown(WidgetTester tester) async {
      await unregisterSingletons(tester);
    }
    testWidgets('''There is a TextField for entering message with a Key''', (tester) async {
      try {
        await bddSetUp(tester);
        await theAppIsRunning(tester);
        await iSeeWidget(tester, TextField);
      } finally {
        await bddTearDown(tester);
      }
    });
    testWidgets('''There is a widget offstage when the message list is empty''', (tester) async {
      try {
        await bddSetUp(tester);
        await theAppIsRunning(tester);
        await iWait(tester);
        await iSeeWidgetWithKey(tester, ValueKey("list-offstage"));
      } finally {
        await bddTearDown(tester);
      }
    });
    testWidgets('''Adding new custom message and viewing list''', (tester) async {
      try {
        await bddSetUp(tester);
        await theAppIsRunning(tester);
        await iEnterIntoInputField(tester, "message", 0);
        await iTapText(tester, "Save");
        await iWait(tester);
        await iSeeWidget(tester, ListTile);
      } finally {
        await bddTearDown(tester);
      }
    });
    testWidgets('''Adding two custom messages''', (tester) async {
      try {
        await bddSetUp(tester);
        await theAppIsRunning(tester);
        await iEnterIntoInputField(tester, "this is custom message", 0);
        await iTapText(tester, "Save");
        await iWait(tester);
        await iEnterIntoInputField(tester, "another message", 0);
        await iTapText(tester, "Save");
        await iWait(tester);
        await iSeeWidgetTimes(tester, ListTile, 2);
      } finally {
        await bddTearDown(tester);
      }
    });
    testWidgets('''Adding two custom messages and selecting one''', (tester) async {
      try {
        await bddSetUp(tester);
        await theAppIsRunning(tester);
        await iEnterIntoInputField(tester, "hello", 0);
        await iTapText(tester, "Save");
        await iWait(tester);
        await iEnterIntoInputField(tester, "bye", 0);
        await iTapText(tester, "Save");
        await iWait(tester);
        await iSeeWidgetTimes(tester, ListTile, 2);
        await iTapListtileWithKey(tester, ValueKey(1));
        await iSeeListtileWidgetIsSelected(tester);
        await iSeeText(tester, "Text Message: bye");
      } finally {
        await bddTearDown(tester);
      }
    });
  });
}
