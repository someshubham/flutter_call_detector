import 'dart:async';

import 'package:flutter_call_detector/constants/hive_constants.dart';
import 'package:flutter_call_detector/repository/message_repository.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveMessageRepositoryImpl implements MessageRepository {
  final HiveInterface hive;

  HiveMessageRepositoryImpl(this.hive);

  @override
  Future<List<String>> getMessageList() async {
    try {
      final messageListBox = hive.box(HiveConstants.phoneDataBox);
      if (messageListBox.containsKey(HiveConstants.messageListKey)) {
        final data = messageListBox.get(
          HiveConstants.messageListKey,
          defaultValue: [],
        );

        return (data as List).map((e) => e.toString()).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> addMessage(String message) async {
    try {
      final messageListBox = hive.box(HiveConstants.phoneDataBox);
      var data = messageListBox.get(
        HiveConstants.messageListKey,
        defaultValue: [],
      );

      if (data != null) {
        data.insert(0, message);
      } else {
        data = [message];
      }
      messageListBox.put(HiveConstants.messageListKey, data);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<void> setPrimaryMessage(String message) async {
    try {
      final messageListBox = hive.box(HiveConstants.phoneDataBox);
      messageListBox.put(HiveConstants.primaryMessageKey, message);
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<String> getPrimaryMessage() async {
    try {
      final messageListBox = hive.box(HiveConstants.phoneDataBox);
      if (messageListBox.containsKey(HiveConstants.primaryMessageKey)) {
        final data = messageListBox.get(
          HiveConstants.primaryMessageKey,
          defaultValue: "",
        );

        return data ?? "";
      } else {
        return "";
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}
