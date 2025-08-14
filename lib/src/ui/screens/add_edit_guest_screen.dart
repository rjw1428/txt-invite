
import 'package:flutter/material.dart';
import 'package:txt_invite/src/models/guest.dart';

class AddEditGuestScreen extends StatefulWidget {
  final Guest? guest;
  final Function(Guest) onSave;

  const AddEditGuestScreen({super.key, this.guest, required this.onSave});

  @override
  _AddEditGuestScreenState createState() => _AddEditGuestScreenState();
}

class _AddEditGuestScreenState extends State<AddEditGuestScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _firstName;
  late String _lastName;
  late String _phoneNumber;

  @override
  void initState() {
    super.initState();
    _firstName = widget.guest?.firstName ?? '';
    _lastName = widget.guest?.lastName ?? '';
    _phoneNumber = widget.guest?.phoneNumber ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.guest == null ? 'Add Guest' : 'Edit Guest'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                initialValue: _firstName,
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a first name';
                  }
                  return null;
                },
                onSaved: (value) => _firstName = value!,
              ),
              TextFormField(
                initialValue: _lastName,
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a last name';
                  }
                  return null;
                },
                onSaved: (value) => _lastName = value!,
              ),
              TextFormField(
                initialValue: _phoneNumber,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
                onSaved: (value) => _phoneNumber = value!,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final newGuest = Guest(
                      id: widget.guest?.id, // Use existing ID if editing
                      firstName: _firstName,
                      lastName: _lastName,
                      phoneNumber: _phoneNumber,
                    );
                    widget.onSave(newGuest);
                    Navigator.of(context).pop(); // Go back to previous screen
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
