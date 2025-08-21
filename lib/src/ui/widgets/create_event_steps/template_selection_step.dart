import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TemplateSelectionStep extends StatefulWidget {
  final Function(String) onTemplateSelected;
  final GlobalKey<FormState> formKey;

  const TemplateSelectionStep(
      {super.key, required this.onTemplateSelected, required this.formKey});

  @override
  State<TemplateSelectionStep> createState() => _TemplateSelectionStepState();
}

class _TemplateSelectionStepState extends State<TemplateSelectionStep> {
  final List<String> _templates = [
    'Template 1',
    'Template 2',
    'Template 3',
    'Template 4',
    'Template 5',
  ];

  String? _selectedTemplate;
  String? _selectedImage;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = image.path;
        _selectedTemplate = image.path;
      });
      widget.onTemplateSelected(image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select an Invitation Template',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FormField<String>(
                validator: (value) {
                  if (_selectedTemplate == null) {
                    return 'Please select a template';
                  }
                  return null;
                },
                builder: (FormFieldState<String> state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: _templates.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return GestureDetector(
                                onTap: _pickImage,
                                child: Card(
                                  color: _selectedImage != null
                                      ? Colors.blue.shade100
                                      : Colors.white,
                                  elevation: _selectedImage != null ? 4 : 1,
                                  child: _selectedImage != null
                                      ? Image.file(File(_selectedImage!))
                                      : const Center(
                                          child: Text('Upload from Gallery'),
                                        ),
                                ),
                              );
                            }
                            final templateName = _templates[index - 1];
                            final isSelected =
                                _selectedTemplate == templateName;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedTemplate = templateName;
                                  _selectedImage = null;
                                  state.didChange(templateName);
                                });
                                widget.onTemplateSelected(templateName);
                              },
                              child: Card(
                                color: isSelected
                                    ? Colors.blue.shade100
                                    : Colors.white,
                                elevation: isSelected ? 4 : 1,
                                child: Center(
                                  child: Text(
                                    templateName,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.blue
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      if (state.hasError)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            state.errorText!,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
