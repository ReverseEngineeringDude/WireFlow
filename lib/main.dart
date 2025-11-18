import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const VDTKApp());
}

class VDTKApp extends StatelessWidget {
  const VDTKApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Virtual Digital Trainers Kit',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF0A0A0A),
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      home: const CircuitSimulator(),
    );
  }
}

enum ComponentType { and, or, not, switch_comp, led, and3, or3, nand, nor, xor, xnor }

enum LogicState { high, low, floating }

class Pin {
  final String id;
  final Component owner;
  final bool isOutput;
  LogicState state = LogicState.low;
  final List<Wire> connections = [];
  Offset get position => owner.getPinPosition(this);

  Pin(this.id, this.owner, {this.isOutput = false});
}

class Wire {
  final Pin from;
  final Pin to;
  LogicState state = LogicState.low;

  Wire(this.from, this.to) {
    from.connections.add(this);
    to.connections.add(this);
  }

  void dispose() {
    from.connections.remove(this);
    to.connections.remove(this);
  }
}

abstract class Component {
  final String id;
  Offset position;
  final ComponentType type;
  final List<Pin> pins = [];

  Component(this.id, this.position, this.type);

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

class AndGate extends Component {
  AndGate(String id, Offset position) : super(id, position, ComponentType.and) {
    pins.add(Pin('in1', this));
    pins.add(Pin('in2', this));
    pins.add(Pin('out', this, isOutput: true));
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
    return position + Offset(0, 13.33 + (index * 13.33));
  }

  @override
  Rect get rect => Rect.fromLTWH(position.dx, position.dy, 80, 40);
}

class OrGate extends Component {
  OrGate(String id, Offset position) : super(id, position, ComponentType.or) {
    pins.add(Pin('in1', this));
    pins.add(Pin('in2', this));
    pins.add(Pin('out', this, isOutput: true));
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
    return position + Offset(0, 13.33 + (index * 13.33));
  }

  @override
  Rect get rect => Rect.fromLTWH(position.dx, position.dy, 80, 40);
}

class NotGate extends Component {
  NotGate(String id, Offset position) : super(id, position, ComponentType.not) {
    pins.add(Pin('in', this));
    pins.add(Pin('out', this, isOutput: true));
  }

  @override
  void evaluate() {
    pins[1].state =
        pins[0].state == LogicState.high ? LogicState.low : LogicState.high;
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
  AndGate3Input(String id, Offset position) : super(id, position, ComponentType.and3) {
    pins.add(Pin('in1', this));
    pins.add(Pin('in2', this));
    pins.add(Pin('in3', this));
    pins.add(Pin('out', this, isOutput: true));
  }

  @override
  void evaluate() {
    final in1 = pins[0].state;
    final in2 = pins[1].state;
    final in3 = pins[2].state;
    pins[3].state = (in1 == LogicState.high && in2 == LogicState.high && in3 == LogicState.high)
        ? LogicState.high
        : LogicState.low;
  }

  @override
  Offset getPinPosition(Pin pin) {
    final index = pins.indexOf(pin);
    if (index == 3) {
      return position + const Offset(80, 20);
    }
    return position + Offset(0, 10 + (index * 10));
  }

  @override
  Rect get rect => Rect.fromLTWH(position.dx, position.dy, 80, 40);
}

class OrGate3Input extends Component {
  OrGate3Input(String id, Offset position) : super(id, position, ComponentType.or3) {
    pins.add(Pin('in1', this));
    pins.add(Pin('in2', this));
    pins.add(Pin('in3', this));
    pins.add(Pin('out', this, isOutput: true));
  }

  @override
  void evaluate() {
    final in1 = pins[0].state;
    final in2 = pins[1].state;
    final in3 = pins[2].state;
    pins[3].state = (in1 == LogicState.high || in2 == LogicState.high || in3 == LogicState.high)
        ? LogicState.high
        : LogicState.low;
  }

  @override
  Offset getPinPosition(Pin pin) {
    final index = pins.indexOf(pin);
    if (index == 3) {
      return position + const Offset(80, 20);
    }
    return position + Offset(0, 10 + (index * 10));
  }

  @override
  Rect get rect => Rect.fromLTWH(position.dx, position.dy, 80, 40);
}

class NandGate extends Component {
  NandGate(String id, Offset position) : super(id, position, ComponentType.nand) {
    pins.add(Pin('in1', this));
    pins.add(Pin('in2', this));
    pins.add(Pin('out', this, isOutput: true));
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
    return position + Offset(0, 13.33 + (index * 13.33));
  }

  @override
  Rect get rect => Rect.fromLTWH(position.dx, position.dy, 80, 40);
}

class NorGate extends Component {
  NorGate(String id, Offset position) : super(id, position, ComponentType.nor) {
    pins.add(Pin('in1', this));
    pins.add(Pin('in2', this));
    pins.add(Pin('out', this, isOutput: true));
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
    return position + Offset(0, 13.33 + (index * 13.33));
  }

  @override
  Rect get rect => Rect.fromLTWH(position.dx, position.dy, 80, 40);
}

class XorGate extends Component {
  XorGate(String id, Offset position) : super(id, position, ComponentType.xor) {
    pins.add(Pin('in1', this));
    pins.add(Pin('in2', this));
    pins.add(Pin('out', this, isOutput: true));
  }

  @override
  void evaluate() {
    final in1 = pins[0].state;
    final in2 = pins[1].state;
    pins[2].state = (in1 != in2)
        ? LogicState.high
        : LogicState.low;
  }

  @override
  Offset getPinPosition(Pin pin) {
    final index = pins.indexOf(pin);
    if (index == 2) {
      return position + const Offset(80, 20);
    }
    return position + Offset(0, 13.33 + (index * 13.33));
  }

  @override
  Rect get rect => Rect.fromLTWH(position.dx, position.dy, 80, 40);
}

class XnorGate extends Component {
  XnorGate(String id, Offset position) : super(id, position, ComponentType.xnor) {
    pins.add(Pin('in1', this));
    pins.add(Pin('in2', this));
    pins.add(Pin('out', this, isOutput: true));
  }

  @override
  void evaluate() {
    final in1 = pins[0].state;
    final in2 = pins[1].state;
    pins[2].state = (in1 == in2)
        ? LogicState.high
        : LogicState.low;
  }

  @override
  Offset getPinPosition(Pin pin) {
    final index = pins.indexOf(pin);
    if (index == 2) {
      return position + const Offset(80, 20);
    }
    return position + Offset(0, 13.33 + (index * 13.33));
  }

  @override
  Rect get rect => Rect.fromLTWH(position.dx, position.dy, 80, 40);
}

class SwitchComponent extends Component {
  SwitchComponent(String id, Offset position)
      : super(id, position, ComponentType.switch_comp) {
    pins.add(Pin('out', this, isOutput: true));
  }

  void toggle() {
    pins[0].state =
        pins[0].state == LogicState.high ? LogicState.low : LogicState.high;
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
  void evaluate() {}

  @override
  Offset getPinPosition(Pin pin) => position + const Offset(0, 20);

  @override
  Rect get rect => Rect.fromLTWH(position.dx, position.dy, 40, 40);
}

class CircuitSimulator extends StatefulWidget {
  const CircuitSimulator({super.key});

  @override
  State<CircuitSimulator> createState() => _CircuitSimulatorState();
}

class _CircuitSimulatorState extends State<CircuitSimulator> {
  final List<Component> components = [];
  final List<Wire> wires = [];
  final TransformationController transformationController =
      TransformationController();
  Timer? simulationTimer;
  Pin? selectedPin;

  @override
  void initState() {
    super.initState();
    startSimulation();
  }

  @override
  void dispose() {
    simulationTimer?.cancel();
    super.dispose();
  }

  void startSimulation() {
    simulationTimer =
        Timer.periodic(const Duration(milliseconds: 16), (timer) {
      setState(() {
        for (var wire in wires) {
          wire.state = wire.from.state;
          wire.to.state = wire.state;
        }
        for (var component in components) {
          component.evaluate();
        }
      });
    });
  }

  void onComponentDrag(DraggableDetails details, ComponentType type) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset localPosition = renderBox.globalToLocal(details.offset);
    final Offset snappedPosition = Offset(
      (localPosition.dx / 20).round() * 20.0,
      (localPosition.dy / 20).round() * 20.0,
    );

    setState(() {
      final String id = DateTime.now().millisecondsSinceEpoch.toString();
      switch (type) {
        case ComponentType.and:
          components.add(AndGate(id, snappedPosition));
          break;
        case ComponentType.or:
          components.add(OrGate(id, snappedPosition));
          break;
        case ComponentType.not:
          components.add(NotGate(id, snappedPosition));
          break;
        case ComponentType.switch_comp:
          components.add(SwitchComponent(id, snappedPosition));
          break;
        case ComponentType.led:
          components.add(LedComponent(id, snappedPosition));
          break;
        case ComponentType.and3:
          components.add(AndGate3Input(id, snappedPosition));
          break;
        case ComponentType.or3:
          components.add(OrGate3Input(id, snappedPosition));
          break;
        case ComponentType.nand:
          components.add(NandGate(id, snappedPosition));
          break;
        case ComponentType.nor:
          components.add(NorGate(id, snappedPosition));
          break;
        case ComponentType.xor:
          components.add(XorGate(id, snappedPosition));
          break;
        case ComponentType.xnor:
          components.add(XnorGate(id, snappedPosition));
          break;
      }
    });
  }

  void handleTap(Offset position) {
    Pin? tappedPin;
    Component? tappedComponent;

    for (var component in components) {
      if (component.rect.contains(position)) {
        tappedComponent = component;
      }
      for (var pin in component.pins) {
        if ((pin.position - position).distance < 8.0) {
          tappedPin = pin;
          break;
        }
      }
      if (tappedPin != null) {
        tappedComponent = null; 
        break;
      }
    }

    if (tappedPin != null) {
      if (selectedPin == null) {
        selectedPin = tappedPin;
      } else {
        if (selectedPin!.owner != tappedPin.owner &&
            selectedPin!.isOutput != tappedPin.isOutput) {
          setState(() {
            wires.add(Wire(
                selectedPin!.isOutput ? selectedPin! : tappedPin!,
                selectedPin!.isOutput ? tappedPin! : selectedPin!));
          });
        }
        selectedPin = null;
      }
    } else if (tappedComponent != null && tappedComponent is SwitchComponent) {
      final switchComponent = tappedComponent;
      setState(() {
        switchComponent.toggle();
      });
    } else {
      selectedPin = null;
    }
    setState(() {});
  }

  void handleDoubleTap(Offset position) {
    Component? toRemove;
    for (var component in components) {
      if (component.rect.contains(position)) {
        toRemove = component;
        break;
      }
    }
    if (toRemove != null) {
      final componentToRemove = toRemove;
      setState(() {
        for (var pin in componentToRemove.pins) {
          for (var wire in List.from(pin.connections)) {
            wires.remove(wire);
            wire.dispose();
          }
        }
        components.remove(componentToRemove);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTapUp: (details) => handleTap(details.localPosition),
        onDoubleTapDown: (details) => handleDoubleTap(details.localPosition),
        child: InteractiveViewer(
          transformationController: transformationController,
          minScale: 0.1,
          maxScale: 2.0,
          child: CustomPaint(
            painter: GridPainter(),
            foregroundPainter: CircuitPainter(components, wires, selectedPin),
            child: Container(),
          ),
        ),
      ),
      bottomNavigationBar: ComponentPalette(onComponentDrag: onComponentDrag),
    );
  }
}

class ComponentPalette extends StatelessWidget {
  final Function(DraggableDetails, ComponentType) onComponentDrag;

  const ComponentPalette({super.key, required this.onComponentDrag});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      height: 160,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Draggable<ComponentType>(
                data: ComponentType.switch_comp,
                feedback: const Icon(Icons.power_settings_new,
                    color: Colors.cyan, size: 40),
                child: const Icon(Icons.power_settings_new,
                    color: Colors.white, size: 40),
                onDragEnd: (details) =>
                    onComponentDrag(details, ComponentType.switch_comp),
              ),
              Draggable<ComponentType>(
                data: ComponentType.led,
                feedback: const Icon(Icons.lightbulb, color: Colors.yellow, size: 40),
                child: const Icon(Icons.lightbulb_outline,
                    color: Colors.white, size: 40),
                onDragEnd: (details) => onComponentDrag(details, ComponentType.led),
              ),
              Draggable<ComponentType>(
                data: ComponentType.and,
                feedback: _buildGateIcon('AND'),
                child: _buildGateIcon('AND'),
                onDragEnd: (details) => onComponentDrag(details, ComponentType.and),
              ),
              Draggable<ComponentType>(
                data: ComponentType.or,
                feedback: _buildGateIcon('OR'),
                child: _buildGateIcon('OR'),
                onDragEnd: (details) => onComponentDrag(details, ComponentType.or),
              ),
              Draggable<ComponentType>(
                data: ComponentType.not,
                feedback: _buildGateIcon('NOT'),
                child: _buildGateIcon('NOT'),
                onDragEnd: (details) => onComponentDrag(details, ComponentType.not),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Draggable<ComponentType>(
                data: ComponentType.and3,
                feedback: _buildGateIcon('AND3'),
                child: _buildGateIcon('AND3'),
                onDragEnd: (details) => onComponentDrag(details, ComponentType.and3),
              ),
              Draggable<ComponentType>(
                data: ComponentType.or3,
                feedback: _buildGateIcon('OR3'),
                child: _buildGateIcon('OR3'),
                onDragEnd: (details) => onComponentDrag(details, ComponentType.or3),
              ),
              Draggable<ComponentType>(
                data: ComponentType.nand,
                feedback: _buildGateIcon('NAND'),
                child: _buildGateIcon('NAND'),
                onDragEnd: (details) => onComponentDrag(details, ComponentType.nand),
              ),
              Draggable<ComponentType>(
                data: ComponentType.nor,
                feedback: _buildGateIcon('NOR'),
                child: _buildGateIcon('NOR'),
                onDragEnd: (details) => onComponentDrag(details, ComponentType.nor),
              ),
              Draggable<ComponentType>(
                data: ComponentType.xor,
                feedback: _buildGateIcon('XOR'),
                child: _buildGateIcon('XOR'),
                onDragEnd: (details) => onComponentDrag(details, ComponentType.xor),
              ),
              Draggable<ComponentType>(
                data: ComponentType.xnor,
                feedback: _buildGateIcon('XNOR'),
                child: _buildGateIcon('XNOR'),
                onDragEnd: (details) => onComponentDrag(details, ComponentType.xnor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGateIcon(String label) {
    return Container(
      width: 60,
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 0.5;

    for (double i = 0; i < size.width; i += 20) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 20) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CircuitPainter extends CustomPainter {
  final List<Component> components;
  final List<Wire> wires;
  final Pin? selectedPin;

  CircuitPainter(this.components, this.wires, this.selectedPin);

  @override
  void paint(Canvas canvas, Size size) {
    final wirePaint = Paint()
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (var wire in wires) {
      wirePaint.color = wire.state == LogicState.high
          ? Colors.greenAccent
          : Colors.red.shade900;
      final path = Path();
      path.moveTo(wire.from.position.dx, wire.from.position.dy);
      path.cubicTo(
          wire.from.position.dx + 50,
          wire.from.position.dy,
          wire.to.position.dx - 50,
          wire.to.position.dy,
          wire.to.position.dx,
          wire.to.position.dy);
      canvas.drawPath(path, wirePaint);
    }

    for (var component in components) {
      _drawComponent(canvas, component);
    }

    if (selectedPin != null) {
      final paint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.fill;
      canvas.drawCircle(selectedPin!.position, 6, paint);
    }
  }

  void _drawComponent(Canvas canvas, Component component) {
    final componentPaint = Paint()
      ..color = const Color(0xFF2A2A2A)
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = Colors.cyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    canvas.drawRRect(
        RRect.fromRectAndRadius(component.rect, const Radius.circular(4)),
        componentPaint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(component.rect, const Radius.circular(4)),
        borderPaint);

    if (component is SwitchComponent) {
      final switchPaint = Paint()
        ..color = component.pins[0].state == LogicState.high
            ? Colors.greenAccent
            : Colors.red.shade900;
      canvas.drawCircle(component.position + const Offset(20, 20), 10, switchPaint);
    } else if (component is LedComponent) {
      final ledPaint = Paint()
        ..color = component.pins[0].state == LogicState.high
            ? Colors.yellow
            : Colors.grey.shade800;
      canvas.drawCircle(component.position + const Offset(20, 20), 15, ledPaint);
    } else {
      textPainter.text = TextSpan(
        text: component.type.toString().split('.').last.toUpperCase(),
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
      );
      textPainter.layout(minWidth: 0, maxWidth: component.rect.width);
      textPainter.paint(
          canvas,
          component.position +
              Offset((component.rect.width - textPainter.width) / 2,
                  (component.rect.height - textPainter.height) / 2));
    }

    for (var pin in component.pins) {
      final pinPaint = Paint()
        ..color = pin.state == LogicState.high
            ? Colors.greenAccent
            : Colors.grey.shade600;
      canvas.drawCircle(pin.position, 4, pinPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}