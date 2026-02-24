class ProfileSubmission {
  const ProfileSubmission({
    required this.name,
    required this.email,
    required this.gender,
    required this.refer,
    required this.emergencyContact,
  });

  final String name;
  final String email;
  final String gender;
  final String refer;
  final String emergencyContact;
}

class ProfileSetupState {
  const ProfileSetupState({
    this.name = '',
    this.email = '',
    this.gender = '',
    this.dob = '',
    this.refer = '',
    this.emergencyContact = '',
    this.nameError,
    this.emailError,
    this.genderError,
    this.dobError,
    this.emergencyContactError,
    this.showValidation = false,
    this.submitRequested = false,
    this.submission,
  });

  final String name;
  final String email;
  final String gender;
  final String dob;
  final String refer;
  final String emergencyContact;
  final String? nameError;
  final String? emailError;
  final String? genderError;
  final String? dobError;
  final String? emergencyContactError;
  final bool showValidation;
  final bool submitRequested;
  final ProfileSubmission? submission;

  ProfileSetupState copyWith({
    String? name,
    String? email,
    String? gender,
    String? dob,
    String? refer,
    String? emergencyContact,
    String? nameError,
    String? emailError,
    String? genderError,
    String? dobError,
    String? emergencyContactError,
    bool? showValidation,
    bool? submitRequested,
    ProfileSubmission? submission,
    bool clearSubmission = false,
  }) {
    return ProfileSetupState(
      name: name ?? this.name,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      refer: refer ?? this.refer,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      nameError: nameError,
      emailError: emailError,
      genderError: genderError,
      dobError: dobError,
      emergencyContactError: emergencyContactError,
      showValidation: showValidation ?? this.showValidation,
      submitRequested: submitRequested ?? this.submitRequested,
      submission: clearSubmission ? null : (submission ?? this.submission),
    );
  }
}
