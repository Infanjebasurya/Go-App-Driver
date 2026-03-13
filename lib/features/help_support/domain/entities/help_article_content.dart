import 'package:goapp/features/help_support/domain/entities/help_content_block.dart';

class HelpArticleContent {
  const HelpArticleContent({
    required this.title,
    required this.blocks,
    required this.showBottomActions,
  });

  final String title;
  final List<HelpContentBlock> blocks;
  final bool showBottomActions;
}

