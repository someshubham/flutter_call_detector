import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_call_detector/modules/call_detector/bloc/message_bloc.dart';
import 'package:flutter_call_detector/modules/call_detector/screens/add_message_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_state/phone_state.dart';
import 'package:direct_sms/direct_sms.dart';

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

  void _startListeningToPhoneCalls() {
    phoneStateSub = PhoneState.stream.listen((event) {
      setState(() {
        status = event;
      });

      if (status.status == PhoneStateStatus.CALL_ENDED) {
        _sendSms(number: status.number!, message: messageBloc.primaryMessage);
      }
    });
  }

  _sendSms({required String number, required String message}) async {
    final permission = Permission.sms.request();
    if (await permission.isGranted) {
      directSms.sendSms(message: message, phone: number);
    }
  }

  void navigateToEditMessage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddMessagePage(messageBloc: messageBloc),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "DK Phone Call Detector",
          style: TextStyle(fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder<String>(
              stream: messageBloc.primaryMessageStream,
              builder: (context, snapshot) {
                final str = snapshot.data;
                if (str?.isEmpty ?? true) {
                  return Column(
                    children: [
                      const Text(
                        "Your SMS Message appears here\nPress the + icon to add",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      IconButton(
                        onPressed: navigateToEditMessage,
                        icon: const Icon(
                          Icons.add,
                          size: 28,
                        ),
                      ),
                    ],
                  );
                }
                return Column(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: navigateToEditMessage,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 4),
                          child: Text(
                            messageBloc.primaryMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Tap on message to update",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: StreamBuilder<String>(
        stream: messageBloc.primaryMessageStream,
        builder: (context, snapshot) {
          final isPrimaryMessageSet =
              !snapshot.hasData || (snapshot.data?.isEmpty ?? false);
          if (isPrimaryMessageSet) {
            return const Offstage();
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton.large(
                elevation: 2,
                tooltip:
                    phoneStateSub == null ? "Start Service" : "Stop Serice",
                onPressed: phoneStateSub == null ? startService : stopService,
                backgroundColor: phoneStateSub == null
                    ? Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).primaryColorLight
                        : Theme.of(context).primaryColor
                    : Colors.red,
                child: Icon(
                  phoneStateSub == null ? Icons.play_arrow : Icons.pause,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                phoneStateSub == null
                    ? "Tap to Start Service"
                    : "Service is running",
                style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[700]
                        : Colors.grey[500]),
              ),
            ],
          );
        },
      ),
    );
  }

  void startService() {
    requestSmsAndPhonePermission().then((value) {
      if (value && phoneStateSub == null) {
        _startListeningToPhoneCalls();
      }
      setState(() {});
    });
  }

  void stopService() {
    phoneStateSub?.cancel();
    phoneStateSub = null;
    setState(() {});
  }

  @override
  void dispose() {
    messageBloc.dispose();
    phoneStateSub?.cancel();
    super.dispose();
  }
}
