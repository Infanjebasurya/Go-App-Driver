import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:goapp/features/documents/presentation/cubit/document_upload_cubit.dart';

void main() {
  group('DocumentUploadCubit document number validation', () {
    test('does not navigate until front and back are captured', () async {
      final cubit = DocumentUploadCubit(initialStepIndex: 0);
      addTearDown(cubit.close);

      cubit.updateDocumentNumber('MH1220180012345');
      await cubit.saveAndNext();
      expect(cubit.state.currentStepIndex, 0);
      expect(cubit.state.currentDocStep.numberError, isNotNull);

      await cubit.captureFront(source: ImageSource.gallery);
      await cubit.saveAndNext();
      expect(cubit.state.currentStepIndex, 0);

      await cubit.captureBack(source: ImageSource.gallery);
      await cubit.saveAndNext();
      expect(cubit.state.currentStepIndex, 1);
    });

    test('driving license rejects invalid and accepts valid', () async {
      final cubit = DocumentUploadCubit(initialStepIndex: 0);
      addTearDown(cubit.close);

      await cubit.captureFront(source: ImageSource.gallery);
      await cubit.captureBack(source: ImageSource.gallery);
      cubit.updateDocumentNumber('abc123');
      await cubit.saveAndNext();
      expect(cubit.state.currentStepIndex, 0);
      expect(cubit.state.currentDocStep.numberError, isNotNull);

      cubit.updateDocumentNumber('MH1220180012345');
      await cubit.saveAndNext();
      expect(cubit.state.currentStepIndex, 1);
    });

    test('vehicle RC rejects invalid and accepts valid', () async {
      final cubit = DocumentUploadCubit(initialStepIndex: 1);
      addTearDown(cubit.close);

      await cubit.captureFront(source: ImageSource.gallery);
      await cubit.captureBack(source: ImageSource.gallery);
      cubit.updateDocumentNumber('12345');
      await cubit.saveAndNext();
      expect(cubit.state.currentStepIndex, 1);
      expect(cubit.state.currentDocStep.numberError, isNotNull);

      cubit.updateDocumentNumber('TN01AB1234');
      await cubit.saveAndNext();
      expect(cubit.state.currentStepIndex, 2);
    });

    test('aadhaar rejects invalid and accepts 12 digits', () async {
      final cubit = DocumentUploadCubit(initialStepIndex: 2);
      addTearDown(cubit.close);

      await cubit.captureFront(source: ImageSource.gallery);
      await cubit.captureBack(source: ImageSource.gallery);
      cubit.updateDocumentNumber('1234ABCD5678');
      await cubit.saveAndNext();
      expect(cubit.state.currentStepIndex, 2);
      expect(cubit.state.currentDocStep.numberError, isNotNull);

      cubit.updateDocumentNumber('123412341234');
      await cubit.saveAndNext();
      expect(cubit.state.currentStepIndex, 3);
    });

    test('pan rejects invalid and accepts valid format', () async {
      final cubit = DocumentUploadCubit(initialStepIndex: 3);
      addTearDown(cubit.close);

      await cubit.captureFront(source: ImageSource.gallery);
      await cubit.captureBack(source: ImageSource.gallery);
      cubit.updateDocumentNumber('ABCDE12345');
      await cubit.saveAndNext();
      expect(cubit.state.currentStepIndex, 3);
      expect(cubit.state.currentDocStep.numberError, isNotNull);

      cubit.updateDocumentNumber('ABCDE1234F');
      await cubit.saveAndNext();
      expect(cubit.state.currentStepIndex, 4);
      expect(cubit.state.isCurrentStepBank, isTrue);
    });

    test('normalizes lower-case formatted input for license and RC', () async {
      final licenseCubit = DocumentUploadCubit(initialStepIndex: 0);
      addTearDown(licenseCubit.close);

      await licenseCubit.captureFront(source: ImageSource.gallery);
      await licenseCubit.captureBack(source: ImageSource.gallery);
      licenseCubit.updateDocumentNumber('mh 12-2018 0012345');
      await licenseCubit.saveAndNext();
      expect(licenseCubit.state.steps[0].documentNumber, 'MH1220180012345');

      final rcCubit = DocumentUploadCubit(initialStepIndex: 1);
      addTearDown(rcCubit.close);

      await rcCubit.captureFront(source: ImageSource.gallery);
      await rcCubit.captureBack(source: ImageSource.gallery);
      rcCubit.updateDocumentNumber('tn 01 ab 1234');
      await rcCubit.saveAndNext();
      expect(rcCubit.state.steps[1].documentNumber, 'TN01AB1234');
    });
  });
}
