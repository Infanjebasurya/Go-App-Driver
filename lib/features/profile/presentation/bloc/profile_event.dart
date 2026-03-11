sealed class ProfileEvent {
  const ProfileEvent();
}

class ProfileRequested extends ProfileEvent {
  const ProfileRequested();
}

class ProfileSubmitted extends ProfileEvent {
  const ProfileSubmitted({
    required this.name,
    required this.email,
    required this.gender,
    required this.dob,
    required this.refer,
    required this.emergencyContact,
  });

  final String name;
  final String email;
  final String gender;
  final String dob;
  final String refer;
  final String emergencyContact;
}
