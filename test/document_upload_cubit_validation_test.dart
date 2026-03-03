import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:goapp/features/document_verify/presentation/cubit/verification_cubit.dart';
import 'package:goapp/features/document_verify/presentation/model/document_model.dart';
import 'package:goapp/features/document_verify/presentation/model/document_progress_store.dart';
import 'package:goapp/features/documents/presentation/cubit/document_upload_cubit.dart';
import 'package:goapp/features/documents/presentation/pages/document_upload_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const MethodChannel permissionChannel = MethodChannel(
    'flutter.baseflow.com/permissions/methods',
  );
  const MethodChannel imagePickerChannel = MethodChannel(
    'plugins.flutter.io/image_picker',
  );
  late String fakeImagePath;

  setUpAll(() async {
    final tempDir = await Directory.systemTemp.createTemp('goapp_test_');
    final fakeFile = File('${tempDir.path}\\fake_doc.jpg');
    await fakeFile.writeAsBytes(List<int>.filled(1024, 1));
    fakeImagePath = fakeFile.path;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, (MethodCall call) async {
          switch (call.method) {
            case 'checkPermissionStatus':
              return 1; // granted
            case 'requestPermissions':
              final permissions =
                  (call.arguments as List<dynamic>?) ?? <dynamic>[];
              return <int, int>{
                for (final p in permissions.whereType<int>()) p: 1,
              };
            default:
              return null;
          }
        });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(imagePickerChannel, (MethodCall call) async {
          if (call.method == 'pickImage') {
            return fakeImagePath;
          }
          return null;
        });
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(imagePickerChannel, null);
  });

  group('DocumentUploadCubit document number validation', () {
    setUp(() {
      DocumentProgressStore.reset();
    });

    test('profile photo is required on Step 1', () async {
      final cubit = DocumentUploadCubit(initialStepIndex: 0);
      addTearDown(cubit.close);

      await cubit.saveAndNext();
      expect(cubit.state.currentStepIndex, 0);
      expect(
        cubit.state.currentDocStep.imageError,
        'Please upload your profile picture before proceeding.',
      );
    });

    test('profile photo selection moves to next step', () async {
      final cubit = DocumentUploadCubit(initialStepIndex: 0);
      addTearDown(cubit.close);

      await cubit.captureProfilePhoto(source: ImageSource.gallery);
      await cubit.saveAndNext();

      expect(cubit.state.currentStepIndex, 1);
      expect(DocumentProgressStore.isProfileImageUploaded(), isTrue);
    });

    test('does not navigate until front and back are captured', () async {
      final cubit = DocumentUploadCubit(initialStepIndex: 1);
      addTearDown(cubit.close);

      cubit.updateDocumentNumber('MH1220180012345');
      await cubit.saveAndNext();
      expect(cubit.state.currentStepIndex, 1);
      expect(cubit.state.currentDocStep.numberError, isNotNull);

      await cubit.captureFront(source: ImageSource.gallery);
      await cubit.saveAndNext();
      expect(cubit.state.currentStepIndex, 1);

      await cubit.captureBack(source: ImageSource.gallery);
      await cubit.saveAndNext();
      expect(cubit.state.currentStepIndex, 2);
    });

    test('driving license rejects invalid and accepts valid', () async {
      final cubit = DocumentUploadCubit(initialStepIndex: 1);
      addTearDown(cubit.close);

      await cubit.captureFront(source: ImageSource.gallery);
      await cubit.captureBack(source: ImageSource.gallery);
      cubit.updateDocumentNumber('abc123');
      await cubit.saveAndNext();
      expect(cubit.state.currentStepIndex, 1);
      expect(cubit.state.currentDocStep.numberError, isNotNull);

      cubit.updateDocumentNumber('MH1220180012345');
      await cubit.saveAndNext();
      expect(cubit.state.currentStepIndex, 2);
    });

    test('vehicle RC rejects invalid and accepts valid', () async {
      final cubit = DocumentUploadCubit(initialStepIndex: 2);
      addTearDown(cubit.close);

      await cubit.captureFront(source: ImageSource.gallery);
      await cubit.captureBack(source: ImageSource.gallery);
      cubit.updateDocumentNumber('12345');
      await cubit.saveAndNext();
      expect(cubit.state.currentStepIndex, 2);
      expect(cubit.state.currentDocStep.numberError, isNotNull);

      cubit.updateDocumentNumber('TN01AB1234');
      await cubit.saveAndNext();
      expect(cubit.state.currentStepIndex, 3);
    });

    test('aadhaar rejects invalid and accepts 12 digits', () async {
      final cubit = DocumentUploadCubit(initialStepIndex: 3);
      addTearDown(cubit.close);

      await cubit.captureFront(source: ImageSource.gallery);
      await cubit.captureBack(source: ImageSource.gallery);
      cubit.updateDocumentNumber('1234ABCD5678');
      await cubit.saveAndNext();
      expect(cubit.state.currentStepIndex, 3);
      expect(cubit.state.currentDocStep.numberError, isNotNull);

      cubit.updateDocumentNumber('123412341234');
      await cubit.saveAndNext();
      expect(cubit.state.currentStepIndex, 4);
    });

    test('pan rejects invalid and accepts valid format', () async {
      final cubit = DocumentUploadCubit(initialStepIndex: 4);
      addTearDown(cubit.close);

      await cubit.captureFront(source: ImageSource.gallery);
      await cubit.captureBack(source: ImageSource.gallery);
      cubit.updateDocumentNumber('ABCDE12345');
      await cubit.saveAndNext();
      expect(cubit.state.currentStepIndex, 4);
      expect(cubit.state.currentDocStep.numberError, isNotNull);

      cubit.updateDocumentNumber('ABCDE1234F');
      await cubit.saveAndNext();
      expect(cubit.state.currentStepIndex, 5);
      expect(cubit.state.isCurrentStepBank, isTrue);
    });

    test('normalizes lower-case formatted input for license and RC', () async {
      final licenseCubit = DocumentUploadCubit(initialStepIndex: 1);
      addTearDown(licenseCubit.close);

      await licenseCubit.captureFront(source: ImageSource.gallery);
      await licenseCubit.captureBack(source: ImageSource.gallery);
      licenseCubit.updateDocumentNumber('mh 12-2018 0012345');
      await licenseCubit.saveAndNext();
      expect(licenseCubit.state.steps[1].documentNumber, 'MH1220180012345');

      final rcCubit = DocumentUploadCubit(initialStepIndex: 2);
      addTearDown(rcCubit.close);

      await rcCubit.captureFront(source: ImageSource.gallery);
      await rcCubit.captureBack(source: ImageSource.gallery);
      rcCubit.updateDocumentNumber('tn 01 ab 1234');
      await rcCubit.saveAndNext();
      expect(rcCubit.state.steps[2].documentNumber, 'TN01AB1234');
    });

    test(
      'marks driving license completed and shows completed in verification',
      () async {
        final uploadCubit = DocumentUploadCubit(initialStepIndex: 1);
        addTearDown(uploadCubit.close);

        await uploadCubit.captureFront(source: ImageSource.gallery);
        await uploadCubit.captureBack(source: ImageSource.gallery);
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
      'shows mandatory error and allows upload from camera-icon bottom sheet',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: DocumentUploadScreen(initialStepIndex: 0),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Profile Picture'), findsOneWidget);
        expect(find.byIcon(Icons.camera_alt), findsOneWidget);

        await tester.tap(find.byKey(const Key('save_next_button')));
        await tester.pumpAndSettle();
        expect(
          find.text('Please upload your profile picture before proceeding.'),
          findsOneWidget,
        );

        await tester.tap(find.byIcon(Icons.camera_alt));
        await tester.pumpAndSettle();
        expect(find.text('Upload Profile Photo'), findsOneWidget);
        expect(find.text('Gallery'), findsOneWidget);

        await tester.tap(find.text('Gallery'));
        await tester.pumpAndSettle();
        expect(DocumentProgressStore.isProfileImageUploaded(), isTrue);

        await tester.tap(find.byKey(const Key('save_next_button')));
        await tester.pumpAndSettle();
        expect(find.text('Driving License'), findsOneWidget);
      },
    );
  });
}
