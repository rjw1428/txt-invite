
import 'package:flutter/material.dart';

class EventDetailsStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final DateTime? startTime;
  final DateTime? endTime;
  final Function(DateTime?) onStartTimeChanged;
  final Function(DateTime?) onEndTimeChanged;

  const EventDetailsStep({
    super.key,
    required this.formKey,
    required this.titleController,
    required this.descriptionController,
    required this.startTime,
    required this.endTime,
    required this.onStartTimeChanged,
    required this.onEndTimeChanged,
  });

  @override
  State<EventDetailsStep> createState() => _EventDetailsStepState();
}

class _EventDetailsStepState extends State<EventDetailsStep> {
  Future<DateTime?> _selectDate(BuildContext context, bool isStartTime) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    return picked;
  }

  Future<TimeOfDay?> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    return picked;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: widget.formKey,
        child: ListView(
          children: [
            TextFormField(
              controller: widget.titleController,
              decoration: const InputDecoration(
                labelText: 'Event Title',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            TextFormField(
              controller: widget.descriptionController,
              decoration: const InputDecoration(
                labelText: 'Event Description',
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            ListTile(
              title: Text(widget.startTime == null
                  ? 'Select Start Date and Time'
                  : 'Start: ${widget.startTime!.toLocal().toString().split('.')[0]}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await _selectDate(context, true);
                if (date != null) {
                  final time = await _selectTime(context, true);
                  if (time != null) {
                    widget.onStartTimeChanged(DateTime(
                      date.year,
                      date.month,
                      date.day,
                      time.hour,
                      time.minute,
                    ));
                  }
                }
              },
            ),
            ListTile(
              title: Text(widget.endTime == null
                  ? 'Select End Date and Time'
                  : 'End: ${widget.endTime!.toLocal().toString().split('.')[0]}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await _selectDate(context, true);
                if (date != null) {
                  final time = await _selectTime(context, true);
                  if (time != null) {
                    widget.onEndTimeChanged(DateTime(
                      date.year,
                      date.month,
                      date.day,
                      time.hour,
                      time.minute,
                    ));
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
