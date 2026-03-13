import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goapp/core/service/file_picker_service.dart';
import 'package:goapp/core/service/image_picker_service.dart';
import 'package:goapp/core/service/permission_service.dart';
import 'package:goapp/core/service/path_provider_service.dart';
import 'package:goapp/features/document_verify/presentation/cubit/verification_cubit.dart';
import 'package:goapp/features/document_verify/presentation/model/document_model.dart';
import 'package:goapp/features/document_verify/presentation/model/document_progress_store.dart';
import 'package:goapp/features/documents/presentation/cubit/document_upload_cubit.dart';
import 'package:goapp/features/documents/presentation/services/document_upload_file_service.dart';
import 'package:goapp/features/documents/presentation/pages/document_upload_screen.dart';
import 'package:goapp/core/di/injection.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const MethodChannel permissionChannel = MethodChannel(
    'app/permission_service',
  );
  const MethodChannel imagePickerChannel = MethodChannel(
    'app/image_picker_service',
  );
  const MethodChannel pathProviderChannel = MethodChannel(
    'app/path_provider_service',
  );
  late String fakeImagePath;
  late String docsDirPath;

  setUpAll(() async {
    if (!sl.isRegistered<DocumentUploadCubit>()) {
      sl.registerFactoryParam<DocumentUploadCubit, int, void>((
        initialStepIndex,
        _,
      ) {
        return DocumentUploadCubit(
          initialStepIndex: initialStepIndex,
          imagePickerService: ImagePickerService(),
          filePickerService: const FilePickerService(),
          fileService: DocumentUploadFileService(
            pathProvider: PathProviderService(),
            permissionService: const PermissionService(),
          ),
        );
      });
    }

    final tempDir = await Directory.systemTemp.createTemp('goapp_test_');
    docsDirPath = tempDir.path;
    final fakeFile = File('${tempDir.path}\\fake_doc.jpg');
    await fakeFile.writeAsBytes(List<int>.filled(1024, 1));
    fakeImagePath = fakeFile.path;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, (MethodCall call) async {
          switch (call.method) {
            case 'status':
              return 'granted';
            case 'request':
              return 'granted';
            case 'openAppSettings':
              return true;
            default:
              return null;
          }
        });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(imagePickerChannel, (MethodCall call) async {
          if (call.method == 'pickImage') {
            return <String, Object?>{
              'path': fakeImagePath,
              'name': 'fake_doc.jpg',
            };
          }
          return null;
        });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (MethodCall call) async {
          if (call.method == 'getApplicationDocumentsDirectory') {
            return docsDirPath;
          }
          return null;
        });
  });

  tearDownAll(() {
    if (sl.isRegistered<DocumentUploadCubit>()) {
      sl.unregister<DocumentUploadCubit>();
    }

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(imagePickerChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
  });

  group('DocumentUploadCubit document number validation', () {
    setUp(() {
      DocumentProgressStore.reset();
    });

    DocumentUploadCubit createCubit(int initialStepIndex) {
      return DocumentUploadCubit(
        initialStepIndex: initialStepIndex,
        imagePickerService: ImagePickerService(),
        filePickerService: const FilePickerService(),
        fileService: DocumentUploadFileService(
          pathProvider: PathProviderService(),
          permissionService: const PermissionService(),
        ),
      );
    }

    test('profile photo is required on Step 1', () async {
      final cubit = createCubit(0);
      addTearDown(cubit.close);

      await cubit.saveAndNext();
      expect(cubit.state.currentStepIndex, 0);
      expect(
        cubit.state.currentDocStep.imageError,
        'Please upload your profile picture before proceeding.',
      );
    });

    test('profile photo selection moves to next step', () async {
      final cubit = createCubit(0);
      addTearDown(cubit.close);

      await cubit.captureProfilePhoto(source: AppImageSource.gallery);
      await cubit.saveAndNext();

      expect(cubit.state.currentStepIndex, 1);
      expect(DocumentProgressStore.isProfileImageUploaded(), isTrue);
    });

    test('does not navigate until front and back are captured', () async {
      final cubit = createCubit(1);
      addTearDown(cubit.close);

      cubit.updateDocumentNumber('MH1220180012345');
      await cubit.saveAndNext();
      expect(cubit.state.currentStepIndex, 1);
      expect(cubit.state.currentDocStep.numberError, isNotNull);

      await cubit.captureFront(source: AppImageSource.gallery);
      await cubit.saveAndNext();
      expect(cubit.state.currentStepIndex, 1);

      await cubit.captureBack(source: AppImageSource.gallery);
      await cubit.saveAndNext();
      expect(cubit.state.currentStepIndex, 2);
    });

    test('driving license rejects invalid and accepts valid', () async {
      final cubit = createCubit(1);
      addTearDown(cubit.close);

      await cubit.captureFront(source: AppImageSource.gallery);
      await cubit.captureBack(source: AppImageSource.gallery);
      cubit.updateDocumentNumber('abc123');
      await cubit.saveAndNext();
      expect(cubit.state.currentStepIndex, 1);
      expect(cubit.state.currentDocStep.numberError, isNotNull);

      cubit.updateDocumentNumber('MH1220180012345');
      await cubit.saveAndNext();
      expect(cubit.state.currentStepIndex, 2);
    });

    test('vehicle RC rejects invalid and accepts valid', () async {
      final cubit = createCubit(2);
      addTearDown(cubit.close);

      await cubit.captureFront(source: AppImageSource.gallery);
      await cubit.captureBack(source: AppImageSource.gallery);
      cubit.updateDocumentNumber('12345');
      await cubit.saveAndNext();
      expect(cubit.state.currentStepIndex, 2);
      expect(cubit.state.currentDocStep.numberError, isNotNull);

      cubit.updateDocumentNumber('TN01AB1234');
      await cubit.saveAndNext();
      expect(cubit.state.currentStepIndex, 3);
    });

    test('aadhaar rejects invalid and accepts 12 digits', () async {
      final cubit = createCubit(3);
      addTearDown(cubit.close);

      await cubit.captureFront(source: AppImageSource.gallery);
      await cubit.captureBack(source: AppImageSource.gallery);
      cubit.updateDocumentNumber('1234ABCD5678');
      await cubit.saveAndNext();
      expect(cubit.state.currentStepIndex, 3);
      expect(cubit.state.currentDocStep.numberError, isNotNull);

      cubit.updateDocumentNumber('123412341234');
      await cubit.saveAndNext();
      expect(cubit.state.currentStepIndex, 4);
    });

    test('pan rejects invalid and accepts valid format', () async {
      final cubit = createCubit(4);
      addTearDown(cubit.close);

      await cubit.captureFront(source: AppImageSource.gallery);
      cubit.updateDocumentNumber('ABCDE12345');
      await cubit.saveAndNext();
      expect(cubit.state.currentStepIndex, 4);
      expect(cubit.state.currentDocStep.numberError, isNotNull);

      cubit.updateDocumentNumber('ABCDE1234F');
      await cubit.saveAndNext();
      expect(cubit.state.currentStepIndex, 5);
      expect(cubit.state.isCurrentStepBank, isTrue);
    });

    test(
      'bank mismatch error clears after correcting account number and re-submitting',
      () async {
        final cubit = createCubit(5);
        addTearDown(cubit.close);

        cubit.updateAccountHolderName('JOHN DOE');
        cubit.updateBankName('HDFC BANK');
        cubit.updateAccountNumber('1234567890');
        cubit.updateConfirmAccountNumber('0987654321');
        cubit.updateIfscCode('HDFC0000001');
        await cubit.captureBankDocument(source: AppImageSource.gallery);

        await cubit.saveAndNext();
        expect(
          cubit.state.bankData.confirmAccountNumberError,
          'Account numbers do not match',
        );

        cubit.updateAccountNumber('0987654321');
        await cubit.saveAndNext();
        expect(cubit.state.bankData.confirmAccountNumberError, isNull);
        expect(cubit.state.isAllDone, isTrue);
      },
    );

    test('normalizes lower-case formatted input for license and RC', () async {
      final licenseCubit = createCubit(1);
      addTearDown(licenseCubit.close);

      await licenseCubit.captureFront(source: AppImageSource.gallery);
      await licenseCubit.captureBack(source: AppImageSource.gallery);
      licenseCubit.updateDocumentNumber('mh 12-2018 0012345');
      await licenseCubit.saveAndNext();
      expect(licenseCubit.state.steps[1].documentNumber, 'MH1220180012345');

      final rcCubit = createCubit(2);
      addTearDown(rcCubit.close);

      await rcCubit.captureFront(source: AppImageSource.gallery);
      await rcCubit.captureBack(source: AppImageSource.gallery);
      rcCubit.updateDocumentNumber('tn 01 ab 1234');
      await rcCubit.saveAndNext();
      expect(rcCubit.state.steps[2].documentNumber, 'TN01AB1234');
    });

    test(
      'marks driving license completed and shows completed in verification',
      () async {
        final uploadCubit = createCubit(1);
        addTearDown(uploadCubit.close);

        await uploadCubit.captureFront(source: AppImageSource.gallery);
        await uploadCubit.captureBack(source: AppImageSource.gallery);
        uploadCubit.updateDocumentNumber('MH1220180012345');
        await uploadCubit.saveAndNext();

        expect(uploadCubit.state.currentStepIndex, 2);
        expect(
          DocumentProgressStore.isCompleted(DocumentType.drivingLicense),
          isTrue,
        );

        final verificationCubit = VerificationCubit();
        addTearDown(verificationCubit.close);

        final drivingLicenseDoc = verificationCubit.state.documents.firstWhere(
          (doc) => doc.type == DocumentType.drivingLicense,
        );
        expect(drivingLicenseDoc.status, DocumentStatus.completed);
      },
    );
  });

  group('VerificationCubit profile photo submission validation', () {
    setUp(() {
      DocumentProgressStore.reset();
    });

    test('blocks final submit when profile photo is missing', () async {
      for (final type in DocumentType.values) {
        DocumentProgressStore.setCompleted(type, true);
      }
      DocumentProgressStore.setProfileImagePath(null);

      final cubit = VerificationCubit();
      addTearDown(cubit.close);

      await cubit.submitForReview();
      expect(cubit.state.isSubmitted, isFalse);
      expect(
        cubit.state.errorMessage,
        'Please upload your profile picture before proceeding.',
      );
    });
  });

  group('DocumentUploadScreen Step 1 profile picture widget', () {
    setUp(() {
      DocumentProgressStore.reset();
    });

    testWidgets(
      'shows mandatory error and allows upload from profile photo tap area',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              useMaterial3: false,
              splashFactory: InkRipple.splashFactory,
            ),
            home: const DocumentUploadScreen(initialStepIndex: 0),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Profile Picture'), findsOneWidget);
        expect(find.byIcon(Icons.camera_alt), findsNothing);
        expect(
          find.byKey(const Key('profile_photo_frame_tap_area')),
          findsOneWidget,
        );

        await tester.tap(find.byKey(const Key('save_next_button')));
        await tester.pumpAndSettle();
        expect(
          find.text('Please upload your profile picture before proceeding.'),
          findsOneWidget,
        );

        await tester.tap(find.byKey(const Key('profile_photo_frame_tap_area')));
        await tester.pumpAndSettle();
        expect(find.text('Upload Profile Photo'), findsOneWidget);
        expect(find.text('Gallery'), findsOneWidget);
      },
    );
  });
}
