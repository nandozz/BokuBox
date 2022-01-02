// import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_mqtt_app/mqtt/state/MQTTAppState.dart';
import 'package:flutter_mqtt_app/mqtt/MQTTManager.dart';
import 'package:lottie/lottie.dart';

// String uplist = '';
// String boxID = '';
// String${widget.keypas} = '';

// ignore: must_be_immutable
class HomePage extends StatefulWidget {
  String id;
  String keypas;

  // ignore: sort_constructors_first
  HomePage(this.id, this.keypas);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _newCodeTextController = TextEditingController();

  late MQTTAppState currentAppState;

  late MQTTManager manager;
  //  _configureAndConnect(widget.id, widget.keypas);

  @override
  void initState() {
    print('initState homePage');
    print('${widget.id}');

    super.initState();
  }

  @override
  void dispose() {
    _newCodeTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MQTTAppState appState = Provider.of<MQTTAppState>(context);
    // Keep a reference to the app state.
    currentAppState = appState;

    Future<bool?> showWarning(BuildContext context) async => showDialog<bool>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('Do you want to Logout?'),
              // ignore: always_specify_types
              actions: [
                ElevatedButton(
                  child: const Text('No'),
                  onPressed: () => Navigator.pop(context, false),
                ),
                ElevatedButton(
                  child: const Text('Yes'),
                  onPressed: () {
                    currentAppState.setReceivedText('listempty');
                    currentAppState.setReceivedText('historyempty');
                    _disconnect();
                    return Navigator.pop(context, true);
                  },
                ),
              ],
            ));

    return ChangeNotifierProvider<MQTTAppState>(
      create: (_) => MQTTAppState(),
      child: WillPopScope(
        onWillPop: () async {
          print('Back button pressed!');
          final bool? shouldPop = await showWarning(context);
          return shouldPop ?? false;
        },
        child: Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: SingleChildScrollView(
                child: Column(
                  // ignore: always_specify_types
                  children: [
                    _buildConnectionStateText(_prepareStateMessageFrom(
                        currentAppState.getAppConnectionState,
                        id: widget.id,
                        key: widget.keypas)),
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
                    const SizedBox(height: 10),
                    _clearlist('list', 'clearlist'),
                    _listofresi(currentAppState.getUpdateList),
                    const SizedBox(height: 10),
                    _clearlist('history', 'clearhis'),
                    _listofhistory(currentAppState.getHistoryText),
                    const SizedBox(height: 10),
                    _buildPublishMessageRow(),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      // ignore: always_specify_types
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          // ignore: always_specify_types
                          children: [
                            TextButton(
                              onPressed:
                                  currentAppState.getAppConnectionState ==
                                          MQTTAppConnectionState.connected
                                      ? () {
                                          _publishMessage(
                                              '${widget.keypas} restart');
                                        }
                                      : null,
                              child: const Text('Restart'),
                            ),
                            TextButton(
                              onPressed: currentAppState
                                          .getAppConnectionState ==
                                      MQTTAppConnectionState.connected
                                  ? () {
                                      _publishMessage('${widget.keypas} reset');
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
      ),
    );
  }

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
                  ? _publishMessage('${widget.keypas} open')
                  : _publishMessage('${widget.keypas} close');
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
              // String sendCode = _newCodeTextController.text;
              // sendCode =
              //     sendCode.substring(sendCode.length - 5, sendCode.length);
              _publishMessage(
                  '${widget.keypas} add ${_newCodeTextController.text}');
            }
          : () {
              _configureAndConnect(widget.id, widget.keypas);
            },
    );
  }

  Widget _listofresi(String text) {
    // final String uplist = currentAppState.getReceivedText;
    final List<String> arr = text.split('.');
    print('Data LIST : $arr');
    if (arr[0] == 'List') {
      print(text);
    }
    // ignore: prefer_const_constructors
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: arr.map((String e) {
          return Text(
            e,
            style: const TextStyle(fontSize: 18),
          );
        }).toList(),
      ),
    );
  }

  Widget _listofhistory(String text) {
    // final String uplist = currentAppState.getReceivedText;
    final List<String> arr = text.split('.');
    print('Data History : $arr');
    if (arr[0] == 'History') {
      print(text);
    }
    // ignore: prefer_const_constructors
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: arr.map((String e) {
          return Text(
            e,
            style: const TextStyle(fontSize: 18),
          );
        }).toList(),
      ),
    );
  }

  Row _clearlist(String reqlist, String clear) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      // ignore: always_specify_types
      children: [
        IconButton(
          onPressed: () {
            currentAppState.getAppConnectionState ==
                    MQTTAppConnectionState.connected
                ? _publishMessage('${widget.keypas} $reqlist')
                : _configureAndConnect(widget.id, widget.keypas);
          },
          icon: const Icon(Icons.list_alt),
          color: Colors.amber,
        ),
        const SizedBox(height: 20),
        IconButton(
          onPressed: () {
            currentAppState.getAppConnectionState ==
                    MQTTAppConnectionState.connected
                ? _publishMessage('${widget.keypas} $clear')
                : _configureAndConnect(widget.id, widget.keypas);
          },
          icon: const Icon(Icons.delete_outlined),
        ),
      ],
    );
  }

  Widget _buildConnectionStateText(String status) {
    // print('${_prepareStateMessageFrom(currentAppState.getAppConnectionState)}');

    return Row(
      children: <Widget>[
        IconButton(
          iconSize: 30,
          color: Colors.amber,
          icon: const Icon(Icons.logout),
          onPressed: () {
            currentAppState.setReceivedText('listempty');
            currentAppState.setReceivedText('historyempty');
            _disconnect();

            Navigator.pop(context);
          },
        ),
        Expanded(
          child: Container(
            color: Colors.amber,
            child: Text(status, textAlign: TextAlign.center),
          ),
        ),
        const SizedBox(
          width: 40,
        )
      ],
    );
  }

  // Utility functions
  String _prepareStateMessageFrom(MQTTAppConnectionState state,
      {String id = '', String key = ''}) {
    switch (state) {
      case MQTTAppConnectionState.connected:
        return 'Connected';
      case MQTTAppConnectionState.connecting:
        return 'Connecting';
      case MQTTAppConnectionState.disconnected:
        Future.delayed(
          const Duration(seconds: 2),
          () {
            // 5 seconds over, navigate to Page2.
            setState(
              () {
                _configureAndConnect(id, key);
                Future.delayed(
                  const Duration(seconds: 1),
                  () {
                    // 5 seconds over, navigate to Page2.
                    setState(
                      () {
                        _publishMessage('$key list');
                      },
                    );
                  },
                );
              },
            );
          },
        );
        return 'Disconnected';
    }
  }

  void _disconnect() {
    manager.disconnect();
  }

  void _configureAndConnect(String id, String key) {
    String osPrefix = 'Flutter_iOS';
    if (Platform.isAndroid) {
      osPrefix = 'Flutter_Android';
    }
    final String _topic = 'BokuBox/$key/$id';
    manager = MQTTManager(
        host: 'broker.hivemq.com',
        // topic: who == 'user' ? _topic : _topiccourier,
        topic: _topic,
        identifier: osPrefix,
        state: currentAppState);
    Future.delayed(
      Duration.zero,
      () => setState(
        () {
          manager.initializeMQTTClient();
          manager.connect();
        },
      ),
    );
  }
}
