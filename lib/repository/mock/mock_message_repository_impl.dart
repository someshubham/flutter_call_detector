import 'package:flutter_call_detector/repository/message_repository.dart';

class MockMessageRepositoryImpl implements MessageRepository {
  List<String> initialData = [];
  var primaryMessage = "";
  MockMessageRepositoryImpl();

  @override
  Future<void> addMessage(String message) async {
    initialData.add(message);
  }

  @override
  Future<List<String>> getMessageList() async {
    return initialData;
  }

  @override
  Future<String> getPrimaryMessage() async {
    return primaryMessage;
  }

  @override
  Future<void> setPrimaryMessage(String message) async {
    primaryMessage = message;
  }
}
