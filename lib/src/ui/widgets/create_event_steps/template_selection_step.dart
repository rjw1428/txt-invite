import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:txt_invite/src/models/invitation.dart';
import 'package:txt_invite/src/services/api.dart';

class TemplateSelectionStep extends StatefulWidget {
  final Function(Invitation) onTemplateSelected;
  final GlobalKey<FormState> formKey;

  const TemplateSelectionStep({
    super.key,
    required this.onTemplateSelected,
    required this.formKey,
  });

  @override
  State<TemplateSelectionStep> createState() => _TemplateSelectionStepState();
}

class _TemplateSelectionStepState extends State<TemplateSelectionStep> {
  late Future<List<Invitation>> _templatesFuture;
  int? selectedIndex;
  Invitation? _selectedTemplate;

  @override
  void initState() {
    super.initState();
    _templatesFuture = Api().templateService.getAllTemplates();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final newTemplate = Invitation(
        width: 500,
        height: 500,
        textElements: [],
        imageElements: [],
        backgroundImage: image.path,
      );
      setState(() {
        selectedIndex = 0;
        _selectedTemplate = newTemplate;
      });
      widget.onTemplateSelected(newTemplate);
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
              child: FormField<Invitation>(
                validator: (value) {
                  if (selectedIndex == null) {
                    return 'Please select a template';
                  }
                  return null;
                },
                builder: (FormFieldState<Invitation> state) {
                  return FutureBuilder<List<Invitation>>(
                    future: _templatesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: SelectableText('Error: ${snapshot.error}'),
                        );
                      }
                      final templates = snapshot.data ?? [];
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
                              itemCount: templates.length + 1,
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return GestureDetector(
                                    key: const Key('pick_image_key'),
                                    onTap: _pickImage,
                                    child: Card(
                                      color:
                                          selectedIndex == 0
                                              ? Colors.blue.shade100
                                              : Colors.white,
                                      elevation:
                                          selectedIndex == 0 ? 4 : 1,
                                      child:
                                          selectedIndex == 0
                                              ? Image.file(
                                                  File(
                                                    _selectedTemplate!.backgroundImage,
                                                  ),
                                                )
                                              : const Center(
                                                  child: Text(
                                                    'Upload from Gallery',
                                                  ),
                                                ),
                                    ),
                                  );
                                }
                                // final template = templates[index - 1];
                                final isSelected = index == selectedIndex;

                                return GestureDetector(
                                  key: Key('template_card_${index - 1}'),
                                  onTap: () {
                                    print(index);
                                    setState(() {
                                      selectedIndex = index;
                                    });
                                    widget.onTemplateSelected(templates[index - 1]);
                                  },
                                  child: Card(
                                    color:
                                        isSelected
                                            ? Colors.blue.shade100
                                            : Colors.white,
                                    elevation: isSelected ? 4 : 1,
                                    child: Center(
                                      child: Stack(
                                        children: [
                                          Image.network(
                                            templates[index - 1].backgroundImage,
                                            fit: BoxFit.cover,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                );
                              }
                            ),
                          ),
                          if (state.hasError)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                state.errorText!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
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
