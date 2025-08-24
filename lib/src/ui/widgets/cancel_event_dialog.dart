import 'package:flutter/material.dart';

class CancelEventDialog extends StatefulWidget {
  final Function(String, bool) onConfirm;

  const CancelEventDialog({super.key, required this.onConfirm});

  @override
  CancelEventDialogState createState() => CancelEventDialogState();
}

class CancelEventDialogState extends State<CancelEventDialog> {
  final _formKey = GlobalKey<FormState>();
  String _reason = '';
  bool _skipDeclinedGuests = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cancel Event'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Reason for cancellation',
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a reason';
                }
                return null;
              },
              onSaved: (value) => _reason = value!,
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Skip guests who have declined'),
              value: _skipDeclinedGuests,
              onChanged: (value) {
                setState(() {
                  _skipDeclinedGuests = value!;
                });
              },
            ),
          ],
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
              widget.onConfirm(_reason, _skipDeclinedGuests);
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}
