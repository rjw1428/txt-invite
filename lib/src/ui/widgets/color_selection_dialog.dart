import 'package:flutter/material.dart';

class ColorSelectionDialog extends StatelessWidget {
  const ColorSelectionDialog({super.key, required this.selectedColor});

  final Color selectedColor;

  @override
  Widget build(BuildContext context) {
    final List<Color> colors = [
      Colors.black,
      Colors.white,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
    ];

    return AlertDialog(
      title: const Text('Select Text Color'),
      content: SingleChildScrollView(
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children:
              colors.map((color) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(color);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey, width: 1),
                    ),
                    child:
                        selectedColor == color
                            ? Icon(
                              Icons.check,
                              color:
                                  color == Colors.black ? Colors.white : Colors.black,
                            )
                            : null,
                  ),
                );
              }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
