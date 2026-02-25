import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/features/about/presentation/cubit/about_state.dart';

class AboutCubit extends Cubit<AboutState> {
  AboutCubit() : super(const AboutInitial()) {
    loadContent();
  }

  static const _loremBase =
      'Lorem Ipsum is simply dummy text of the printing and typesetting industry. '
      'Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, '
      'when an unknown printer took a galley of type and scrambled it to make a type '
      'specimen book. It has survived not only five centuries, but also the leap into '
      'electronic typesetting, remaining essentially unchanged. It was popularised in '
      'the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, '
      'and more recently with desktop publishing software.';

  Future<void> loadContent() async {
    emit(const AboutLoading());
    await Future<void>.delayed(const Duration(milliseconds: 400));
    emit(
      AboutLoaded(
        content: {
          AboutSection.ourStory: const AboutContent(
            title: 'Our Story',
            paragraphs: [_loremBase],
          ),
          AboutSection.termsOfService: const AboutContent(
            title: 'Terms of Service',
            paragraphs: [_loremBase],
          ),
          AboutSection.privacyPolicy: const AboutContent(
            title: 'Privacy Policy',
            paragraphs: [_loremBase],
          ),
        },
      ),
    );
  }
}
