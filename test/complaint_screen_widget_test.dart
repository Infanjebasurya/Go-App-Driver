import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goapp/features/help_support/presentation/cubit/complaint_cubit.dart';
import 'package:goapp/features/help_support/presentation/pages/complaint_screen.dart';

Widget _buildTestApp(ComplaintCubit cubit) {
  return MaterialApp(
    home: BlocProvider<ComplaintCubit>.value(
      value: cubit,
      child: const ComplaintScreen(),
    ),
  );
}

void main() {
  testWidgets('shows document icon and file name for attached document', (
    WidgetTester tester,
  ) async {
    final cubit = ComplaintCubit()
      ..attachMedia(
        path: '/tmp/report.pdf',
        name: 'report.pdf',
        mediaType: ComplaintMediaType.document,
      );
    addTearDown(cubit.close);

    await tester.pumpWidget(_buildTestApp(cubit));
    await tester.pump();

    expect(find.byIcon(Icons.description_rounded), findsOneWidget);
    expect(find.text('report.pdf'), findsOneWidget);
  });

  testWidgets('shows video icon and file name for attached video', (
    WidgetTester tester,
  ) async {
    final cubit = ComplaintCubit()
      ..attachMedia(
        path: '/tmp/evidence.mp4',
        name: 'evidence.mp4',
        mediaType: ComplaintMediaType.video,
      );
    addTearDown(cubit.close);

    await tester.pumpWidget(_buildTestApp(cubit));
    await tester.pump();

    expect(find.byIcon(Icons.videocam_outlined), findsOneWidget);
    expect(find.text('evidence.mp4'), findsOneWidget);
  });

  testWidgets('shows image preview and file name for attached image', (
    WidgetTester tester,
  ) async {
    final cubit = ComplaintCubit()
      ..attachMedia(
        path: '/tmp/photo.jpg',
        name: 'photo.jpg',
        mediaType: ComplaintMediaType.image,
      );
    addTearDown(cubit.close);

    await tester.pumpWidget(_buildTestApp(cubit));
    await tester.pump();

    expect(find.byType(Image), findsOneWidget);
    expect(find.text('photo.jpg'), findsOneWidget);
  });

  testWidgets('shows Return to Dashboard action when complaint is submitted', (
    WidgetTester tester,
  ) async {
    final cubit = ComplaintCubit()
      ..selectCategory('fare_payment')
      ..updateDescription('Fare mismatch.');
    addTearDown(cubit.close);

    await tester.pumpWidget(_buildTestApp(cubit));
    cubit.submitComplaint();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1200));

    expect(find.text('Return to Dashboard'), findsOneWidget);
  });
}
