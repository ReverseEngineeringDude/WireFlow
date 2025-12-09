import 'package:flutter/material.dart';
import '../models/enums.dart';

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

  static Widget _buildGateIcon(String label) {
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
