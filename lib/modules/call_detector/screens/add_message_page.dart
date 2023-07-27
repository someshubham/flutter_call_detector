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

  MessageBloc get messageBloc => widget.messageBloc;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add SMS Messages",
          style: TextStyle(fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    key: const ValueKey("msg"),
                    controller: messageInputController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: "Your Preferred SMS",
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            messageBloc
                                .saveMessage(messageInputController.text);
                            messageBloc
                                .setPrimaryMessage(messageInputController.text);
                            messageInputController.clear();
                          },
                          child: const Text("Save"),
                        ),
                      ),
                    ],
                  ),
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
                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: list!.length,
                    separatorBuilder: (_, __) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Divider(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[700]
                            : Colors.grey[300],
                      ),
                    ),
                    itemBuilder: (context, index) {
                      return ListTile(
                        key: ValueKey(index),
                        selected: list[index] == messageBloc.primaryMessage,
                        title: Text(list[index]),
                        trailing: list[index] == messageBloc.primaryMessage
                            ? const Icon(Icons.check)
                            : null,
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
