enum RsvpStatus {
  attending,
  notAttending,
  maybe,
  pending
}

class Rsvp {
  final String id;
  final RsvpStatus attending;

  Rsvp({required this.id, required this.attending});

  factory Rsvp.fromMap(Map<String, dynamic> map) {
    return Rsvp(
      id: map['id'],
      attending: RsvpStatus.values[map['attending']],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'attending': attending.index,
    };
  }
}
