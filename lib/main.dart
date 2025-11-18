// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const VDTKApp());
}

// Command Pattern for Undo/Redo
abstract class Command {
  void execute();
  void undo();
}

class AddComponentCommand implements Command {
  final _CircuitSimulatorState _state;
  final Component _component;

  AddComponentCommand(this._state, this._component);

  @override
  void execute() {
    _state.components.add(_component);
  }

  @override
  void undo() {
    _state.components.remove(_component);
  }
}

class RemoveComponentCommand implements Command {
  final _CircuitSimulatorState _state;
  final Component _component;
  final List<Wire> _removedWires = [];

  RemoveComponentCommand(this._state, this._component) {
    for (var pin in _component.pins) {
      _removedWires.addAll(pin.connections);
    }
  }

  @override
  void execute() {
    _state.components.remove(_component);
    for (var wire in _removedWires) {
      _state.wires.remove(wire);
    }
  }

  @override
  void undo() {
    _state.components.add(_component);
    for (var wire in _removedWires) {
      _state.wires.add(wire);
    }
  }
}

class MoveComponentCommand implements Command {
  final Component _component;
  final Offset _oldPosition;
  final Offset _newPosition;

  MoveComponentCommand(this._component, this._oldPosition, this._newPosition);

  @override
  void execute() {
    _component.position = _newPosition;
  }

  @override
  void undo() {
    _component.position = _oldPosition;
  }
}

class AddWireCommand implements Command {
  final _CircuitSimulatorState _state;
  final Wire _wire;

  AddWireCommand(this._state, this._wire);

  @override
  void execute() {
    _state.wires.add(_wire);
  }

  @override
  void undo() {
    _state.wires.remove(_wire);
  }
}

class VDTKApp extends StatelessWidget {
  const VDTKApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Virtual Digital Trainers Kit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF0A0A0A),
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
      ),
      home: const CircuitSimulator(),
    );
  }
}

enum ComponentType {
  and,
  or,
  not,
  switch_comp,
  led,
  and3,
  or3,
  nand,
  nor,
  xor,
  xnor,
}

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
  bool isInvalid = false;

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
  String name = '';
  String icNumber = '';

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
    name = 'AND';
    icNumber = '7408';
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
  SwitchComponent(String id, Offset position)
    : super(id, position, ComponentType.switch_comp) {
    pins.add(Pin('out', this, isOutput: true));
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

enum InteractionMode { normal, move }

class _CircuitSimulatorState extends State<CircuitSimulator>
    with TickerProviderStateMixin {
  final List<Component> components = [];
  final List<Wire> wires = [];
  final TransformationController transformationController =
      TransformationController();
  Timer? simulationTimer;
  Pin? selectedPin;
  InteractionMode _interactionMode = InteractionMode.normal;
  Component? _draggedComponent;
  Offset? _dragOffset;
  Offset? _panStartOffset;
  late AnimationController _animationController;

  final List<Command> _undoStack = [];
  final List<Command> _redoStack = [];

  @override
  void initState() {
    super.initState();
    startSimulation();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    simulationTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _executeCommand(Command command) {
    setState(() {
      command.execute();
      _undoStack.add(command);
      _redoStack.clear();
    });
  }

  void _undo() {
    if (_undoStack.isEmpty) return;
    setState(() {
      final command = _undoStack.removeLast();
      command.undo();
      _redoStack.add(command);
    });
  }

  void _redo() {
    if (_redoStack.isEmpty) return;
    setState(() {
      final command = _redoStack.removeLast();
      command.execute();
      _undoStack.add(command);
    });
  }

  void _clearAll() {
    setState(() {
      components.clear();
      wires.clear();
      _undoStack.clear();
      _redoStack.clear();
    });
  }

  void _zoom(double scale) {
    final center = context.size! / 2;
    final newMatrix = Matrix4.identity()
      ..translate(center.width, center.height)
      ..scale(scale)
      ..translate(-center.width, -center.height);
    transformationController.value = newMatrix * transformationController.value;
  }

  void _resetView() {
    transformationController.value = Matrix4.identity();
  }

  void startSimulation() {
    simulationTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      setState(() {
        for (var wire in wires) {
          if (wire.isInvalid) {
            wire.state = LogicState.floating;
            continue;
          }
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

    final String id = DateTime.now().millisecondsSinceEpoch.toString();
    Component newComponent;
    switch (type) {
      case ComponentType.and:
        newComponent = AndGate(id, snappedPosition);
        break;
      case ComponentType.or:
        newComponent = OrGate(id, snappedPosition);
        break;
      case ComponentType.not:
        newComponent = NotGate(id, snappedPosition);
        break;
      case ComponentType.switch_comp:
        newComponent = SwitchComponent(id, snappedPosition);
        break;
      case ComponentType.led:
        newComponent = LedComponent(id, snappedPosition);
        break;
      case ComponentType.and3:
        newComponent = AndGate3Input(id, snappedPosition);
        break;
      case ComponentType.or3:
        newComponent = OrGate3Input(id, snappedPosition);
        break;
      case ComponentType.nand:
        newComponent = NandGate(id, snappedPosition);
        break;
      case ComponentType.nor:
        newComponent = NorGate(id, snappedPosition);
        break;
      case ComponentType.xor:
        newComponent = XorGate(id, snappedPosition);
        break;
      case ComponentType.xnor:
        newComponent = XnorGate(id, snappedPosition);
        break;
    }
    _executeCommand(AddComponentCommand(this, newComponent));
  }

  void handleTap(Offset position) {
    if (_interactionMode != InteractionMode.normal) return;

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
        setState(() {
          selectedPin = tappedPin;
        });
      } else {
        if (selectedPin!.owner != tappedPin.owner) {
          final bool isOutputToOutput =
              selectedPin!.isOutput && tappedPin.isOutput;
          final newWire = Wire(
            selectedPin!.isOutput ? selectedPin! : tappedPin,
            selectedPin!.isOutput ? tappedPin : selectedPin!,
          );
          if (isOutputToOutput) {
            newWire.isInvalid = true;
          }
          _executeCommand(AddWireCommand(this, newWire));
        }
        setState(() {
          selectedPin = null;
        });
      }
    } else if (tappedComponent != null && tappedComponent is SwitchComponent) {
      final switchComponent = tappedComponent;
      setState(() {
        switchComponent.toggle();
      });
    } else {
      setState(() {
        selectedPin = null;
      });
    }
  }

  void handleDoubleTap(Offset position) {
    if (_interactionMode != InteractionMode.normal) return;

    Component? toRemove;
    for (var component in components) {
      if (component.rect.contains(position)) {
        toRemove = component;
        break;
      }
    }
    if (toRemove != null) {
      _executeCommand(RemoveComponentCommand(this, toRemove));
    }
  }

  void onPanStart(DragStartDetails details) {
    if (_interactionMode != InteractionMode.move) return;

    final sceneOffset = transformationController.toScene(details.localPosition);

    for (var component in components.reversed) {
      if (component.rect.contains(sceneOffset)) {
        setState(() {
          _draggedComponent = component;
          _dragOffset = sceneOffset - component.position;
          _panStartOffset = component.position;
        });
        break;
      }
    }
  }

  void onPanUpdate(DragUpdateDetails details) {
    if (_draggedComponent == null) return;

    final sceneOffset = transformationController.toScene(details.localPosition);
    final newPosition = sceneOffset - _dragOffset!;
    final snappedPosition = Offset(
      (newPosition.dx / 20).round() * 20.0,
      (newPosition.dy / 20).round() * 20.0,
    );

    setState(() {
      _draggedComponent!.position = snappedPosition;
    });
  }

  void onPanEnd(DragEndDetails details) {
    if (_draggedComponent != null && _panStartOffset != null) {
      if (_panStartOffset != _draggedComponent!.position) {
        _executeCommand(
          MoveComponentCommand(
            _draggedComponent!,
            _panStartOffset!,
            _draggedComponent!.position,
          ),
        );
      }
    }
    setState(() {
      _draggedComponent = null;
      _dragOffset = null;
      _panStartOffset = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTapUp: (details) =>
            handleTap(transformationController.toScene(details.localPosition)),
        onDoubleTapDown: (details) => handleDoubleTap(
          transformationController.toScene(details.localPosition),
        ),
        onPanStart: onPanStart,
        onPanUpdate: onPanUpdate,
        onPanEnd: onPanEnd,
        child: InteractiveViewer(
          transformationController: transformationController,
          minScale: 0.1,
          maxScale: 4.0,
          child: CustomPaint(
            painter: GridPainter(),
            foregroundPainter: CircuitPainter(
              components,
              wires,
              selectedPin,
              _draggedComponent,
              _animationController,
            ),
            child: Container(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _interactionMode = _interactionMode == InteractionMode.normal
                ? InteractionMode.move
                : InteractionMode.normal;
          });
        },
        backgroundColor: _interactionMode == InteractionMode.move
            ? Colors.cyan
            : Colors.grey,
        child: Icon(
          _interactionMode == InteractionMode.move
              ? Icons.pan_tool
              : Icons.touch_app,
          color: Colors.white,
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ActionToolbar(
            onUndo: _undo,
            onRedo: _redo,
            onClear: _clearAll,
            onZoomIn: () => _zoom(1.2),
            onZoomOut: () => _zoom(0.8),
            onResetView: _resetView,
            undoEnabled: _undoStack.isNotEmpty,
            redoEnabled: _redoStack.isNotEmpty,
          ),
          ComponentPalette(onComponentDrag: onComponentDrag),
        ],
      ),
    );
  }
}

class ActionToolbar extends StatelessWidget {
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onClear;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onResetView;
  final bool undoEnabled;
  final bool redoEnabled;

  const ActionToolbar({
    super.key,
    required this.onUndo,
    required this.onRedo,
    required this.onClear,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onResetView,
    required this.undoEnabled,
    required this.redoEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.undo),
            color: undoEnabled ? Colors.white : Colors.grey,
            onPressed: undoEnabled ? onUndo : null,
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            color: redoEnabled ? Colors.white : Colors.grey,
            onPressed: redoEnabled ? onRedo : null,
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            color: Colors.white,
            onPressed: onClear,
          ),
          const VerticalDivider(color: Colors.grey, width: 20, thickness: 1),
          IconButton(
            icon: const Icon(Icons.zoom_in),
            color: Colors.white,
            onPressed: onZoomIn,
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out),
            color: Colors.white,
            onPressed: onZoomOut,
          ),
          IconButton(
            icon: const Icon(Icons.center_focus_strong),
            color: Colors.white,
            onPressed: onResetView,
          ),
        ],
      ),
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
                feedback: const Icon(
                  Icons.power_settings_new,
                  color: Colors.cyan,
                  size: 40,
                ),
                child: const Icon(
                  Icons.power_settings_new,
                  color: Colors.white,
                  size: 40,
                ),
                onDragEnd: (details) =>
                    onComponentDrag(details, ComponentType.switch_comp),
              ),
              Draggable<ComponentType>(
                data: ComponentType.led,
                feedback: const Icon(
                  Icons.lightbulb,
                  color: Colors.yellow,
                  size: 40,
                ),
                child: const Icon(
                  Icons.lightbulb_outline,
                  color: Colors.white,
                  size: 40,
                ),
                onDragEnd: (details) =>
                    onComponentDrag(details, ComponentType.led),
              ),
              Draggable<ComponentType>(
                data: ComponentType.and,
                feedback: _buildGateIcon('AND'),
                child: _buildGateIcon('AND'),
                onDragEnd: (details) =>
                    onComponentDrag(details, ComponentType.and),
              ),
              Draggable<ComponentType>(
                data: ComponentType.or,
                feedback: _buildGateIcon('OR'),
                child: _buildGateIcon('OR'),
                onDragEnd: (details) =>
                    onComponentDrag(details, ComponentType.or),
              ),
              Draggable<ComponentType>(
                data: ComponentType.not,
                feedback: _buildGateIcon('NOT'),
                child: _buildGateIcon('NOT'),
                onDragEnd: (details) =>
                    onComponentDrag(details, ComponentType.not),
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
                onDragEnd: (details) =>
                    onComponentDrag(details, ComponentType.and3),
              ),
              Draggable<ComponentType>(
                data: ComponentType.or3,
                feedback: _buildGateIcon('OR3'),
                child: _buildGateIcon('OR3'),
                onDragEnd: (details) =>
                    onComponentDrag(details, ComponentType.or3),
              ),
              Draggable<ComponentType>(
                data: ComponentType.nand,
                feedback: _buildGateIcon('NAND'),
                child: _buildGateIcon('NAND'),
                onDragEnd: (details) =>
                    onComponentDrag(details, ComponentType.nand),
              ),
              Draggable<ComponentType>(
                data: ComponentType.nor,
                feedback: _buildGateIcon('NOR'),
                child: _buildGateIcon('NOR'),
                onDragEnd: (details) =>
                    onComponentDrag(details, ComponentType.nor),
              ),
              Draggable<ComponentType>(
                data: ComponentType.xor,
                feedback: _buildGateIcon('XOR'),
                child: _buildGateIcon('XOR'),
                onDragEnd: (details) =>
                    onComponentDrag(details, ComponentType.xor),
              ),
              Draggable<ComponentType>(
                data: ComponentType.xnor,
                feedback: _buildGateIcon('XNOR'),
                child: _buildGateIcon('XNOR'),
                onDragEnd: (details) =>
                    onComponentDrag(details, ComponentType.xnor),
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
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
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
  final Component? draggedComponent;
  final Animation<double> animation;

  CircuitPainter(
    this.components,
    this.wires,
    this.selectedPin,
    this.draggedComponent,
    this.animation,
  ) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final wirePaint = Paint()
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    if (draggedComponent != null) {
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          draggedComponent!.rect.translate(5, 5),
          const Radius.circular(4),
        ),
        shadowPaint,
      );
    }

    for (var wire in wires) {
      if (wire.isInvalid) {
        final pulse = (sin(2 * pi * animation.value) + 1) / 2;
        final color = Color.lerp(Colors.red.shade900, Colors.redAccent, pulse)!;
        wirePaint.color = color;
        wirePaint.strokeWidth = 2.0 + pulse * 2.0;
      } else {
        wirePaint.color = wire.state == LogicState.high
            ? Colors.greenAccent
            : Colors.red.shade900;
        wirePaint.strokeWidth = 2.0;
      }

      final path = Path();
      path.moveTo(wire.from.position.dx, wire.from.position.dy);
      path.cubicTo(
        wire.from.position.dx + 50,
        wire.from.position.dy,
        wire.to.position.dx - 50,
        wire.to.position.dy,
        wire.to.position.dx,
        wire.to.position.dy,
      );
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
    final bool isDragged = component == draggedComponent;

    if (component is SwitchComponent) {
      _drawSwitch(canvas, component, isDragged);
    } else if (component is LedComponent) {
      _drawLed(canvas, component, isDragged);
    } else {
      _drawGate(canvas, component, isDragged);
    }

    for (var pin in component.pins) {
      final pinPaint = Paint();
      bool isInvalidPin = pin.connections.any((w) => w.isInvalid);

      if (isInvalidPin) {
        final pulse = (sin(2 * pi * animation.value) + 1) / 2;
        final color = Color.lerp(Colors.red.shade900, Colors.redAccent, pulse)!;
        final glowPaint = Paint()
          ..color = color.withOpacity(0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);
        canvas.drawCircle(pin.position, 8 + pulse * 4, glowPaint);
        pinPaint.color = color;
      } else {
        pinPaint.color = pin.state == LogicState.high
            ? Colors.greenAccent
            : Colors.grey.shade600;
      }
      canvas.drawCircle(pin.position, 4, pinPaint);
    }
  }

  void _drawGate(Canvas canvas, Component component, bool isDragged) {
    final rect = component.rect;
    final componentPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF3A3A3A), Color(0xFF2A2A2A)],
      ).createShader(rect);
    final borderPaint = Paint()
      ..color = isDragged ? Colors.yellow : Colors.cyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = isDragged ? 2.0 : 1.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      componentPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      borderPaint,
    );

    // Notch
    final notchPath = Path();
    notchPath.moveTo(rect.left + rect.width / 2 - 5, rect.top);
    notchPath.arcToPoint(
      Offset(rect.left + rect.width / 2 + 5, rect.top),
      radius: const Radius.circular(5),
    );
    canvas.drawPath(notchPath, borderPaint..style = PaintingStyle.fill);

    final textStyle = const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );
    final textSpan = TextSpan(
      text: '${component.name}\n${component.icNumber}',
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(minWidth: 0, maxWidth: rect.width);
    textPainter.paint(
      canvas,
      component.position +
          Offset(
            (rect.width - textPainter.width) / 2,
            (rect.height - textPainter.height) / 2,
          ),
    );

    // Pins
    final pinPaint = Paint()..color = Colors.grey.shade600;
    for (var pin in component.pins) {
      final pinPos = pin.position;
      if (pin.isOutput) {
        canvas.drawRect(
          Rect.fromCenter(center: pinPos, width: 10, height: 2),
          pinPaint,
        );
      } else {
        canvas.drawRect(
          Rect.fromCenter(center: pinPos, width: 10, height: 2),
          pinPaint,
        );
      }
    }
  }

  void _drawSwitch(Canvas canvas, SwitchComponent component, bool isDragged) {
    final borderPaint = Paint()
      ..color = isDragged ? Colors.yellow : Colors.cyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = isDragged ? 2.0 : 1.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(component.rect, const Radius.circular(4)),
      borderPaint,
    );
    final switchPaint = Paint()
      ..color = component.pins[0].state == LogicState.high
          ? Colors.greenAccent
          : Colors.red.shade900;
    canvas.drawCircle(
      component.position + const Offset(20, 20),
      10,
      switchPaint,
    );
  }

  void _drawLed(Canvas canvas, LedComponent component, bool isDragged) {
    final borderPaint = Paint()
      ..color = isDragged ? Colors.yellow : Colors.cyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = isDragged ? 2.0 : 1.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(component.rect, const Radius.circular(4)),
      borderPaint,
    );
    final ledPaint = Paint()
      ..color = component.pins[0].state == LogicState.high
          ? Colors.yellow
          : Colors.grey.shade800;
    canvas.drawCircle(component.position + const Offset(20, 20), 15, ledPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
