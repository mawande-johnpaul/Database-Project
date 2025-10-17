// ignore_for_file: library_prefixes, depend_on_referenced_packages

import 'package:flutter/material.dart';
// ...existing code...

class Editor extends StatefulWidget {
  final String initialCode;

  const Editor({super.key, this.initialCode = "print('Hello, Python!')"});

  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialCode);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0), // Apply clipping
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.undo_rounded),
                tooltip: 'Undo',
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.redo_rounded),
                tooltip: 'Redo',
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.run_circle_rounded),
                tooltip: 'Run',
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.save_rounded),
                tooltip: 'Save',
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.format_align_left_rounded),
                tooltip: 'Format',
                onPressed: () {},
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.settings_rounded),
                tooltip: 'Settings',
                onPressed: () {},
              ),
            ],
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: TextField(
                controller: _controller,
                maxLines: null,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Enter code here...",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
