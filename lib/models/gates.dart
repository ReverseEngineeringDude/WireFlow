import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'enums.dart';
import 'component.dart';
import 'pin.dart';

class AndGate extends Component {
  AndGate(String id, Offset position) : super(id, position, ComponentType.and) {
    name = 'AND';
    icNumber = '7408';
    pins.add(Pin('in1', this));
    pins.add(Pin('in2', this));
    pins.add(Pin('out', this, isOutput: true));
  }

  @override
  String calculateFormula() {
    if (isCalculatingFormula) return id; // Prevent infinite recursion
    isCalculatingFormula = true;
    try {
      final in1 = pins[0].sourceComponent?.calculateFormula() ?? '?';
      final in2 = pins[1].sourceComponent?.calculateFormula() ?? '?';
      return '($in1 . $in2)';
    } finally {
      isCalculatingFormula = false;
    }
  }

  @override
  void evaluate() {
    final in1 = pins[0].state;
    final in2 = pins[1].state;
    pins[2].state = (in1 == LogicState.high && in2 == LogicState.high)
        ? LogicState.high
        : LogicState.low;
  }

  @override
  Offset getPinPosition(Pin pin) {
    final index = pins.indexOf(pin);
    if (index == 2) {
      return position + const Offset(80, 20);
    }
    return position + Offset(0, (rect.height / 3) * (index + 1));
  }

  @override
  Rect get rect => Rect.fromLTWH(position.dx, position.dy, 80, 40);
}

class OrGate extends Component {
  OrGate(String id, Offset position) : super(id, position, ComponentType.or) {
    name = 'OR';
    icNumber = '7432';
    pins.add(Pin('in1', this));
    pins.add(Pin('in2', this));
    pins.add(Pin('out', this, isOutput: true));
  }

  @override
  String calculateFormula() {
    if (isCalculatingFormula) return id; // Prevent infinite recursion
    isCalculatingFormula = true;
    try {
      final in1 = pins[0].sourceComponent?.calculateFormula() ?? '?';
      final in2 = pins[1].sourceComponent?.calculateFormula() ?? '?';
      return '($in1 + $in2)';
    } finally {
      isCalculatingFormula = false;
    }
  }

  @override
  void evaluate() {
    final in1 = pins[0].state;
    final in2 = pins[1].state;
    pins[2].state = (in1 == LogicState.high || in2 == LogicState.high)
        ? LogicState.high
        : LogicState.low;
  }

  @override
  Offset getPinPosition(Pin pin) {
    final index = pins.indexOf(pin);
    if (index == 2) {
      return position + const Offset(80, 20);
    }
    return position + Offset(0, (rect.height / 3) * (index + 1));
  }

  @override
  Rect get rect => Rect.fromLTWH(position.dx, position.dy, 80, 40);
}

class NotGate extends Component {
  NotGate(String id, Offset position) : super(id, position, ComponentType.not) {
    name = 'NOT';
    icNumber = '7404';
    pins.add(Pin('in', this));
    pins.add(Pin('out', this, isOutput: true));
  }

  @override
  String calculateFormula() {
    if (isCalculatingFormula) return id;
    isCalculatingFormula = true;
    try {
      final in1 = pins[0].sourceComponent?.calculateFormula() ?? '?';
      return "$in1'";
    } finally {
      isCalculatingFormula = false;
    }
  }

  @override
  void evaluate() {
    pins[1].state = pins[0].state == LogicState.high
        ? LogicState.low
        : LogicState.high;
  }

  @override
  Offset getPinPosition(Pin pin) {
    final index = pins.indexOf(pin);
    if (index == 1) {
      return position + const Offset(80, 20);
    }
    return position + const Offset(0, 20);
  }

  @override
  Rect get rect => Rect.fromLTWH(position.dx, position.dy, 80, 40);
}

class AndGate3Input extends Component {
  AndGate3Input(String id, Offset position)
    : super(id, position, ComponentType.and3) {
    name = 'AND';
    icNumber = '7411';
    pins.add(Pin('in1', this));
    pins.add(Pin('in2', this));
    pins.add(Pin('in3', this));
    pins.add(Pin('out', this, isOutput: true));
  }

  @override
  String calculateFormula() {
    if (isCalculatingFormula) return id;
    isCalculatingFormula = true;
    try {
      final in1 = pins[0].sourceComponent?.calculateFormula() ?? '?';
      final in2 = pins[1].sourceComponent?.calculateFormula() ?? '?';
      final in3 = pins[2].sourceComponent?.calculateFormula() ?? '?';
      return '($in1 . $in2 . $in3)';
    } finally {
      isCalculatingFormula = false;
    }
  }

  @override
  void evaluate() {
    final in1 = pins[0].state;
    final in2 = pins[1].state;
    final in3 = pins[2].state;
    pins[3].state =
        (in1 == LogicState.high &&
            in2 == LogicState.high &&
            in3 == LogicState.high)
        ? LogicState.high
        : LogicState.low;
  }

  @override
  Offset getPinPosition(Pin pin) {
    final index = pins.indexOf(pin);
    if (index == 3) {
      return position + const Offset(80, 20);
    }
    return position + Offset(0, (rect.height / 4) * (index + 1));
  }

  @override
  Rect get rect => Rect.fromLTWH(position.dx, position.dy, 80, 40);
}

class OrGate3Input extends Component {
  OrGate3Input(String id, Offset position)
    : super(id, position, ComponentType.or3) {
    name = 'OR';
    icNumber = '4075';
    pins.add(Pin('in1', this));
    pins.add(Pin('in2', this));
    pins.add(Pin('in3', this));
    pins.add(Pin('out', this, isOutput: true));
  }

  @override
  String calculateFormula() {
    if (isCalculatingFormula) return id;
    isCalculatingFormula = true;
    try {
      final in1 = pins[0].sourceComponent?.calculateFormula() ?? '?';
      final in2 = pins[1].sourceComponent?.calculateFormula() ?? '?';
      final in3 = pins[2].sourceComponent?.calculateFormula() ?? '?';
      return '($in1 + $in2 + $in3)';
    } finally {
      isCalculatingFormula = false;
    }
  }

  @override
  void evaluate() {
    final in1 = pins[0].state;
    final in2 = pins[1].state;
    final in3 = pins[2].state;
    pins[3].state =
        (in1 == LogicState.high ||
            in2 == LogicState.high ||
            in3 == LogicState.high)
        ? LogicState.high
        : LogicState.low;
  }

  @override
  Offset getPinPosition(Pin pin) {
    final index = pins.indexOf(pin);
    if (index == 3) {
      return position + const Offset(80, 20);
    }
    return position + Offset(0, (rect.height / 4) * (index + 1));
  }

  @override
  Rect get rect => Rect.fromLTWH(position.dx, position.dy, 80, 40);
}

class NandGate extends Component {
  NandGate(String id, Offset position)
    : super(id, position, ComponentType.nand) {
    name = 'NAND';
    icNumber = '7400';
    pins.add(Pin('in1', this));
    pins.add(Pin('in2', this));
    pins.add(Pin('out', this, isOutput: true));
  }

  @override
  String calculateFormula() {
    if (isCalculatingFormula) return id;
    isCalculatingFormula = true;
    try {
      final in1 = pins[0].sourceComponent?.calculateFormula() ?? '?';
      final in2 = pins[1].sourceComponent?.calculateFormula() ?? '?';
      return '($in1 . $in2)\'';
    } finally {
      isCalculatingFormula = false;
    }
  }

  @override
  void evaluate() {
    final in1 = pins[0].state;
    final in2 = pins[1].state;
    pins[2].state = !(in1 == LogicState.high && in2 == LogicState.high)
        ? LogicState.high
        : LogicState.low;
  }

  @override
  Offset getPinPosition(Pin pin) {
    final index = pins.indexOf(pin);
    if (index == 2) {
      return position + const Offset(80, 20);
    }
    return position + Offset(0, (rect.height / 3) * (index + 1));
  }

  @override
  Rect get rect => Rect.fromLTWH(position.dx, position.dy, 80, 40);
}

class NorGate extends Component {
  NorGate(String id, Offset position) : super(id, position, ComponentType.nor) {
    name = 'NOR';
    icNumber = '7402';
    pins.add(Pin('in1', this));
    pins.add(Pin('in2', this));
    pins.add(Pin('out', this, isOutput: true));
  }

  @override
  String calculateFormula() {
    if (isCalculatingFormula) return id;
    isCalculatingFormula = true;
    try {
      final in1 = pins[0].sourceComponent?.calculateFormula() ?? '?';
      final in2 = pins[1].sourceComponent?.calculateFormula() ?? '?';
      return '($in1 + $in2)\'';
    } finally {
      isCalculatingFormula = false;
    }
  }

  @override
  void evaluate() {
    final in1 = pins[0].state;
    final in2 = pins[1].state;
    pins[2].state = !(in1 == LogicState.high || in2 == LogicState.high)
        ? LogicState.high
        : LogicState.low;
  }

  @override
  Offset getPinPosition(Pin pin) {
    final index = pins.indexOf(pin);
    if (index == 2) {
      return position + const Offset(80, 20);
    }
    return position + Offset(0, (rect.height / 3) * (index + 1));
  }

  @override
  Rect get rect => Rect.fromLTWH(position.dx, position.dy, 80, 40);
}

class XorGate extends Component {
  XorGate(String id, Offset position) : super(id, position, ComponentType.xor) {
    name = 'XOR';
    icNumber = '7486';
    pins.add(Pin('in1', this));
    pins.add(Pin('in2', this));
    pins.add(Pin('out', this, isOutput: true));
  }

  @override
  String calculateFormula() {
    if (isCalculatingFormula) return id;
    isCalculatingFormula = true;
    try {
      final in1 = pins[0].sourceComponent?.calculateFormula() ?? '?';
      final in2 = pins[1].sourceComponent?.calculateFormula() ?? '?';
      return '($in1 ⊕ $in2)';
    } finally {
      isCalculatingFormula = false;
    }
  }

  @override
  void evaluate() {
    final in1 = pins[0].state;
    final in2 = pins[1].state;
    pins[2].state = (in1 != in2) ? LogicState.high : LogicState.low;
  }

  @override
  Offset getPinPosition(Pin pin) {
    final index = pins.indexOf(pin);
    if (index == 2) {
      return position + const Offset(80, 20);
    }
    return position + Offset(0, (rect.height / 3) * (index + 1));
  }

  @override
  Rect get rect => Rect.fromLTWH(position.dx, position.dy, 80, 40);
}

class XnorGate extends Component {
  XnorGate(String id, Offset position)
    : super(id, position, ComponentType.xnor) {
    name = 'XNOR';
    icNumber = '74266';
    pins.add(Pin('in1', this));
    pins.add(Pin('in2', this));
    pins.add(Pin('out', this, isOutput: true));
  }

  @override
  String calculateFormula() {
    if (isCalculatingFormula) return id;
    isCalculatingFormula = true;
    try {
      final in1 = pins[0].sourceComponent?.calculateFormula() ?? '?';
      final in2 = pins[1].sourceComponent?.calculateFormula() ?? '?';
      return '($in1 ⊙ $in2)';
    } finally {
      isCalculatingFormula = false;
    }
  }

  @override
  void evaluate() {
    final in1 = pins[0].state;
    final in2 = pins[1].state;
    pins[2].state = (in1 == in2) ? LogicState.high : LogicState.low;
  }

  @override
  Offset getPinPosition(Pin pin) {
    final index = pins.indexOf(pin);
    if (index == 2) {
      return position + const Offset(80, 20);
    }
    return position + Offset(0, (rect.height / 3) * (index + 1));
  }

  @override
  Rect get rect => Rect.fromLTWH(position.dx, position.dy, 80, 40);
}

class SwitchComponent extends Component {
  SwitchComponent(String id, Offset position, String name)
    : super(id, position, ComponentType.switch_comp) {
    this.name = name;
    pins.add(Pin('out', this, isOutput: true));
  }

  @override
  String calculateFormula() {
    return name;
  }

  void toggle() {
    pins[0].state = pins[0].state == LogicState.high
        ? LogicState.low
        : LogicState.high;
  }

  @override
  void evaluate() {}

  @override
  Offset getPinPosition(Pin pin) => position + const Offset(40, 20);

  @override
  Rect get rect => Rect.fromLTWH(position.dx, position.dy, 40, 40);
}

class LedComponent extends Component {
  LedComponent(String id, Offset position)
    : super(id, position, ComponentType.led) {
    pins.add(Pin('in', this));
  }

  @override
  String calculateFormula() {
    if (isCalculatingFormula) return id;
    isCalculatingFormula = true;
    try {
      final formula = pins[0].sourceComponent?.calculateFormula() ?? '';
      if (formula.isEmpty) {
        return '';
      }
      try {
        Parser p = Parser();
        Expression exp = p.parse(formula);
        return exp.simplify().toString();
      } catch (e) {
        return formula;
      }
    } finally {
      isCalculatingFormula = false;
    }
  }

  @override
  void evaluate() {}

  @override
  Offset getPinPosition(Pin pin) => position + const Offset(0, 20);

  @override
  Rect get rect => Rect.fromLTWH(position.dx, position.dy, 40, 40);
}
