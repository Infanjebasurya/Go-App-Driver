import 'package:flutter/material.dart';
import 'package:goapp/core/theme/app_colors.dart';
import 'package:goapp/features/help_support/presentation/pages/account_support_article_screen.dart';

class UnableToGoOnDutyScreen extends StatelessWidget {
  const UnableToGoOnDutyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AccountSupportArticleScreen(
      title: 'Unable to go on duty',
      showDefaultGetHelpLine: false,
      content: [
        Text.rich(
          TextSpan(
            style: ArticleText.body,
            children: [
              TextSpan(text: 'If you are unable to go '),
              TextSpan(
                text: 'On Duty',
                style: TextStyle(
                  height: 2,
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),
              TextSpan(text: ', please check the\nfollowing:'),
            ],
          ),
        ),
        SizedBox(height: 16),
        ArticleBulletList(
          items: [
            [
              TextSpan(text: 'Make sure you have a '),
              TextSpan(
                text: 'stable internet\nconnection',
                style: TextStyle(
                  height: 2,
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),
            ],
            [
              TextSpan(text: 'Check if any of your '),
              TextSpan(
                text: 'services are\nsuspended',
                style: TextStyle(
                  height: 2,
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),
            ],
            [
              TextSpan(text: 'Ensure your '),
              TextSpan(
                text: 'GoApp wallet balance is\nabove ₹0',
                style: TextStyle(
                  height: 2,
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 16),
        Text.rich(
          TextSpan(
            style: ArticleText.body,
            children: [
              TextSpan(text: 'If the issue continues, try '),
              TextSpan(
                text: 'logging out and logging in',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),
              TextSpan(text: '\nagain, or '),
              TextSpan(
                text: 'reinstall the app',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),
              TextSpan(text: '.'),
            ],
          ),
        ),
        SizedBox(height: 16),
        Text.rich(
          TextSpan(
            style: ArticleText.body,
            children: [
              TextSpan(
                text: 'If you are still unable to go On Duty, please contact ',
              ),
              TextSpan(
                text: '\nSupport Chat or Customer Care',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),

              TextSpan(text: ' by tapping '),
              TextSpan(
                text: 'Get Help',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),
              TextSpan(text: '\nbelow.'),
            ],
          ),
        ),
      ],
    );
  }
}

class NotReceivingOrdersScreen extends StatelessWidget {
  const NotReceivingOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AccountSupportArticleScreen(
      title: 'Not receiving orders',
      showDefaultGetHelpLine: false,
      content: [
        Text('You may not receive orders if :', style: ArticleText.body),
        SizedBox(height: 16),
        ArticleBulletList(
          items: [
            [
              TextSpan(text: 'You are '),
              TextSpan(
                text: 'Off Duty',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),
            ],
            [
              TextSpan(text: 'Your '),
              TextSpan(
                text: 'wallet balance is below ₹0',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 18),
        Text(
          'You may also receive fewer orders if you are in a low-demand area.',
          style: ArticleText.body,
        ),
        SizedBox(height: 18),
        Text.rich(
          TextSpan(
            style: ArticleText.body,
            children: [
              TextSpan(
                text: 'To increase your chances of getting orders, check on ',
              ),
              TextSpan(
                text: '\nHigh Demand Areas',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),
              TextSpan(text: ' on the Menu.'),
            ],
          ),
        ),

        Text.rich(
          TextSpan(
            style: ArticleText.body,
            children: [
              TextSpan(text: 'High-demand zones appear in '),
              TextSpan(
                text: 'green',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),
              TextSpan(text: '.'),
            ],
          ),
        ),
      ],
    );
  }
}

class ServiceSuspendedScreen extends StatelessWidget {
  const ServiceSuspendedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AccountSupportArticleScreen(
      title: 'Service suspended on my account',
      showDefaultGetHelpLine: false,
      content: [
        Text(
          'Your service may be suspended if any of the following\nare observed:',
          style: ArticleText.body,
        ),
        SizedBox(height: 18),
        ArticleBulletList(
          items: [
            [
              TextSpan(
                text: 'Failure to complete an accepted order',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),
            ],
            [
              TextSpan(
                text: 'Excessive order cancellations',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),
            ],
            [
              TextSpan(
                text: 'Repeated behaviour issues',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 18),
        Text(
          'The suspension period depends on the severity and frequency of the issue.',
          style: ArticleText.body,
        ),
        SizedBox(height: 18),
        Text.rich(
          TextSpan(
            style: ArticleText.body,
            children: [
              TextSpan(text: 'If you need more information, please contact '),
              TextSpan(
                text: 'Support\nChat or Customer Care',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),

              TextSpan(text: ' by tapping '),
              TextSpan(
                text: 'Get Help',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),
              TextSpan(text: '\nbelow.'),
            ],
          ),
        ),
      ],
    );
  }
}

class AppCrashingScreen extends StatelessWidget {
  const AppCrashingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AccountSupportArticleScreen(
      title: 'App is crashing',
      showDefaultGetHelpLine: false,
      content: [
        Text(
          'If the app keeps crashing, please try the following:',
          style: ArticleText.body,
        ),
        SizedBox(height: 18),
        ArticleBulletList(
          items: [
            [
              TextSpan(text: 'Make sure your app is '),
              TextSpan(
                text: 'updated to the latest\nversion',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),
            ],
            [
              TextSpan(
                text: 'Restart the app',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),
              TextSpan(text: ' after updating'),
            ],
          ],
        ),
        SizedBox(height: 18),
        Text.rich(
          TextSpan(
            style: ArticleText.body,
            children: [
              TextSpan(text: 'If the issue continues, please contact '),
              TextSpan(
                text: 'Support Chat or\nCustomer Care',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),

              TextSpan(text: ' by tapping '),
              TextSpan(
                text: 'Get Help',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),
              TextSpan(text: ' below.'),
            ],
          ),
        ),
      ],
    );
  }
}

class ChangeMobileNumberScreen extends StatelessWidget {
  const ChangeMobileNumberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AccountSupportArticleScreen(
      title: 'Change my mobile number',
      showDefaultGetHelpLine: false,
      content: [
        Text.rich(
          TextSpan(
            style: ArticleText.body,
            children: [
              TextSpan(text: 'Your mobile number must be '),
              TextSpan(
                text: 'active',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),
              TextSpan(text: ' to log in and receive orders.'),
            ],
          ),
        ),
        SizedBox(height: 18),
        Text.rich(
          TextSpan(
            style: ArticleText.body,
            children: [
              TextSpan(text: 'To update your number, please contact '),
              TextSpan(
                text: 'Support Chat\nor Customer Care',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),

              TextSpan(text: ' by tapping '),
              TextSpan(
                text: 'Get Help',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),
              TextSpan(text: ' below.'),
            ],
          ),
        ),
        SizedBox(height: 22),
        Text('Please Note :', style: ArticleText.sectionTitle),
        SizedBox(height: 14),
        ArticleBulletList(
          items: [
            [
              TextSpan(text: 'Your '),
              TextSpan(
                text: 'wallet balance must be ₹0',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),
            ],
            [
              TextSpan(text: 'The '),
              TextSpan(
                text:
                    'new mobile number should not already be registered with GoApp',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class UpdateVehicleDetailsScreen extends StatelessWidget {
  const UpdateVehicleDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AccountSupportArticleScreen(
      title: 'Update my vehicle details',
      showDefaultGetHelpLine: false,
      content: [
        Text(
          'You can update your vehicle details from the app.',
          style: ArticleText.body,
        ),
        SizedBox(height: 18),
        Text('Follow these steps:', style: ArticleText.body),
        SizedBox(height: 10),
        ArticleBulletList(
          items: [
            [
              TextSpan(text: 'Open '),
              TextSpan(
                text: 'Menu',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),
            ],
            [
              TextSpan(text: 'Tap '),
              TextSpan(
                text: 'Documents & Details → RC',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),
            ],
            [
              TextSpan(text: 'Enter your '),
              TextSpan(
                text: 'vehicle number and Upload photo',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),
              TextSpan(text: '\nand tap '),
              TextSpan(
                text: 'Save',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 18),
        Text.rich(
          TextSpan(
            style: ArticleText.body,
            children: [
              TextSpan(text: 'Your vehicle details will be '),
              TextSpan(
                text: 'updated after verification.',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 18),
        Text.rich(
          TextSpan(
            style: ArticleText.body,
            children: [
              TextSpan(text: 'If you need further help, tap '),
              TextSpan(
                text: 'Get Help',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),
              TextSpan(text: ' below'),
            ],
          ),
        ),
      ],
    );
  }
}

class UnableToUploadDocumentsScreen extends StatelessWidget {
  const UnableToUploadDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AccountSupportArticleScreen(
      title: 'Unable to upload documents',
      showDefaultGetHelpLine: false,
      content: [
        Text('Please check the following:', style: ArticleText.sectionTitle),
        SizedBox(height: 16),
        ArticleBulletList(
          items: [
            [
              TextSpan(text: 'Ensure you have a '),
              TextSpan(
                text: 'stable internet connection',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),
            ],
            [
              TextSpan(text: 'Upload documents in '),
              TextSpan(
                text: 'image format',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 18),
        Text.rich(
          TextSpan(
            style: ArticleText.body,
            children: [
              TextSpan(text: 'If the issue continues, please contact '),
              TextSpan(
                text: 'Support Chat or\nCustomer Care',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),

              TextSpan(text: ' by tapping '),
              TextSpan(
                text: 'Get Help',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingDark,
                ),
              ),
              TextSpan(text: ' below.'),
            ],
          ),
        ),
      ],
    );
  }
}
