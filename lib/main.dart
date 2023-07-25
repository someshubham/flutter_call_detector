import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_call_detector/di.dart';
import 'package:flutter_call_detector/flavor.dart';
import 'package:flutter_call_detector/hive_constants.dart';
import 'package:flutter_call_detector/message_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_state/phone_state.dart';
import 'package:direct_sms/direct_sms.dart';

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

class PhoneCallDetectorPage extends StatefulWidget {
  const PhoneCallDetectorPage({super.key});

  @override
  State<PhoneCallDetectorPage> createState() => _PhoneCallDetectorPageState();
}

class _PhoneCallDetectorPageState extends State<PhoneCallDetectorPage> {
  var directSms = DirectSms();
  PhoneState status = PhoneState.nothing();
  bool granted = false;

  final messageBloc = MessageBloc();

  final messageInputController = TextEditingController(text: "");

  String statusMessage = "";

  _sendSms({required String number, required String message}) async {
    final permission = Permission.sms.request();
    if (await permission.isGranted) {
      directSms.sendSms(message: message, phone: number);
    }
  }

  Future<bool> requestPermission() async {
    var status = await Permission.phone.request();

    return switch (status) {
      PermissionStatus.denied ||
      PermissionStatus.restricted ||
      PermissionStatus.limited ||
      PermissionStatus.permanentlyDenied =>
        false,
      PermissionStatus.provisional || PermissionStatus.granted => true,
    };
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) setStream();
    messageBloc.loadMessage();
  }

  bool get isIncomingCall =>
      status.status == PhoneStateStatus.CALL_INCOMING ||
      status.status == PhoneStateStatus.CALL_STARTED;

  void setStream() {
    PhoneState.stream.listen((event) {
      setState(() {
        status = event;
      });

      if (status.status == PhoneStateStatus.CALL_ENDED) {
        _sendSms(number: status.number!, message: "This is a test message");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dk Phone Call Detector"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            if (messageBloc.primaryMessage.isNotEmpty)
              Text("Text Message: ${messageBloc.primaryMessage}"),
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

    // return Scaffold(
    //   appBar: AppBar(
    //     title: const Text("Phone State"),
    //     centerTitle: true,
    //   ),
    //   body: Center(
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       crossAxisAlignment: CrossAxisAlignment.center,
    //       children: [
    //         if (Platform.isAndroid)
    //           MaterialButton(
    //             onPressed: !granted
    //                 ? () async {
    //                     bool temp = await requestPermission();
    //                     setState(() {
    //                       granted = temp;
    //                       if (granted) {
    //                         setStream();
    //                       }
    //                     });
    //                   }
    //                 : null,
    //             child: const Text("Request permission of Phone"),
    //           ),
    //         Column(
    //           children: [
    //             const Text("Text Message"),
    //             TextField(
    //               key: ValueKey("msg"),
    //               controller: messageInputController,
    //             ),
    //             ElevatedButton(
    //               onPressed: () {
    //                 hiveRepo.addMessage(messageInputController.text);
    //               },
    //               child: const Text("Save"),
    //             ),
    //             Text(statusMessage),
    //           ],
    //         ),
    //         const Text(
    //           "Status of call",
    //           style: TextStyle(fontSize: 24),
    //         ),
    //         if (status.status == PhoneStateStatus.CALL_INCOMING ||
    //             status.status == PhoneStateStatus.CALL_STARTED)
    //           Text(
    //             "Number: ${status.number}",
    //             style: const TextStyle(fontSize: 24),
    //           ),
    //         Icon(
    //           getIcons(),
    //           color: getColor(),
    //           size: 80,
    //         )
    //       ],
    //     ),
    //   ),
    // );
  }

  IconData getIcons() {
    return switch (status.status) {
      PhoneStateStatus.NOTHING => Icons.clear,
      PhoneStateStatus.CALL_INCOMING => Icons.add_call,
      PhoneStateStatus.CALL_STARTED => Icons.call,
      PhoneStateStatus.CALL_ENDED => Icons.call_end,
    };
  }

  Color getColor() {
    return switch (status.status) {
      PhoneStateStatus.NOTHING || PhoneStateStatus.CALL_ENDED => Colors.red,
      PhoneStateStatus.CALL_INCOMING => Colors.green,
      PhoneStateStatus.CALL_STARTED => Colors.orange,
    };
  }

  @override
  void dispose() {
    messageBloc.dispose();
    super.dispose();
  }
}
