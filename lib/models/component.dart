import 'package:flutter/material.dart';
import 'enums.dart';
import 'pin.dart';

abstract class Component {
  final String id;
  Offset position;
  final ComponentType type;
  final List<Pin> pins = [];
  String name = '';
  String icNumber = '';
  String formula = '';
  bool isCalculatingFormula = false; // Guard against circular recursion

  Component(this.id, this.position, this.type);

  String calculateFormula();

  void evaluate();
  Offset getPinPosition(Pin pin);
  Rect get rect;
  void dispose() {
    for (var pin in pins) {
      for (var wire in List.from(pin.connections)) {
        wire.dispose();
      }
    }
  }
}
