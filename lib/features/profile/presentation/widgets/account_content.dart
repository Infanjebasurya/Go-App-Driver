import 'package:flutter/material.dart';
import 'package:goapp/features/auth/presentation/widgets/snackbar_utils.dart';

class AccountContent extends StatelessWidget {
  const AccountContent({
    super.key,
    required this.name,
    required this.email,
    required this.onProfileTap,
    required this.accountItems,
    required this.benefitItems,
    required this.supportItems,
  });

  final String name;
  final String email;
  final VoidCallback onProfileTap;
  final List<AccountMenuItem> accountItems;
  final List<AccountMenuItem> benefitItems;
  final List<AccountMenuItem> supportItems;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        AccountProfileCard(name: name, email: email, onTap: onProfileTap),
        const SizedBox(height: 20),
        const AccountSectionTitle(title: 'ACCOUNT'),
        const SizedBox(height: 8),
        AccountMenuCard(items: accountItems),
        const SizedBox(height: 20),
        const AccountSectionTitle(title: 'BENEFITS'),
        const SizedBox(height: 8),
        AccountMenuCard(items: benefitItems),
        const SizedBox(height: 20),
        const AccountSectionTitle(title: 'SUPPORT'),
        const SizedBox(height: 8),
        AccountMenuCard(items: supportItems),
      ],
    );
  }
}

class AccountProfileCard extends StatelessWidget {
  const AccountProfileCard({
    super.key,
    required this.name,
    required this.email,
    required this.onTap,
  });

  final String name;
  final String email;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              blurRadius: 12,
              color: Color(0x14000000),
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 26,
              backgroundColor: Color(0xFFE8EBF3),
              child: Icon(Icons.person, color: Colors.black54),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black45),
          ],
        ),
      ),
    );
  }
}

class AccountSectionTitle extends StatelessWidget {
  const AccountSectionTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: Colors.black45,
        letterSpacing: 0.6,
      ),
    );
  }
}

class AccountMenuCard extends StatelessWidget {
  const AccountMenuCard({super.key, required this.items});

  final List<AccountMenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            color: Color(0x11000000),
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var index = 0; index < items.length; index++)
            _AccountMenuTile(item: items[index], showDivider: false),
        ],
      ),
    );
  }
}

class AccountMenuItem {
  const AccountMenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
}

class _AccountMenuTile extends StatelessWidget {
  const _AccountMenuTile({required this.item, required this.showDivider});

  final AccountMenuItem item;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(item.icon, color: Colors.black),
          title: Text(item.title, style: const TextStyle(fontSize: 16)),
          subtitle: item.subtitle == null
              ? null
              : Text(
                  item.subtitle!,
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: Colors.black45),
                ),
          trailing: SizedBox(
            width: 36,
            child: Align(
              alignment: Alignment.centerRight,
              child: item.onTap == null
                  ? const Icon(Icons.chevron_right)
                  : IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.chevron_right),
                      onPressed: item.onTap,
                    ),
            ),
          ),
          onTap: () {
            final handler = item.onTap;
            if (handler != null) {
              handler();
              return;
            }
            SnackBarUtils.show(context, 'Coming soon');
          },
        ),
        if (showDivider)
          const Divider(height: 1, thickness: 0.6, color: Colors.black12),
      ],
    );
  }
}
