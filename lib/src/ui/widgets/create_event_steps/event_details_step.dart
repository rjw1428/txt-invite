
import 'package:flutter/material.dart';
import 'package:txt_invite/src/utils/constants.dart';

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
  State<EventDetailsStep> createState() => EventDetailsStepState();
}

class EventDetailsStepState extends State<EventDetailsStep> {
  String? _startTimeError;
  String? _endTimeError;

  Future<DateTime?> _selectDate(BuildContext context, DateTime? startDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    return picked;
  }

  Future<TimeOfDay?> _selectTime(BuildContext context, DateTime? startTime) async {
    final now = TimeOfDay.now();
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: startTime != null
          ? TimeOfDay(hour: startTime.hour + 1, minute: 0)
          : TimeOfDay(hour: now.hour + 1, minute: 0),
    );
    return picked;
  }

  bool _validateDateTimeFields() {
    setState(() {
      _startTimeError = null;
      _endTimeError = null;

      if (widget.startTime == null) {
        _startTimeError = 'Please select a start date and time';
      }
      if (widget.endTime == null) {
        _endTimeError = 'Please select an end date and time';
      }
      if (widget.startTime != null && widget.endTime != null && widget.endTime!.isBefore(widget.startTime!)) {
        _endTimeError = 'End time cannot be before start time';
      }
    });
    return _startTimeError == null && _endTimeError == null;
  }

  bool validateAndSave() {
    final formValid = widget.formKey.currentState!.validate();
    final dateTimeValid = _validateDateTimeFields();
    return formValid && dateTimeValid;
  }

  void clearStartTimeError() {
    setState(() {
      _startTimeError = null;
    });
  }

    void clearEndTimeError() {
    setState(() {
      _endTimeError = null;
    });
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
              textCapitalization: TextCapitalization.words,
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
              textCapitalization: TextCapitalization.sentences,
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
                  : 'Start: ${dateTimeFormat.format(widget.startTime!.toLocal())}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await _selectDate(context, null);
                if (date != null) {
                  final time = await _selectTime(context, null);
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
                clearStartTimeError();
              },
            ),
            if (_startTimeError != null)
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                child: Text(
                  _startTimeError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                ),
              ),
            ListTile(
              title: Text(widget.endTime == null
                  ? 'Select End Date and Time'
                  : 'End: ${dateTimeFormat.format(widget.endTime!.toLocal())}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await _selectDate(context, widget.startTime);
                if (date != null) {
                  final time = await _selectTime(context, widget.startTime);
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
                clearEndTimeError();
              },
            ),
            if (_endTimeError != null)
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                child: Text(
                  _endTimeError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
