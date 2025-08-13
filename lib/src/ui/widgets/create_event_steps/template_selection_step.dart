
import 'package:flutter/material.dart';

class TemplateSelectionStep extends StatefulWidget {
  final Function(String) onTemplateSelected;
  final GlobalKey<FormState> formKey;

  const TemplateSelectionStep({super.key, required this.onTemplateSelected, required this.formKey});

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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select an Invitation Template',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Form(
            key: widget.formKey,
            child: Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _templates.length,
                itemBuilder: (context, index) {
                  final templateName = _templates[index];
                  final isSelected = _selectedTemplate == templateName;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTemplate = templateName;
                      });
                      widget.onTemplateSelected(templateName);
                    },
                    child: Card(
                      color: isSelected ? Colors.blue.shade100 : Colors.white,
                      elevation: isSelected ? 4 : 1,
                      child: Center(
                        child: Text(
                          templateName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.blue : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
