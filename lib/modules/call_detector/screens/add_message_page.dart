import 'package:flutter/material.dart';
import 'package:flutter_call_detector/modules/call_detector/bloc/message_bloc.dart';

class AddMessagePage extends StatefulWidget {
  final MessageBloc messageBloc;

  const AddMessagePage({super.key, required this.messageBloc});

  @override
  State<AddMessagePage> createState() => _AddMessagePageState();
}

class _AddMessagePageState extends State<AddMessagePage> {
  final messageInputController = TextEditingController(text: "");

  get messageBloc => widget.messageBloc;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const ValueKey("msg"),
                    controller: messageInputController,
                    decoration: const InputDecoration(
                      hintText: "Enter Custom Message",
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    messageBloc.saveMessage(messageInputController.text);
                  },
                  child: const Text("Save"),
                ),
              ],
            ),
            Expanded(
              child: StreamBuilder<List<String>>(
                stream: messageBloc.messageListStream,
                builder: (context, snapshot) {
                  final list = snapshot.data;
                  if (list?.isEmpty ?? true) {
                    return const Offstage(
                      key: ValueKey("list-offstage"),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: list!.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        key: ValueKey(index),
                        selected: list[index] == messageBloc.primaryMessage,
                        title: Text(list[index]),
                        onTap: () {
                          messageBloc.setPrimaryMessage(list[index]);
                          setState(() {});
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
