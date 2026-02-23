sealed class ProfileEvent {
  const ProfileEvent();
}

class ProfileRequested extends ProfileEvent {
  const ProfileRequested();
}

class ProfileSubmitted extends ProfileEvent {
  const ProfileSubmitted({
    required this.name,
    required this.gender,
    required this.refer,
    required this.emergencyContact,
  });

  final String name;
  final String gender;
  final String refer;
  final String emergencyContact;
}
