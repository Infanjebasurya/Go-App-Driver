import 'package:flutter/material.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/core/widgets/app_app_bar.dart';
import 'package:goapp/core/di/injection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/features/help_support/presentation/cubit/support_chat_cubit.dart';
import 'package:goapp/features/help_support/presentation/pages/support_chat_screen.dart';
import 'package:goapp/features/help_support/presentation/routes/help_support_routes.dart';
import 'package:goapp/features/help_support/presentation/widgets/help_support_common_widgets.dart';

class GettingStartedSupportArticleScreen extends StatelessWidget {
  const GettingStartedSupportArticleScreen({
    super.key,
    required this.title,
    required this.content,
  });

  final String title;
  final List<Widget> content;

  @override
  Widget build(BuildContext context) {
    void openSupportChat() {
      ensureSupportChatDependenciesRegistered();
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          settings: const RouteSettings(name: HelpSupportRoutes.supportChat),
          builder: (_) => BlocProvider(
            create: (_) => sl<SupportChatCubit>(),
            child: const SupportChatScreen(),
          ),
        ),
      );
    }

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
      bottomNavigationBar: HelpCustomerCareSupportChatBar(
        onSupportChat: openSupportChat,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [...content, const SizedBox(height: 72)],
          ),
        ),
      ),
    );
  }
}
