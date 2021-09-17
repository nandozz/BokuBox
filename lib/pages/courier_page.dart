// import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_mqtt_app/mqtt/state/MQTTAppState.dart';
import 'package:flutter_mqtt_app/mqtt/MQTTManager.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

// ignore: must_be_immutable
class CourierPage extends StatelessWidget {
  // const CourierPage({ Key? key }) : super(key: key);
  final TextEditingController _idBoxTextController = TextEditingController();
  final TextEditingController _scanBarcodeTextController =
      TextEditingController();

  late MQTTAppState currentAppState;
  late MQTTManager manager;

  @override
  Widget build(BuildContext context) {
    final MQTTAppState appState = Provider.of<MQTTAppState>(context);
    // Keep a reference to the app state.
    currentAppState = appState;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: SingleChildScrollView(
            child: Column(
              // ignore: always_specify_types
              mainAxisAlignment: MainAxisAlignment.center,
              // ignore: always_specify_types
              children: [
                const Text(
                  'Courier Box',
                  style: TextStyle(fontSize: 25, color: Colors.lightBlue),
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
                _buildTextFiedScan(
                    _idBoxTextController, 'Boku ID', 'type/scan Boku ID', 'QR'),
                const SizedBox(height: 55),
                _buildTextFiedScan(_scanBarcodeTextController, 'No.Resi',
                    'type/scan No.Resi', 'BARCODE'),
                const SizedBox(height: 35),

                /////////////////  Connect / OPEN ////////////////////////
                TextButton.icon(
                  onPressed: () {
                    if (currentAppState.getAppConnectionState ==
                            MQTTAppConnectionState.connected &&
                        _idBoxTextController.text.isNotEmpty &&
                        _scanBarcodeTextController.text.isNotEmpty) {
                      String sendCode = _scanBarcodeTextController.text;
                      sendCode = sendCode.substring(
                          sendCode.length - 5, sendCode.length);
                      _publishMessage('courier $sendCode');

                      if (currentAppState.getState) {
                        showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text('Box Open'),
                            content: const Text(
                                'Box will close in 7 sec.\nClose now?'),
                            // ignore: always_specify_types
                            actions: [
                              TextButton(
                                  child: const Text('OK'),
                                  onPressed: () {
                                    manager.publish('courier done');
                                    currentAppState.setReceivedText('Close');
                                    Navigator.pop(context, 'OK');
                                    manager.disconnect();
                                  })
                            ],
                          ),
                        );
                        // ignore: unnecessary_statements
                      } else {
                        manager.publish('courier done');
                        currentAppState.setReceivedText('Close');
                        manager.disconnect();
                      }
                    } else
                      _configureAndConnect();
                  },
                  icon: (currentAppState.getAppConnectionState ==
                              MQTTAppConnectionState.connected &&
                          _idBoxTextController.text.isNotEmpty &&
                          _scanBarcodeTextController.text.isNotEmpty)
                      ? const Icon(Icons.open_in_full)
                      : const Icon(Icons.connect_without_contact),
                  label: (currentAppState.getAppConnectionState ==
                              MQTTAppConnectionState.connected &&
                          _idBoxTextController.text.isNotEmpty &&
                          _scanBarcodeTextController.text.isNotEmpty)
                      ? const Text('Open')
                      : const Text('Connect'),
                ),
                const SizedBox(height: 55),
                _buildScrollableTextWith(currentAppState.getHistoryText)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScrollableTextWith(String text) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        // ignore: always_specify_types
        children: [
          IconButton(
            onPressed: () {
              currentAppState.setClearHistoryText();
            },
            icon: const Icon(Icons.refresh),
          ),
          Container(
            width: 400,
            height: 200,
            child: SingleChildScrollView(
              child: Text(text),
            ),
          ),
        ],
      ),
    );
  }

  TextField _buildTextFiedScan(TextEditingController controller, String label,
      String hintText, String mode) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 18, color: Colors.black54),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.amber),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.lightBlue.withOpacity(.5)),
        suffixIcon: IconButton(
          onPressed: () {
            scanQR(controller, mode);
          },
          icon: const Icon(
            Icons.camera_alt,
            size: 35,
            color: Colors.lightBlue,
          ),
        ),
      ),
    );
  }

  void _configureAndConnect() {
    // ignore: flutter_style_todos
    // TODO: Use UUID
    String osPrefix = 'Flutter_iOS';
    if (Platform.isAndroid) {
      osPrefix = 'Flutter_Android';
    }
    final String _topic = 'BokuBox/courier/${_idBoxTextController.text}';

    manager = MQTTManager(
        host: 'broker.hivemq.com',
        topic: _topic,
        identifier: osPrefix,
        state: currentAppState);
    manager.initializeMQTTClient();
    manager.connect();
    // _publishMessage('courier ping');
  }

  Future<void> scanQR(TextEditingController controller, String mode) async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = mode == 'QR'
          ? await FlutterBarcodeScanner.scanBarcode(
              '#ff6666', 'Cancel', true, ScanMode.QR)
          : await FlutterBarcodeScanner.scanBarcode(
              '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      if (barcodeScanRes == '-1') {
        barcodeScanRes = 'Failed to get the code';
      }
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    controller.text = barcodeScanRes;
  }

  // @override
  // void dispose() {
  //   _idBoxTextController.dispose();
  //   super.dispose();
  // }

  void _publishMessage(String text) {
    // String osPrefix = 'Flutter_iOS';
    // if (Platform.isAndroid) {
    //   osPrefix = 'Flutter_Android';
    // }
    final String message = text;
    manager.publish(message);
    _idBoxTextController.clear();
    _scanBarcodeTextController.clear();
    // manager.disconnect();
  }
}
