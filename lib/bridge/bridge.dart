import 'package:baserouter/bridge/bridge_models.dart';
import 'package:flutter/cupertino.dart';

class BridgeBase extends ChangeNotifier {
  final Map<String, dynamic> _data = {};
  Map<String, dynamic> get data => _data;

  void close() {
    _data.clear();
    notifyListeners();
  }

  void closeKey(String name) {
    _data.remove(name);
    notifyListeners();
  }

  void load(String name, dynamic slice, Type type) {
    _data[name] = {'slice': slice, 'type': type};
    notifyListeners();
  }

  BridgeModel read(String name, dynamic initial) {
    if (data.containsKey(name)) {
      return BridgeModel(data[name]['slice'], data[name]['type']);
    } else {
      return BridgeModel(initial, initial.runtimeType);
    }
  }
}
