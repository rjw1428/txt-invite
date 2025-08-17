
import 'package:flutter/material.dart';

class CancelEventDialog extends StatefulWidget {
  final Function(String) onConfirm;

  const CancelEventDialog({super.key, required this.onConfirm});

  @override
  CancelEventDialogState createState() => CancelEventDialogState();
}

class CancelEventDialogState extends State<CancelEventDialog> {
  final _formKey = GlobalKey<FormState>();
  String _reason = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cancel Event'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          decoration: const InputDecoration(labelText: 'Reason for cancellation'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a reason';
            }
            return null;
          },
          onSaved: (value) => _reason = value!,
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Nevermind'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Confirm'),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              widget.onConfirm(_reason);
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}
