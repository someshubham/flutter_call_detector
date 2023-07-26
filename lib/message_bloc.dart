import 'package:flutter_call_detector/di.dart';
import 'package:flutter_call_detector/hive_data_repository.dart';
import 'package:rxdart/rxdart.dart';

class MessageBloc {
  String _primaryMessage = "";

  String get primaryMessage => _primaryMessage;

  final _messageRepo = locator<MessageRepository>();

  final _subjectMessageList = BehaviorSubject<List<String>>.seeded([]);
  final _subjectPrimaryMessage = BehaviorSubject<String>.seeded("");

  ValueStream<List<String>> get messageListStream => _subjectMessageList.stream;
  ValueStream<String> get primaryMessageStream => _subjectPrimaryMessage.stream;

  Future<void> loadMessage() async {
    final newPrimaryMessage = await _messageRepo.getPrimaryMessage();
    _primaryMessage = newPrimaryMessage;
    _subjectPrimaryMessage.add(_primaryMessage);
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
    _subjectPrimaryMessage.add(_primaryMessage);
  }

  void dispose() {
    _subjectMessageList.close();
  }
}
