import 'package:flutter_call_detector/di.dart';
import 'package:flutter_call_detector/hive_data_repository.dart';
import 'package:rxdart/rxdart.dart';

class MessageBloc {
  String _primaryMessage = "";

  String get primaryMessage => _primaryMessage;

  final _messageRepo = locator<MessageRepository>();

  final _subjectMessageList = BehaviorSubject<List<String>>.seeded([]);

  ValueStream<List<String>> get messageListStream => _subjectMessageList.stream;

  Future<void> loadMessage() async {
    final newList = await _messageRepo.getMessageList();
    _subjectMessageList.add(newList);
  }

  Future<void> saveMessage(String message) async {
    _messageRepo.addMessage(message);
    final newList = await _messageRepo.getMessageList();
    _subjectMessageList.add(newList);
  }

  Future<void> setPrimaryMessage(String message) async {
    _messageRepo.setPrimaryMessage(message);
    _primaryMessage = await _messageRepo.getPrimaryMessage();
  }

  void dispose() {
    _subjectMessageList.close();
  }
}
