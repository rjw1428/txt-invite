import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:screenshot/screenshot.dart';

class InvitationCustomizationStep extends StatefulWidget {
  const InvitationCustomizationStep(
      {super.key, required this.formKey, this.selectedTemplate, required this.screenshotController});

  final GlobalKey<FormState> formKey;
  final String? selectedTemplate;
  final ScreenshotController screenshotController;

  @override
  State<InvitationCustomizationStep> createState() =>
      _InvitationCustomizationStepState();
}

class _InvitationCustomizationStepState
    extends State<InvitationCustomizationStep> {
  final TextEditingController _invitationTextController =
      TextEditingController(text: 'Your Invitation Text Here');
  double _fontSize = 24.0;
  String _fontFamily = 'Roboto'; // Default font
  Color _textColor = Colors.black;
  Offset _textPosition = const Offset(50, 50); // Initial position

  XFile? _pickedImage;
  Offset _imagePosition = const Offset(100, 200); // Initial position
  double _imageScale = 1.0;

  @override
  void dispose() {
    _invitationTextController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _pickedImage = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Form(
      key: widget.formKey,
      child: Column(
        children: [
          Expanded(
            child: Screenshot(
              controller: widget.screenshotController,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  image: widget.selectedTemplate != null &&
                          widget.selectedTemplate!.startsWith('/')
                      ? DecorationImage(
                          image: FileImage(File(widget.selectedTemplate!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: Stack(
                  children: [
                    // Draggable Text
                    Positioned(
                      left: _textPosition.dx,
                      top: _textPosition.dy,
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          setState(() {
                            _textPosition += details.delta;
                          });
                        },
                        child: Text(
                          _invitationTextController.text,
                          style: GoogleFonts.getFont(
                            _fontFamily,
                            fontSize: _fontSize,
                            color: _textColor,
                          ),
                        ),
                      ),
                    ),

                    // Draggable and Scalable Image
                    if (_pickedImage != null)
                      Positioned(
                        left: _imagePosition.dx,
                        top: _imagePosition.dy,
                        child: GestureDetector(
                          onScaleUpdate: (details) {
                            setState(() {
                              _imageScale = details.scale;
                            });
                          },
                          child: Transform.scale(
                            scale: _imageScale,
                            child: Image.file(
                              File(_pickedImage!.path),
                              width: 150, // Base width for scaling
                              height: 150, // Base height for scaling
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    if (widget.selectedTemplate != null &&
                        !widget.selectedTemplate!.startsWith('/'))
                      Center(
                        child: Text(
                          widget.selectedTemplate!,
                          style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      )
                  ],
                ),
              ),
            ),
          ),
          // Controls for customization
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _invitationTextController,
                  decoration: const InputDecoration(
                    labelText: 'Invitation Text',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (text) {
                    setState(() {}); // Rebuild to update text
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: _fontSize,
                        min: 10.0,
                        max: 50.0,
                        divisions: 40,
                        label: _fontSize.round().toString(),
                        onChanged: (value) {
                          setState(() {
                            _fontSize = value;
                          });
                        },
                      ),
                    ),
                    Text('Font Size: ${_fontSize.round()}'),
                  ],
                ),
                const SizedBox(height: 10),
                DropdownButton<String>(
                  value: _fontFamily,
                  onChanged: (String? newValue) {
                    setState(() {
                      _fontFamily = newValue!;
                    });
                  },
                  items: GoogleFonts.asMap()
                      .keys
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('Pick Image'),
                ),
                if (_pickedImage != null)
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _imageScale,
                          min: 0.5,
                          max: 2.0,
                          divisions: 15,
                          label: _imageScale.toStringAsFixed(1),
                          onChanged: (value) {
                            setState(() {
                              _imageScale = value;
                            });
                          },
                        ),
                      ),
                      Text('Image Scale: ${_imageScale.toStringAsFixed(1)}'),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}
