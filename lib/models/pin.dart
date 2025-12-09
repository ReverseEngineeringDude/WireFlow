import 'package:flutter/material.dart';
import 'enums.dart';

class Pin {
  final String id;
  final dynamic owner; // Component type to avoid circular imports
  final bool isOutput;
  LogicState state = LogicState.low;
  final List<dynamic> connections = []; // Wire type
  Offset get position => owner.getPinPosition(this);

  Pin(this.id, this.owner, {this.isOutput = false});

  dynamic get sourceComponent {
    if (isOutput) return owner;
    if (connections.isEmpty) return null;
    final wire = connections.first;
    return wire.from.owner;
  }
}
