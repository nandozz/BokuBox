// import 'dart:async';
// import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_mqtt_app/mqtt/state/MQTTAppState.dart';
import 'package:flutter_mqtt_app/mqtt/MQTTManager.dart';
import 'package:lottie/lottie.dart';

// String uplist = '';
String boxID = '';
String boxPass = '';

// ignore: must_be_immutable
class HomePage extends StatelessWidget {
  // const HomePage({ Key? key }) : super(key: key);
  final TextEditingController _newCodeTextController = TextEditingController();

  late MQTTAppState currentAppState;
  late MQTTManager manager;

  @override
  Widget build(BuildContext context) {
    final MQTTAppState appState = Provider.of<MQTTAppState>(context);
    // Keep a reference to the app state.
    currentAppState = appState;
    boxID = currentAppState.getBoxID;
    boxPass = currentAppState.getBoxPass;

    print('${currentAppState.getAppConnectionState}');

    return ChangeNotifierProvider<MQTTAppState>(
      create: (_) => MQTTAppState(),
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: SingleChildScrollView(
              child: Column(
                // ignore: always_specify_types
                children: [
                  const Text(
                    'Smart Box',
                    style: TextStyle(fontSize: 25, color: Colors.amber),
                  ),
                  const SizedBox(height: 45),
                  Lottie.asset(
                    'assets/lottie/walkingbox.json',
                    // 'https://assets7.lottiefiles.com/packages/lf20_i7bmwsni.json',
                    width: 75,
                    height: 75,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 45),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    // ignore: always_specify_types
                    children: [
                      IconButton(
                        onPressed: currentAppState.getAppConnectionState ==
                                MQTTAppConnectionState.connected
                            ? () {
                                _publishMessage('$boxPass listView');
                              }
                            : null,
                        icon: const Icon(Icons.list_alt, color: Colors.amber),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          // ignore: always_specify_types
                          children: [
                            Text('Code : ${currentAppState.getUpdateList}'),
                            // const SizedBox(height: 10),
                            IconButton(
                              onPressed:
                                  currentAppState.getAppConnectionState ==
                                          MQTTAppConnectionState.connected
                                      ? () {
                                          _publishMessage('$boxPass listClear');
                                        }
                                      : null,
                              icon: const Icon(Icons.delete),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 35),
                  _buildPublishMessageRow(),
                  const SizedBox(height: 35),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    // ignore: always_specify_types
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        // ignore: always_specify_types
                        children: [
                          TextButton(
                            onPressed: currentAppState.getAppConnectionState ==
                                    MQTTAppConnectionState.connected
                                ? () {
                                    _publishMessage('$boxPass restart');
                                  }
                                : null,
                            child: const Text('Restart'),
                          ),
                          TextButton(
                            onPressed: currentAppState.getAppConnectionState ==
                                    MQTTAppConnectionState.connected
                                ? () {
                                    _publishMessage('$boxPass reset');
                                  }
                                : null,
                            child: const Text(
                              'Reset',
                              style: TextStyle(
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: 25,
                      ),
                      _buildLockButtonFrom(
                          currentAppState.getAppConnectionState),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //   @override
  // void dispose() {
  //   _newCodeTextController.dispose();
  //   super.dispose();
  // }

  void _publishMessage(String text) {
    // String osPrefix = 'Flutter_iOS';
    // if (Platform.isAndroid) {
    //   osPrefix = 'Flutter_Android';
    // }
    final String message = text;
    manager.publish(message);
    _newCodeTextController.clear();
  }

  Widget _buildPublishMessageRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
          child: _buildTextFieldWith(_newCodeTextController, 'Add no.resi',
              currentAppState.getAppConnectionState),
        ),
        _buildSendButtonFrom(currentAppState.getAppConnectionState)
      ],
    );
  }

  Widget _buildLockButtonFrom(MQTTAppConnectionState state) {
    // ignore: deprecated_member_use
    return IconButton(
      iconSize: 35,
      onPressed: state == MQTTAppConnectionState.connected
          ? () {
              // currentAppState.changeLock(currentAppState.getState);
              currentAppState.getState
                  ? _publishMessage('$boxPass open')
                  : _publishMessage('$boxPass close');
            }
          : null, //

      icon: currentAppState.getState
          ? const Icon(Icons.lock, color: Colors.amber)
          : const Icon(Icons.lock_open, color: Colors.amber),
      // () => lock(),
    );
  }

  Widget _buildTextFieldWith(TextEditingController controller, String hintText,
      MQTTAppConnectionState state) {
    bool shouldEnable = false;
    if (controller == _newCodeTextController &&
        state == MQTTAppConnectionState.connected) {
      shouldEnable = true;
    }
    return TextField(
        enabled: shouldEnable,
        controller: controller,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.only(left: 0, bottom: 0, top: 0, right: 0),
          labelText: hintText,
        ));
  }

  Widget _buildSendButtonFrom(MQTTAppConnectionState state) {
    // ignore: deprecated_member_use
    return IconButton(
      icon: const Icon(
        Icons.add_box,
        size: 35,
        color: Colors.amber,
      ),
      onPressed: state == MQTTAppConnectionState.connected
          ? () {
              String sendCode = _newCodeTextController.text;
              sendCode =
                  sendCode.substring(sendCode.length - 5, sendCode.length);
              _publishMessage('$boxPass add $sendCode');
            }
          : null,
    );
  }
}
