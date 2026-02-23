import 'package:equatable/equatable.dart';

enum AboutSection { ourStory, termsOfService, privacyPolicy }

class AboutContent {
  final String title;
  final List<String> paragraphs;

  const AboutContent({required this.title, required this.paragraphs});
}

abstract class AboutState extends Equatable {
  const AboutState();

  @override
  List<Object?> get props => [];
}

class AboutInitial extends AboutState {
  const AboutInitial();
}

class AboutLoading extends AboutState {
  const AboutLoading();
}

class AboutLoaded extends AboutState {
  final Map<AboutSection, AboutContent> content;

  const AboutLoaded({required this.content});

  @override
  List<Object?> get props => [content];
}
