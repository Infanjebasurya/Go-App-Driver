import 'package:equatable/equatable.dart';

enum DocumentStep {
  drivingLicense,
  vehicleRC,
  identityAadhaar,
  identityPan,
  bankAccount,
}

class StepConfig {
  final DocumentStep step;
  final String title;
  final String subtitle;
  final String numberLabel;
  final String numberHint;
  final String numberExample;
  final bool isBankStep;
  final String frontLabel;
  final String backLabel;

  const StepConfig({
    required this.step,
    required this.title,
    required this.subtitle,
    required this.numberLabel,
    required this.numberHint,
    this.numberExample = '',
    this.isBankStep = false,
    this.frontLabel = 'Front Side',
    this.backLabel = 'Back Side',
  });
}

const List<StepConfig> kStepConfigs = [
  StepConfig(
    step: DocumentStep.drivingLicense,
    title: 'Driving License',
    subtitle: 'Driving Certificate',
    numberLabel: 'Driving License Number',
    numberHint: 'Tn02 2354851253',
    numberExample: 'Example: MH12 20180012345',
  ),
  StepConfig(
    step: DocumentStep.vehicleRC,
    title: 'Vehicle RC',
    subtitle: 'Registration Certificate',
    numberLabel: 'Vehicle Number',
    numberHint: 'Tn02 2354851253',
  ),
  StepConfig(
    step: DocumentStep.identityAadhaar,
    title: 'Identity Verification',
    subtitle: 'Upload your Aadhaar for quick approval',
    numberLabel: 'Document Number',
    numberHint: 'EG : 1234562378945',
  ),
  StepConfig(
    step: DocumentStep.identityPan,
    title: 'Identity Verification',
    subtitle: 'Upload your Pan for quick approval',
    numberLabel: 'Document Number',
    numberHint: 'EG : ABCDE1231',
  ),
  StepConfig(
    step: DocumentStep.bankAccount,
    title: 'Link Bank Account',
    subtitle: 'Securely link your account for direct payouts',
    numberLabel: '',
    numberHint: '',
    isBankStep: true,
  ),
];

class BankAccountData extends Equatable {
  final String accountHolderName;
  final String accountNumber;
  final String confirmAccountNumber;
  final String ifscCode;
  final String? nameError;
  final String? accountNumberError;
  final String? confirmAccountNumberError;
  final String? ifscError;

  const BankAccountData({
    this.accountHolderName = '',
    this.accountNumber = '',
    this.confirmAccountNumber = '',
    this.ifscCode = '',
    this.nameError,
    this.accountNumberError,
    this.confirmAccountNumberError,
    this.ifscError,
  });

  bool get hasErrors =>
      nameError != null ||
      accountNumberError != null ||
      confirmAccountNumberError != null ||
      ifscError != null;

  bool get isComplete =>
      accountHolderName.trim().isNotEmpty &&
      accountNumber.trim().isNotEmpty &&
      confirmAccountNumber.trim().isNotEmpty &&
      confirmAccountNumber == accountNumber &&
      ifscCode.trim().isNotEmpty;

  BankAccountData copyWith({
    String? accountHolderName,
    String? accountNumber,
    String? confirmAccountNumber,
    String? ifscCode,
    String? nameError,
    String? accountNumberError,
    String? confirmAccountNumberError,
    String? ifscError,
    bool clearNameError = false,
    bool clearAccountNumberError = false,
    bool clearConfirmError = false,
    bool clearIfscError = false,
  }) {
    return BankAccountData(
      accountHolderName: accountHolderName ?? this.accountHolderName,
      accountNumber: accountNumber ?? this.accountNumber,
      confirmAccountNumber: confirmAccountNumber ?? this.confirmAccountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      nameError: clearNameError ? null : (nameError ?? this.nameError),
      accountNumberError: clearAccountNumberError
          ? null
          : (accountNumberError ?? this.accountNumberError),
      confirmAccountNumberError: clearConfirmError
          ? null
          : (confirmAccountNumberError ?? this.confirmAccountNumberError),
      ifscError: clearIfscError ? null : (ifscError ?? this.ifscError),
    );
  }

  @override
  List<Object?> get props => [
    accountHolderName,
    accountNumber,
    confirmAccountNumber,
    ifscCode,
    nameError,
    accountNumberError,
    confirmAccountNumberError,
    ifscError,
  ];
}

class StepData extends Equatable {
  final DocumentStep step;
  final bool frontCaptured;
  final bool backCaptured;
  final String documentNumber;
  final String? numberError;
  final String? imageError;

  const StepData({
    required this.step,
    this.frontCaptured = false,
    this.backCaptured = false,
    this.documentNumber = '',
    this.numberError,
    this.imageError,
  });

  bool get isNumberValid => documentNumber.trim().isNotEmpty;
  bool get isComplete => frontCaptured && backCaptured && isNumberValid;

  StepData copyWith({
    bool? frontCaptured,
    bool? backCaptured,
    String? documentNumber,
    String? numberError,
    bool clearError = false,
    String? imageError,
    bool clearImageError = false,
  }) {
    return StepData(
      step: step,
      frontCaptured: frontCaptured ?? this.frontCaptured,
      backCaptured: backCaptured ?? this.backCaptured,
      documentNumber: documentNumber ?? this.documentNumber,
      numberError: clearError ? null : (numberError ?? this.numberError),
      imageError: clearImageError ? null : (imageError ?? this.imageError),
    );
  }

  @override
  List<Object?> get props => [
    step,
    frontCaptured,
    backCaptured,
    documentNumber,
    numberError,
    imageError,
  ];
}

class DocumentUploadState extends Equatable {
  final int currentStepIndex;
  final List<StepData> steps;
  final BankAccountData bankData;
  final bool isSubmitting;
  final bool isAllDone;

  const DocumentUploadState({
    this.currentStepIndex = 0,
    required this.steps,
    this.bankData = const BankAccountData(),
    this.isSubmitting = false,
    this.isAllDone = false,
  });

  factory DocumentUploadState.initial() => DocumentUploadState(
    currentStepIndex: 0,
    steps: [
      DocumentStep.drivingLicense,
      DocumentStep.vehicleRC,
      DocumentStep.identityAadhaar,
      DocumentStep.identityPan,
    ].map((s) => StepData(step: s)).toList(),
    bankData: const BankAccountData(),
  );

  int get totalSteps => steps.length + 1;

  bool get isCurrentStepBank => currentStepIndex == 4;

  StepData get currentDocStep => steps[currentStepIndex];

  StepConfig get currentConfig => kStepConfigs[currentStepIndex];

  bool get isLastStep => currentStepIndex == totalSteps - 1;

  bool get canGoBack => currentStepIndex > 0;

  int get completedCount {
    int count = steps.where((s) => s.isComplete).length;
    if (bankData.isComplete) count++;
    return count;
  }

  DocumentUploadState copyWithDocStep(StepData updated) {
    final newSteps = List<StepData>.from(steps);
    newSteps[currentStepIndex] = updated;
    return copyWith(steps: newSteps);
  }

  DocumentUploadState copyWith({
    int? currentStepIndex,
    List<StepData>? steps,
    BankAccountData? bankData,
    bool? isSubmitting,
    bool? isAllDone,
  }) {
    return DocumentUploadState(
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      steps: steps ?? this.steps,
      bankData: bankData ?? this.bankData,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isAllDone: isAllDone ?? this.isAllDone,
    );
  }

  @override
  List<Object?> get props => [
    currentStepIndex,
    steps,
    bankData,
    isSubmitting,
    isAllDone,
  ];
}
