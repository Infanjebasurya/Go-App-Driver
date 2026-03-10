import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/features/about/presentation/cubit/about_cubit.dart';
import 'package:goapp/features/about/presentation/cubit/about_state.dart';
import 'package:goapp/core/widgets/app_app_bar.dart';
import 'package:goapp/core/di/injection.dart';
import 'package:url_launcher/url_launcher.dart';


class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => sl<AboutCubit>(), child: const _AboutView());
  }
}

class _AboutView extends StatelessWidget {
  const _AboutView();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pop(true);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surfaceF5,
        appBar: const _AppBar(title: 'About', returnToDrawer: true),
        body: BlocBuilder<AboutCubit, AboutState>(
          builder: (context, state) {
            if (state is AboutLoading || state is AboutInitial) {
              return const _SkeletonList();
            }
            if (state is AboutLoaded) {
              return _AboutMenuList(state: state);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _AboutMenuList extends StatelessWidget {
  final AboutLoaded state;
  static final Uri _termsUri = Uri.parse('https://sybrox.com/about');
  static final Uri _aboutExternalUri = Uri.parse('https://sybrox.com/about');

  const _AboutMenuList({required this.state});

  @override
  Widget build(BuildContext context) {
    final items = [
      _MenuItem(
        icon: Icons.menu_book_outlined,
        label: 'Our Story',
        onTap: () => _push(context, AboutSection.ourStory, state),
      ),
      _MenuItem(
        icon: Icons.gavel_outlined,
        label: 'Terms of Service',
        onTap: () => _openTermsOfService(context),
      ),
      _MenuItem(
        icon: Icons.shield_outlined,
        label: 'Privacy Policy',
        onTap: () => _push(context, AboutSection.privacyPolicy, state),
      ),
    ];

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: items.length,
      separatorBuilder: (_, index) =>
          const Divider(height: 1, color: AppColors.strokeLight, indent: 58),
      itemBuilder: (_, i) => items[i],
    );
  }

  void _push(BuildContext context, AboutSection section, AboutLoaded state) {
    if (section == AboutSection.termsOfService ||
        section == AboutSection.privacyPolicy) {
      _openExternalAbout(context);
      return;
    }
    final content = state.content[section]!;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ContentScreen(
          title: content.title,
          paragraphs: content.paragraphs,
        ),
      ),
    );
  }

  Future<void> _openTermsOfService(BuildContext context) async {
    final launched = await launchUrl(
      _termsUri,
      mode: LaunchMode.externalApplication,
    );
    if (!context.mounted || launched) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Unable to open link')));
  }

  void _openExternalAbout(BuildContext context) {
    launchUrl(_aboutExternalUri, mode: LaunchMode.externalApplication).then((
      launched,
    ) {
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open link')),
        );
      }
    });
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(0),
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.verifiedMint.withValues(alpha: 0.06),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              SizedBox(
                width: 26,
                child: Icon(icon, size: 22, color: AppColors.neutral555),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.headingDark,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.neutralCCC,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContentScreen extends StatelessWidget {
  final String title;
  final List<String> paragraphs;

  const _ContentScreen({required this.title, required this.paragraphs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _AppBar(title: title),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        itemCount: paragraphs.length,
        itemBuilder: (_, i) {
          final text = paragraphs[i];
          final isSectionHeader = RegExp(r'^\d+\.').hasMatch(text.trimLeft());
          final parts = text.split('\n');
          final hasNewline = parts.length > 1;

          if (isSectionHeader && hasNewline) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    parts[0],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.headingDark,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    parts.sublist(1).join('\n'),
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.neutral444,
                      height: 1.7,
                    ),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSectionHeader ? FontWeight.w700 : FontWeight.w400,
                color: isSectionHeader
                    ? AppColors.headingDark
                    : AppColors.neutral444,
                height: 1.7,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool returnToDrawer;

  const _AppBar({required this.title, this.returnToDrawer = false});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppAppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
      onBack: () => Navigator.of(context).pop(returnToDrawer ? true : null),
      title: Text(title),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: AppColors.strokeLight, height: 1),
      ),
    );
  }
}

class _SkeletonList extends StatefulWidget {
  const _SkeletonList();

  @override
  State<_SkeletonList> createState() => _SkeletonListState();
}

class _SkeletonListState extends State<_SkeletonList>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _anim = Tween<double>(
      begin: -1.5,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: 3,
      separatorBuilder: (_, index) =>
          const Divider(height: 1, color: AppColors.strokeLight, indent: 58),
      itemBuilder: (_, index) => AnimatedBuilder(
        animation: _anim,
        builder: (_, child) => Container(
          color: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              _shimmerBox(24, 24, radius: 6),
              const SizedBox(width: 16),
              Expanded(child: _shimmerBox(14, 140)),
              _shimmerBox(16, 16, radius: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _shimmerBox(double h, double w, {double radius = 4}) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: LinearGradient(
            begin: Alignment(_anim.value - 1, 0),
            end: Alignment(_anim.value + 1, 0),
            colors: const [
              AppColors.surfaceF0,
              AppColors.mapRoad,
              AppColors.surfaceF0,
            ],
          ),
        ),
      ),
    );
  }
}



