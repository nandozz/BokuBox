// import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_mqtt_app/mqtt/state/MQTTAppState.dart';
import 'package:flutter_mqtt_app/mqtt/MQTTManager.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter/services.dart';

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
      body: Column(
        // ignore: always_specify_types
        children: [
          const Text(
            'Courier Box',
            style: TextStyle(fontSize: 25),
          ),
          const SizedBox(height: 35),
          _buildTextFiedScan(
              _idBoxTextController, 'Boku ID', 'type/scan Boku ID', 'QR'),
          const SizedBox(height: 35),
          _buildTextFiedScan(_scanBarcodeTextController, 'No.Resi',
              'type/scan No.Resi', 'BARCODE'),
          const SizedBox(height: 35),

          ////////////////////////////////////////

          /////////////////  OPEN ////////////////////////
          TextButton.icon(
            onPressed: () {
              if (currentAppState.getAppConnectionState ==
                  MQTTAppConnectionState.connected) {
                String sendCode = _scanBarcodeTextController.text;
                sendCode =
                    sendCode.substring(sendCode.length - 5, sendCode.length);
                _publishMessage('courier $sendCode');
              } else
                _configureAndConnect();
            },
            icon: currentAppState.getAppConnectionState ==
                    MQTTAppConnectionState.connected
                ? const Icon(Icons.open_in_full)
                : const Icon(Icons.connect_without_contact),
            label: currentAppState.getAppConnectionState ==
                    MQTTAppConnectionState.connected
                ? const Text('Open')
                : const Text('Connect'),
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
    _publishMessage('courier ping');
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
  }
}
