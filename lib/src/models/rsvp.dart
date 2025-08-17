enum RsvpStatus {
  attending,
  notAttending,
  maybe,
  pending
}

class Rsvp {
  final String id;
  final RsvpStatus status;

  Rsvp({required this.id, required this.status});

  factory Rsvp.fromMap(Map<String, dynamic> map) {
    return Rsvp(
      id: map['id'],
      status: RsvpStatus.values[map['status']],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'status': status.index,
    };
  }
}
