import 'package:goapp/features/help_support/domain/entities/help_text_run.dart';

sealed class HelpContentBlock {
  const HelpContentBlock();
}

class HelpParagraphBlock extends HelpContentBlock {
  const HelpParagraphBlock(this.runs);

  final List<HelpTextRun> runs;
}

class HelpBulletsBlock extends HelpContentBlock {
  const HelpBulletsBlock(this.items);

  final List<List<HelpTextRun>> items;
}

class HelpSpacerBlock extends HelpContentBlock {
  const HelpSpacerBlock(this.height);

  final double height;
}

class HelpHeadingBlock extends HelpContentBlock {
  const HelpHeadingBlock(this.text);

  final String text;
}
