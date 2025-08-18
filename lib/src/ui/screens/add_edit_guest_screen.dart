
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:txt_invite/src/models/guest.dart';

class AddEditGuestScreen extends StatefulWidget {
  final Guest? guest;
  final Function(Guest) onSave;

  const AddEditGuestScreen({super.key, this.guest, required this.onSave});

  @override
  AddEditGuestScreenState createState() => AddEditGuestScreenState();
}

class AddEditGuestScreenState extends State<AddEditGuestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  List<Contact>? _contacts;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _firstNameController.text = widget.guest?.firstName ?? '';
    _lastNameController.text = widget.guest?.lastName ?? '';
    _phoneNumberController.text = widget.guest?.phoneNumber ?? '';
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final hasPermission = await FlutterContacts.requestPermission(readonly: true);
      if (hasPermission) {
        final contacts = await FlutterContacts.getContacts(withProperties: true);
        setState(() {
          _contacts = contacts;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Permission denied';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading contacts: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              if (_isLoading)
                const CircularProgressIndicator()
              else if (_error != null)
                Text(_error!)
              else
                Autocomplete<Contact>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<Contact>.empty();
                    }
                    return _contacts!.where((contact) {
                      return contact.displayName.toLowerCase().contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  displayStringForOption: (Contact contact) => contact.displayName,
                  onSelected: (Contact selection) {
                    _firstNameController.text = selection.name.first;
                    _lastNameController.text = selection.name.last;
                    if (selection.phones.isNotEmpty) {
                      _phoneNumberController.text = selection.phones.first.number;
                    }
                  },
                  fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                    return TextField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        labelText: 'Search Contacts',
                        // border: OutlineInputBorder(),
                      ),
                      onSubmitted: (value) => onFieldSubmitted(),
                    );
                  },
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a first name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a last name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newGuest = Guest(
                      id: widget.guest?.id, // Use existing ID if editing
                      firstName: _firstNameController.text,
                      lastName: _lastNameController.text,
                      phoneNumber: _phoneNumberController.text,
                    );
                    widget.onSave(newGuest);
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Save'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
