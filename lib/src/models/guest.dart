class Guest {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String phoneNumber;

  Guest({this.id, this.firstName, this.lastName, required this.phoneNumber});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
    };
  }

  factory Guest.fromMap(Map<String, dynamic> map) {
    return Guest(
      id: map['id'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      phoneNumber: map['phoneNumber'],
    );
  }

  Guest copyWith({String? id, String? firstName, String? lastName, String? phoneNumber}) {
    return Guest(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}