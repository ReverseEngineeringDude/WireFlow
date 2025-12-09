// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';

// Models
import 'models/enums.dart';
import 'models/pin.dart';
import 'models/wire.dart';
import 'models/component.dart';
import 'models/gates.dart';

// Commands
import 'commands/command.dart';
import 'commands/commands.dart';

// Widgets
import 'widgets/action_toolbar.dart';
import 'widgets/component_palette.dart';

// Painters
import 'painters/grid_painter.dart';
import 'painters/circuit_painter.dart';

void main() {
  runApp(const VDTKApp());
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

class CircuitSimulator extends StatefulWidget {
  const CircuitSimulator({super.key});

  @override
  State<CircuitSimulator> createState() => _CircuitSimulatorState();
}

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
  int _nextSwitchId = 0;
  final TextEditingController _notesController = TextEditingController();

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
    _notesController.dispose();
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
      _nextSwitchId = 0;
      _updateFormulas();
    });
  }

  void _updateFormulas() {
    for (var component in components) {
      component.formula = component.calculateFormula();
    }
  }

  String _getNthSwitchName(int n) {
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    String result = '';
    do {
      result = alphabet[n % alphabet.length] + result;
      n = (n / alphabet.length).floor() - 1;
    } while (n >= 0);
    return result;
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
        newComponent = SwitchComponent(
          id,
          snappedPosition,
          _getNthSwitchName(_nextSwitchId++),
        );
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
    _executeCommand(
      AddComponentCommand(components, wires, newComponent, _updateFormulas),
    );
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
          _executeCommand(AddWireCommand(wires, newWire, _updateFormulas));
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
      _executeCommand(
        RemoveComponentCommand(components, wires, toRemove, _updateFormulas),
      );
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
            notesController: _notesController,
          ),
          ComponentPalette(onComponentDrag: onComponentDrag),
        ],
      ),
    );
  }
}
