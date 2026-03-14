import 'package:flutter/material.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/core/widgets/app_app_bar.dart';
import 'package:goapp/features/help_support/presentation/widgets/help_support_common_widgets.dart';

class GettingStartedArticleScreen extends StatelessWidget {
  const GettingStartedArticleScreen({
    super.key,
    required this.title,
    required this.content,
  });

  final String title;
  final List<Widget> content;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppAppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        bottom: const HelpSupportAppBarBottomDivider(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: content,
          ),
        ),
      ),
    );
  }
}

class GettingStartedText {
  GettingStartedText._();

  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
    height: 2,
  );

  static const TextStyle bold = TextStyle(
    fontWeight: FontWeight.w700,
    color: AppColors.headingDark,
  );

  static const TextStyle noteLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.headingDark,
    height: 2,
  );
}

class GettingStartedBulletList extends StatelessWidget {
  const GettingStartedBulletList({super.key, required this.items});

  final List<List<InlineSpan>> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final spans in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    '•',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text.rich(
                    TextSpan(style: GettingStartedText.body, children: spans),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
