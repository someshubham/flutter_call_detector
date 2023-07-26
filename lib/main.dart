import 'dart:async';
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
  StreamSubscription<PhoneState>? phoneStateSub;

  final messageBloc = MessageBloc();

  final messageInputController = TextEditingController(text: "");

  _sendSms({required String number, required String message}) async {
    final permission = Permission.sms.request();
    if (await permission.isGranted) {
      directSms.sendSms(message: message, phone: number);
    }
  }

  @override
  void initState() {
    super.initState();
    messageBloc.loadMessage();
  }

  Future<bool> requestSmsAndPhonePermission() async {
    var phonePermissionStatus = await Permission.phone.request();
    final smsPermissionStatus = await Permission.sms.request();

    final isPhonePermissionGranted = switch (phonePermissionStatus) {
      PermissionStatus.denied ||
      PermissionStatus.restricted ||
      PermissionStatus.limited ||
      PermissionStatus.permanentlyDenied =>
        false,
      PermissionStatus.provisional || PermissionStatus.granted => true,
    };

    final isSmsPermissionGranted = smsPermissionStatus.isGranted;

    return isPhonePermissionGranted && isSmsPermissionGranted;
  }

  void setStream() {
    phoneStateSub = PhoneState.stream.listen((event) {
      setState(() {
        status = event;
      });

      if (status.status == PhoneStateStatus.CALL_ENDED) {
        _sendSms(number: status.number!, message: messageBloc.primaryMessage);
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
            StreamBuilder<String>(
                stream: messageBloc.primaryMessageStream,
                builder: (context, snapshot) {
                  final str = snapshot.data;
                  if (str?.isEmpty ?? true) {
                    return const Offstage();
                  }
                  return Text("Text Message: ${messageBloc.primaryMessage}");
                }),
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(phoneStateSub == null
                    ? "No Service is running"
                    : "Service is running"),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      requestSmsAndPhonePermission().then((value) {
                        if (value && phoneStateSub == null) {
                          setStream();
                        }
                        setState(() {});
                      });
                    },
                    child: const Text("Start Service"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      phoneStateSub = null;
                      setState(() {});
                    },
                    child: const Text("Stop Service"),
                  ),
                ),
              ],
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

  @override
  void dispose() {
    messageBloc.dispose();
    phoneStateSub?.cancel();
    super.dispose();
  }
}
