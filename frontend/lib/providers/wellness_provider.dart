import 'package:flutter/material.dart';

class WellnessProvider extends ChangeNotifier {
  bool _takenMeds = false;
  bool _drankWater = false;
  bool _sleptWell = false;

  bool get takenMeds => _takenMeds;
  bool get drankWater => _drankWater;
  bool get sleptWell => _sleptWell;

  int get score {
    int total = 0;
    if (_takenMeds) total += 40;
    if (_drankWater) total += 30;
    if (_sleptWell) total += 30;
    return total;
  }

  void toggleMeds() {
    _takenMeds = !_takenMeds;
    notifyListeners();
  }

  void toggleWater() {
    _drankWater = !_drankWater;
    notifyListeners();
  }

  void toggleSleep() {
    _sleptWell = !_sleptWell;
    notifyListeners();
  }
}
