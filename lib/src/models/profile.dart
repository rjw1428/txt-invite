class Profile {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String? fcmToken;
  final String role;

  Profile({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.fcmToken,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'fcmToken': fcmToken,
      'role': role,
    };
  }

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      firstName: map['firstName'],
      lastName: map['lastName'],
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      fcmToken: map['fcmToken'],
      role: map['role'],
    );
  }
}
