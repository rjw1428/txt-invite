
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
  Future<void> _selectDate(BuildContext context, bool isStartTime) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      if (isStartTime) {
        widget.onStartTimeChanged(picked);
      } else {
        widget.onEndTimeChanged(picked);
      }
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      if (isStartTime) {
        widget.onStartTimeChanged(DateTime(
          widget.startTime!.year,
          widget.startTime!.month,
          widget.startTime!.day,
          picked.hour,
          picked.minute,
        ));
      } else {
        widget.onEndTimeChanged(DateTime(
          widget.endTime!.year,
          widget.endTime!.month,
          widget.endTime!.day,
          picked.hour,
          picked.minute,
        ));
      }
    }
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
                await _selectDate(context, true);
                if (widget.startTime != null) {
                  await _selectTime(context, true);
                }
              },
            ),
            ListTile(
              title: Text(widget.endTime == null
                  ? 'Select End Date and Time'
                  : 'End: ${widget.endTime!.toLocal().toString().split('.')[0]}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                await _selectDate(context, false);
                if (widget.endTime != null) {
                  await _selectTime(context, false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
