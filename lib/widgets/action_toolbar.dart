import 'package:flutter/material.dart';

class ActionToolbar extends StatelessWidget {
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onClear;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onResetView;
  final bool undoEnabled;
  final bool redoEnabled;
  final TextEditingController notesController;

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
    required this.notesController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Column(
        children: [
          Row(
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
              const VerticalDivider(
                color: Colors.grey,
                width: 20,
                thickness: 1,
              ),
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
              IconButton(
                icon: const Icon(Icons.more_vert),
                color: Colors.white,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('How to Use'),
                      content: const SingleChildScrollView(
                        child: Text(
                          'Welcome to the Virtual Digital Logic Trainer!\n\n'
                          'Adding Components:\n'
                          '- Drag and drop components from the palette at the bottom onto the canvas.\n\n'
                          'Connecting Components:\n'
                          '- Tap on a pin to select it.\n'
                          '- Tap on another pin to create a wire between them.\n\n'
                          'Interacting with Components:\n'
                          '- Double-tap a component to remove it.\n'
                          '- Tap on a switch to toggle its state.\n\n'
                          'Moving Components:\n'
                          '- Use the hand tool in the bottom right to switch to move mode.\n'
                          '- Drag components to move them around the canvas.\n\n'
                          'Canvas Control:\n'
                          '- Use the zoom buttons to zoom in and out.\n'
                          '- Use the reset view button to reset the canvas.\n',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const Divider(color: Colors.grey),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: notesController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Notes',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
