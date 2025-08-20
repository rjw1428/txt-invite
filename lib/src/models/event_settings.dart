
class EventSettings {
  final bool allowComments;
  final bool guestListVisible;
  final bool rsvpRequired;

  EventSettings({
    this.allowComments = true,
    this.guestListVisible = true,
    this.rsvpRequired = true,
  });

  EventSettings copyWith({
    bool? allowComments,
    bool? guestListVisible,
    bool? rsvpRequired,
  }) {
    return EventSettings(
      allowComments: allowComments ?? this.allowComments,
      guestListVisible: guestListVisible ?? this.guestListVisible,
      rsvpRequired: rsvpRequired ?? this.rsvpRequired,
    );
  }

  factory EventSettings.fromMap(Map<String, dynamic> map) {
    return EventSettings(
      allowComments: map['allowComments'] ?? true,
      guestListVisible: map['guestListVisible'] ?? true,
      rsvpRequired: map['rsvpRequired'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'allowComments': allowComments,
      'guestListVisible': guestListVisible,
      'rsvpRequired': rsvpRequired,
    };
  }
}
