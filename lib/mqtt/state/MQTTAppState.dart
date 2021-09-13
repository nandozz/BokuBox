import 'package:flutter/cupertino.dart';

enum MQTTAppConnectionState { connected, disconnected, connecting }

class MQTTAppState with ChangeNotifier {
  MQTTAppConnectionState _appConnectionState =
      MQTTAppConnectionState.disconnected;
  String _receivedText = '';
  String _historyText = '';
  bool _isLock = true;
  // ignore: unused_field
  // ignore: always_specify_types
  String _updateList = '';

  void setReceivedText(String text) {
    _receivedText = text;

    if (text.contains('List')) {
      _updateList = 'Code : ' + text.substring(5, text.length);
    } else if (text.contains('Open')) {
      _isLock = false;
    } else if (text.contains('Close')) {
      _isLock = true;
    }
    _historyText = _historyText + '\n' + _receivedText;
    notifyListeners();
  }

  void setAppConnectionState(MQTTAppConnectionState state) {
    _appConnectionState = state;
    notifyListeners();
  }

  void setClearHistoryText() {
    _historyText = '';
    notifyListeners();
  }

  String get getUpdateList => _updateList;
  String get getReceivedText => _receivedText;
  String get getHistoryText => _historyText;
  bool get getState => _isLock;

  MQTTAppConnectionState get getAppConnectionState => _appConnectionState;
}
