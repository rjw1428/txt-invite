import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:txt_invite/src/models/invitation.dart';
import 'package:txt_invite/src/ui/widgets/color_selection_dialog.dart';

import 'package:screenshot/screenshot.dart';

class InvitationCustomizationStep extends StatefulWidget {
  const InvitationCustomizationStep({
    super.key,
    required this.formKey,
    required this.selectedTemplate,
    required this.screenshotController,
    required this.isTakingScreenshot,
  });

  final GlobalKey<FormState> formKey;
  final Invitation selectedTemplate;
  final ScreenshotController screenshotController;
  final bool isTakingScreenshot;

  @override
  State<InvitationCustomizationStep> createState() =>
      _InvitationCustomizationStepState();
}

class _InvitationCustomizationStepState
    extends State<InvitationCustomizationStep> {
  late Invitation _invitation;
  final TextEditingController _invitationTextController = TextEditingController();  
  TextElement? selectedElement;

  @override
  void initState() {
    super.initState();
    _invitation = widget.selectedTemplate;
    _invitationTextController.text = _invitation.textElements.first.content;
  }

  @override
  void dispose() {
    _invitationTextController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _invitation.imageElements.add(
          ImageElement(
            imageUrl: image.path,
            width: 150,
            height: 150,
            x: 100,
            y: 200,
          ),
        );
      });
    }
  }

  String getFont(String fontName) {
    return GoogleFonts.asMap()
      .keys
      .firstWhere((key) => key.toLowerCase() == fontName.toLowerCase(),
          orElse: () => 'Roboto');
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isTakingScreenshot) {
      selectedElement = null;
    }
    return Scaffold(
        floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _pickImage,
            child: const Icon(Icons.add_a_photo),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
              setState(() {
                _invitation.textElements.add(
                  TextElement(
                    content: 'New Text',
                    x: 50,
                    y: 50,
                    size: 20,
                    color: Colors.black,
                    fontFace: 'Roboto',
                  ),
                );
              });
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
        body: Form(
      key: widget.formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Screenshot(
              controller: widget.screenshotController,
              child: Container(
                width: _invitation.width,
                height: _invitation.height,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  image: _invitation.backgroundImage.isNotEmpty
                      ? (_invitation.backgroundImage.startsWith('/')
                          ? DecorationImage(
                              image: FileImage(File(_invitation.backgroundImage)),
                              fit: BoxFit.contain,
                            )
                          : DecorationImage(
                              image: NetworkImage(_invitation.backgroundImage),
                              fit: BoxFit.contain,
                            ))
                      : null,
                ),
                child: Stack(
                  children: [
                    // Draggable Text
                    ..._invitation.textElements.map((textElement) {
                      return Positioned(
                        left: textElement.x,
                        top: textElement.y,
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            setState(() {
                              textElement.x += details.delta.dx;
                              textElement.y += details.delta.dy;
                              selectedElement = textElement;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: selectedElement == textElement ? Colors.red : Colors.transparent,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            child: Text(
                              overflow: TextOverflow.visible,
                              textAlign: TextAlign.center,
                              textElement.content,
                              style: GoogleFonts.getFont(
                                getFont(textElement.fontFace),
                                fontSize: textElement.size,
                                color: textElement.color,
                              ),
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              selectedElement = selectedElement == null ? textElement : null;
                            });
                            if (selectedElement != null) {
                              _showCustomizationBottomSheet(context, selectedElement!);
                            }
                          },
                        ),
                      );
                    }),

                    // Draggable and Scalable Image
                    ..._invitation.imageElements.map((imageElement) {
                      return Positioned(
                        left: imageElement.x,
                        top: imageElement.y,
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            setState(() {
                              imageElement.x += details.delta.dx;
                              imageElement.y += details.delta.dy;
                            });
                          },
                          child: Image.file(
                            File(imageElement.imageUrl),
                            width: imageElement.width,
                            height: imageElement.height,
                            fit: BoxFit.contain,
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }

  void _showCustomizationBottomSheet(BuildContext context, TextElement selectedText) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _invitationTextController,
                    decoration: InputDecoration(
                      labelText: selectedText.content,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (text) {
                      setState(() {
                        selectedText.content = text;
                        this.setState(() {});
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: selectedText.size,
                          min: 10.0,
                          max: 50.0,
                          divisions: 40,
                          label: selectedText.size
                              .round()
                              .toString(),
                          onChanged: (value) {
                            setState(() {
                              selectedText.size = value;
                              this.setState(() {});
                            });
                          },
                        ),
                      ),
                      Text(
                          'Font Size: ${selectedText.size.round()}'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    title: const Text('Text Color'),
                    trailing: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: selectedText.color,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey, width: 1),
                      ),
                    ),
                    onTap: () async {
                      final selectedColor = await showDialog<Color>(
                        context: context,
                        builder: (context) => ColorSelectionDialog(
                            selectedColor:
                                selectedText.color),
                      );
                      if (selectedColor != null) {
                        setState(() {
                          selectedText.color = selectedColor;
                          this.setState(() {});
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _invitation.textElements.remove(selectedText);
                      });
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      setState(() {
        selectedElement = null;
      });
    });
  }
}