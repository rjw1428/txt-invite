
class EventSettings {
  final bool allowComments;
  final bool guestListVisible;
  final bool rsvpRequired;
  final bool qrCodeEnabled;

  EventSettings({
    this.allowComments = true,
    this.guestListVisible = true,
    this.rsvpRequired = true,
    this.qrCodeEnabled = false,
  });

  EventSettings copyWith({
    bool? allowComments,
    bool? guestListVisible,
    bool? rsvpRequired,
    bool? qrCodeEnabled,
  }) {
    return EventSettings(
      allowComments: allowComments ?? this.allowComments,
      guestListVisible: guestListVisible ?? this.guestListVisible,
      rsvpRequired: rsvpRequired ?? this.rsvpRequired,
      qrCodeEnabled: qrCodeEnabled ?? this.qrCodeEnabled,
    );
  }

  factory EventSettings.fromMap(Map<String, dynamic> map) {
    return EventSettings(
      allowComments: map['allowComments'] ?? true,
      guestListVisible: map['guestListVisible'] ?? true,
      rsvpRequired: map['rsvpRequired'] ?? true,
      qrCodeEnabled: map['qrCodeEnabled'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'allowComments': allowComments,
      'guestListVisible': guestListVisible,
      'rsvpRequired': rsvpRequired,
      'qrCodeEnabled': qrCodeEnabled,
    };
  }
}
