import 'package:flutter/material.dart';
import '../models/component.dart';
import '../models/wire.dart';
import 'command.dart';

class AddComponentCommand implements Command {
  final List<Component> components;
  final List<Wire> wires;
  final Component component;
  final Function() updateFormulas;

  AddComponentCommand(
    this.components,
    this.wires,
    this.component,
    this.updateFormulas,
  );

  @override
  void execute() {
    components.add(component);
    updateFormulas();
  }

  @override
  void undo() {
    components.remove(component);
    updateFormulas();
  }
}

class RemoveComponentCommand implements Command {
  final List<Component> components;
  final List<Wire> wires;
  final Component component;
  final List<Wire> removedWires = [];
  final Function() updateFormulas;

  RemoveComponentCommand(
    this.components,
    this.wires,
    this.component,
    this.updateFormulas,
  ) {
    for (var pin in component.pins) {
      for (var connection in pin.connections) {
        if (connection is Wire) {
          removedWires.add(connection);
        }
      }
    }
  }

  @override
  void execute() {
    components.remove(component);
    for (var wire in removedWires) {
      wires.remove(wire);
      wire.dispose();
    }
    component.dispose();
    updateFormulas();
  }

  @override
  void undo() {
    components.add(component);
    for (var wire in removedWires) {
      wires.add(wire);
    }
    updateFormulas();
  }
}

class MoveComponentCommand implements Command {
  final Component component;
  final Offset oldPosition;
  final Offset newPosition;

  MoveComponentCommand(this.component, this.oldPosition, this.newPosition);

  @override
  void execute() {
    component.position = newPosition;
  }

  @override
  void undo() {
    component.position = oldPosition;
  }
}

class AddWireCommand implements Command {
  final List<Wire> wires;
  final Wire wire;
  final Function() updateFormulas;

  AddWireCommand(this.wires, this.wire, this.updateFormulas);

  @override
  void execute() {
    wires.add(wire);
    updateFormulas();
  }

  @override
  void undo() {
    wires.remove(wire);
    wire.dispose();
    updateFormulas();
  }
}
