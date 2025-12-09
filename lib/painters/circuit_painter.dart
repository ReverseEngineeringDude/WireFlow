import 'dart:math';
import 'package:flutter/material.dart';
import '../models/component.dart';
import '../models/wire.dart';
import '../models/pin.dart';
import '../models/enums.dart';
import '../models/gates.dart';

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

    _drawFormula(canvas, component);

    for (var pin in component.pins) {
      final pinPaint = Paint();
      bool isInvalidPin = false;

      // Check if any connection is invalid (safely cast from dynamic)
      for (var connection in pin.connections) {
        if (connection is Wire && connection.isInvalid) {
          isInvalidPin = true;
          break;
        }
      }

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

  void _drawFormula(Canvas canvas, Component component) {
    if (component.formula.isEmpty) return;

    final textStyle = const TextStyle(color: Colors.white, fontSize: 12);
    final textSpan = TextSpan(text: component.formula, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      component.position +
          Offset(
            (component.rect.width - textPainter.width) / 2,
            -textPainter.height - 5,
          ),
    );
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

    final pinPaint = Paint()..color = Colors.grey.shade600;
    for (var pin in component.pins) {
      final pinPos = pin.position;
      canvas.drawRect(
        Rect.fromCenter(center: pinPos, width: 10, height: 2),
        pinPaint,
      );
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

    // Check if LED has a valid connection
    bool hasValidConnection = false;
    if (component.pins[0].connections.isNotEmpty) {
      for (var connection in component.pins[0].connections) {
        if (connection is Wire && !connection.isInvalid) {
          hasValidConnection = true;
          break;
        }
      }
    }

    final ledPaint = Paint()
      ..color = hasValidConnection && component.pins[0].state == LogicState.high
          ? Colors.yellow
          : Colors.grey.shade800;
    canvas.drawCircle(component.position + const Offset(20, 20), 15, ledPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
