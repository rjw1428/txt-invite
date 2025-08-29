import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:txt_invite/src/models/event.dart';
import 'package:txt_invite/src/models/event_status.dart';
import 'package:txt_invite/src/models/event_settings.dart';
import 'package:txt_invite/src/models/guest.dart';
import 'package:txt_invite/src/models/invitation.dart';
import 'package:txt_invite/src/services/api.dart';
import 'package:txt_invite/src/ui/widgets/create_event_steps/confirmation_step.dart';
import 'package:txt_invite/src/ui/widgets/create_event_steps/event_details_step.dart';
import 'package:txt_invite/src/ui/widgets/create_event_steps/event_settings_step.dart';
import 'package:txt_invite/src/ui/widgets/create_event_steps/guest_list_management_step.dart';
import 'package:txt_invite/src/ui/widgets/create_event_steps/invitation_customization_step.dart';
import 'package:txt_invite/src/ui/widgets/create_event_steps/sms_status_step.dart';
import 'package:txt_invite/src/ui/widgets/create_event_steps/template_selection_step.dart';
import 'package:txt_invite/src/utils/constants.dart';
import 'package:txt_invite/src/utils/functions.dart';

enum CreateEventSteps {
  eventDetails,
  templateSelection,
  invitationCustomization,
  guestListManagement,
  eventSettings,
  confirmation,
  smsStatus,
}

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key,});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final PageController _pageController = PageController();
  CreateEventSteps _currentPage = CreateEventSteps.eventDetails;

  final List<GlobalKey<FormState>> _formKeys = List.generate(
    6,
    (_) => GlobalKey<FormState>(),
  );
  final ScreenshotController _screenshotController = ScreenshotController();
  final GlobalKey<EventDetailsStepState> _eventDetailsStepKey = GlobalKey<EventDetailsStepState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  bool _isLocationOptional = true;
  DateTime? _startTime;
  DateTime? _endTime;
  Invitation? _selectedTemplate;
  EventSettings _eventSettings = EventSettings();
  List<Guest> _selectedGuestList = [];
  Event? _event;
  bool _isLoading = false;
  Uint8List? _invitationImage;
  bool _isTakingScreenshot = false;

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  void _nextPage(CreateEventSteps nextStep) async {
    bool isValid = false;

    if (_currentPage == CreateEventSteps.eventDetails) {
      isValid = _eventDetailsStepKey.currentState?.validateAndSave() ?? false;
    } else {
      isValid = _formKeys[_currentPage.index].currentState?.validate() ?? false;
    }

    if (isValid) {
      if (_currentPage == CreateEventSteps.invitationCustomization) {
        setState(() {
          _isTakingScreenshot = true; // Hack to remove the border of selected text
        });
        try {
          _invitationImage = await _screenshotController.capture();
        } catch (e) {
          print('Error capturing screenshot: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create invitation image: $e')),
          );
          return;
        } finally {
          setState(() {
            _isTakingScreenshot = false;
          });
        }
      }

      if (mounted) {
        FocusScope.of(context).unfocus();
      }

      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
      setState(() {
        _currentPage = nextStep;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please complete all required fields before proceeding.',
          ),
        ),
      );
    }
  }

  void _previousPage(CreateEventSteps previousStep) {
    if (_currentPage != CreateEventSteps.eventDetails) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      setState(() {
        _currentPage = previousStep;
      });
    }
  }

  Future<void> _createEvent() async {
    if (_formKeys[_currentPage.index].currentState != null &&
        _formKeys[_currentPage.index].currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final user = Api().auth.currentUser;
        String? imgUrl = _selectedTemplate!.backgroundImage;
        if (_selectedTemplate!.backgroundImage.startsWith('/')) {
          final testFilePath = _selectedTemplate!.backgroundImage;
          final file = File(testFilePath);
          imgUrl = await Api().storage.uploadFile(
            file,
            'invitations/${user!.id}_${DateTime.now().millisecondsSinceEpoch}_background.png',
          );
        }
        final invitationThumbnailImageUrl = await Api().storage.uploadBytes(
          _invitationImage!,
          'invitations/${user!.id}_${DateTime.now().millisecondsSinceEpoch}_preview.png',
        );
        final newEvent = Event(
          id: '',
          title: _titleController.text,
          description: _descriptionController.text,
          location: _isLocationOptional ? null : _locationController.text,
          startTime: _startTime!,
          endTime: _endTime!,
          invitationBackground: imgUrl,
          invitationImageThumbnailUrl: invitationThumbnailImageUrl,
          createdBy: user.id,
          status: EventStatus.active,
          inviteCount: _selectedGuestList.length,
          settings: _eventSettings,
        );

        final event = await Api().events.createEvent(newEvent);
        final updatedGuestList = await Api().events.addGuestListToEvent(
          event.id,
          _selectedGuestList,
        );

        if (_eventSettings.qrCodeEnabled) {
          final qrCodeImageUrl = await generateQrCode(event);
          return Api().events.updateEvent(event.copyWith(qrCodeImageUrl: qrCodeImageUrl));
        }

        _pageController.animateToPage(
          CreateEventSteps.smsStatus.index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
        setState(() {
          _event = event;
          _currentPage = CreateEventSteps.smsStatus;
          _isLoading = false;
          _selectedGuestList = updatedGuestList;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to create event: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Event')),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics:
                      const NeverScrollableScrollPhysics(), // Disable swiping
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = CreateEventSteps.values[index];
                    });
                  },
                  children: [
                    EventDetailsStep(
                      key: _eventDetailsStepKey,
                      formKey: _formKeys[0],
                      titleController: _titleController,
                      descriptionController: _descriptionController,
                      locationController: _locationController,
                      isLocationOptional: _isLocationOptional,
                      onLocationOptionalChanged: (value) {
                        setState(() {
                          _isLocationOptional = value;
                        });
                      },
                      startTime: _startTime,
                      endTime: _endTime,
                      onStartTimeChanged: (dateTime) {
                        setState(() {
                          _startTime = dateTime;
                        });
                      },
                      onEndTimeChanged: (dateTime) {
                        setState(() {
                          _endTime = dateTime;
                        });
                      },
                    ),
                    TemplateSelectionStep(
                      formKey: _formKeys[1],
                      onTemplateSelected: (template) {
                        setState(() {
                          _selectedTemplate = template;
                        });
                      },
                    ),
                    InvitationCustomizationStep(
                      formKey: _formKeys[2],
                      selectedTemplate: Invitation(
                        backgroundImage: _selectedTemplate?.backgroundImage ?? '',
                        textElements: [
                          TextElement(
                            content: _titleController.text,
                            fontFace: FONTS[0],
                            size: 48,
                            color: Colors.white,
                            x: 200,
                            y: 150,),
                          TextElement(
                            content: _locationController.text,
                            fontFace: FONTS[1],
                            size: 32,
                            color: Colors.white,
                            x: 200,
                            y: 200),
                          TextElement(
                            content: "Start: ${dateTimeFormat.format(_startTime?.toLocal() ?? DateTime.now())}",
                            fontFace: FONTS[1],
                            size: 32,
                            color: Colors.white,
                            x: 200,
                            y: 200),
                          TextElement(
                            content: "End: ${dateTimeFormat.format(_endTime?.toLocal() ?? DateTime.now())}",
                            fontFace: FONTS[1],
                            size: 32,
                            color: Colors.white,
                            x: 200,
                            y: 225)
                        ],
                        imageElements: [], 
                        width: 400, 
                        height: 300
                      ),
                      screenshotController: _screenshotController,
                      isTakingScreenshot: _isTakingScreenshot,
                    ),
                    GuestListManagementStep(
                      formKey: _formKeys[3],
                      guestList: _selectedGuestList,
                      onGuestListChanged: (guestList) {
                        setState(() {
                          _selectedGuestList = guestList;
                        });
                      },
                    ),
                    EventSettingsStep(
                      formKey: _formKeys[4],
                      settings: _eventSettings,
                      onSettingsChanged: (settings) {
                        setState(() {
                          _eventSettings = settings;
                        });
                      },
                    ),
                    ConfirmationStep(
                      formKey: _formKeys[5],
                      title: _titleController.text,
                      description: _descriptionController.text,
                      location: _isLocationOptional ? null : _locationController.text,
                      startTime: _startTime,
                      endTime: _endTime,
                      guestList: _selectedGuestList,
                      settings: _eventSettings,
                      invitationImage: _invitationImage
                    ),
                    SmsStatusScreen(
                      event: _event,
                      guestList: _selectedGuestList,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Do not show "Previous" button on the first step or last step
                    if (CreateEventSteps.values.indexOf(_currentPage) > 0 &&
                        CreateEventSteps.values.indexOf(_currentPage) <
                            CreateEventSteps.values.length - 1)
                      ElevatedButton(
                        onPressed: () {
                          final previousStep =
                              CreateEventSteps.values[CreateEventSteps.values
                                      .indexOf(_currentPage) -
                                  1];
                          print('back to $previousStep');
                          _previousPage(previousStep);
                        },
                        child: const Text('Previous'),
                      )
                    else
                      const SizedBox(width: 10), // used to maintain spacing
                    if (_currentPage != CreateEventSteps.smsStatus &&
                        _currentPage != CreateEventSteps.confirmation)
                      ElevatedButton(
                        onPressed: () {
                          final nextStep =
                              CreateEventSteps.values[CreateEventSteps.values
                                      .indexOf(_currentPage) +
                                  1];
                          print('nextStep: $nextStep');
                          _nextPage(nextStep);
                        },
                        child: const Text('Next'),
                      )
                    else if (_currentPage == CreateEventSteps.confirmation)
                      ElevatedButton(
                        onPressed: _createEvent,
                        child: const Text('Create Event'),
                      )
                    else if (_currentPage == CreateEventSteps.smsStatus)
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Done'),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (_isLoading)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Processing...'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
