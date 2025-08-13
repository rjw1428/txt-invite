class Guest {
  final String? firstName;
  final String? lastName;
  final String phoneNumber;

  Guest({this.firstName, this.lastName, required this.phoneNumber});

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
    };
  }

  factory Guest.fromMap(Map<String, dynamic> map) {
    return Guest(
      firstName: map['firstName'],
      lastName: map['lastName'],
      phoneNumber: map['phoneNumber'],
    );
  }
}