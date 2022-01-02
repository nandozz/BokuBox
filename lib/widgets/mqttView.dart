import 'dart:async';
// import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_mqtt_app/mqtt/state/MQTTAppState.dart';
import 'package:flutter_mqtt_app/mqtt/MQTTManager.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_mqtt_app/pages/courier_page.dart';
import 'package:flutter_mqtt_app/pages/home_page.dart';

class MQTTView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MQTTViewState();
  }
}

class _MQTTViewState extends State<MQTTView> {
  final TextEditingController _hostTextController = TextEditingController();
  final TextEditingController _messageTextController = TextEditingController();
  final TextEditingController _bokuIDTextController = TextEditingController();
  final TextEditingController _bokuPassTextController = TextEditingController();

  late MQTTAppState currentAppState;
  late MQTTManager manager;
  bool isHiddenPass = true;

  @override
  void initState() {
    super.initState();

    /*
    _hostTextController.addListener(_printLatestValue);
    _messageTextController.addListener(_printLatestValue);
    _bokuIDTextController.addListener(_printLatestValue);

     */
  }

  @override
  void dispose() {
    _hostTextController.dispose();
    _messageTextController.dispose();
    _bokuIDTextController.dispose();
    _bokuPassTextController.dispose();
    print('dispose nih');
    super.dispose();
  }

  /*
  _printLatestValue() {
    print("Second text field: ${_hostTextController.text}");
    print("Second text field: ${_messageTextController.text}");
    print("Second text field: ${_bokuIDTextController.text}");
  }

   */

  @override
  Widget build(BuildContext context) {
    final MQTTAppState appState = Provider.of<MQTTAppState>(context);
    // Keep a reference to the app state.
    currentAppState = appState;
    final Scaffold scaffold = Scaffold(
        body: SafeArea(child: SingleChildScrollView(child: _buildColumn())));
    return scaffold;
  }

  // Widget _buildAppBar(BuildContext context) {
  //   return AppBar(
  //     title: const Text('MQTT'),
  //     backgroundColor: Colors.greenAccent,
  //   );
  // }

  Widget _buildColumn() {
    return Column(
      children: <Widget>[
        // _buildConnectionStateText(
        //     _prepareStateMessageFrom(currentAppState.getAppConnectionState)),
        _buildEditableColumn(),
        _buildScrollableTextWith(currentAppState.getHistoryText)
      ],
    );
  }

  Widget _buildEditableColumn() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(50),
        child: Column(
          children: <Widget>[
            const Text(
              'My Box',
              style: TextStyle(fontSize: 25, color: Colors.amber),
            ),
            const SizedBox(height: 35),
            TextField(
              enabled: true,
              controller: _bokuIDTextController,
              decoration: const InputDecoration(
                contentPadding:
                    EdgeInsets.only(left: 0, bottom: 0, top: 0, right: 0),
                labelText: 'Box ID',
              ),
            ),
            const SizedBox(height: 20),
            // _buildTextFieldWith(_bokuPassTextController, 'Access Key',
            //     currentAppState.getAppConnectionState),

            TextField(
              obscureText: isHiddenPass,
              enabled: true,
              controller: _bokuPassTextController,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.only(left: 0, bottom: 0, top: 0, right: 0),
                labelText: 'Access Key',
                suffixIcon: InkWell(
                  onTap: _tooglePassView,
                  child: Icon(
                    isHiddenPass ? Icons.visibility : Icons.visibility_off,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildConnecteButtonFrom(currentAppState.getAppConnectionState),
            const SizedBox(height: 20),
            Lottie.asset(
              'assets/lottie/walkingbox.json',
              // 'https://assets7.lottiefiles.com/packages/lf20_i7bmwsni.json',
              width: 75,
              height: 75,
              fit: BoxFit.cover,
            ),
          ],
        ),
      ),
    );
  }

  void _tooglePassView() {
    setState(() {
      isHiddenPass = !isHiddenPass;
    });
  }

  // Widget _buildConnectionStateText(String status) {
  //   return Row(
  //     children: <Widget>[
  //       Expanded(
  //         child: Container(
  //             color: Colors.amber,
  //             child: Text(status, textAlign: TextAlign.center)),
  //       ),
  //     ],
  //   );
  // }

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

  Widget _buildConnecteButtonFrom(MQTTAppConnectionState state) {
    return Row(
      children: <Widget>[
        Expanded(
          // ignore: deprecated_member_use
          child: RaisedButton(
              color: Colors.amber,
              child: const Text('Login'),
              onPressed: () {
                const SnackBar snackBar = SnackBar(
                  content: Text('Please check your Box ID and Access Key!'),
                );
                if (_bokuIDTextController.text == '' ||
                    _bokuPassTextController.text == '') {
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute<HomePage>(
                      builder: (BuildContext context) {
                        return HomePage('${_bokuIDTextController.text}',
                            '${_bokuPassTextController.text}');
                      },
                    ),
                  );
                }
              }
              // state == MQTTAppConnectionState.disconnected ? () : null, //
              ),
        ),
        // const SizedBox(width: 20),
        // Expanded(
        //   // ignore: deprecated_member_use
        //   child: RaisedButton(
        //     color: Colors.amber[200],
        //     child: const Text('Logout'),
        //     onPressed: _disconnect, //
        //   ),
        // ),
      ],
    );
  }

  // Utility functions
  // String _prepareStateMessageFrom(MQTTAppConnectionState state) {
  //   switch (state) {
  //     case MQTTAppConnectionState.connected:
  //       return 'Connected';
  //     case MQTTAppConnectionState.connecting:
  //       return 'Connecting';
  //     case MQTTAppConnectionState.disconnected:
  //       return 'Disconnected';
  //   }
  // }

  Future<void> scanQR(TextEditingController controller, int mode) async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = mode == 1
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
}
