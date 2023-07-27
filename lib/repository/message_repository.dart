import 'dart:async';

abstract class MessageRepository {
  Future<void> addMessage(String message);
  Future<List<String>> getMessageList();
  Future<void> setPrimaryMessage(String message);
  Future<String> getPrimaryMessage();
}


