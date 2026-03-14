import 'package:goapp/features/help_support/domain/entities/help_article_link.dart';

/// Static Help & Support link lists used by mock repositories and as safe
/// initial UI state (so lists don't flash empty before async init completes).
const List<HelpArticleLink> kAccountHelpLinks = <HelpArticleLink>[
  HelpArticleLink(id: 'update_rc_details', title: 'Update RC details'),
  HelpArticleLink(id: 'update_mobile_number', title: 'Update mobile number'),
  HelpArticleLink(
    id: 'update_driving_license',
    title: 'Update driving license',
  ),
  HelpArticleLink(
    id: 'update_aadhaar_pan_details',
    title: 'Update Aadhaar / PAN details',
  ),
  HelpArticleLink(id: 'about_goapp_id_card', title: 'About GoApp ID card'),
];

const List<HelpArticleLink> kAppIssuesHelpLinks = <HelpArticleLink>[
  HelpArticleLink(id: 'unable_to_go_on_duty', title: 'Unable to go on duty'),
  HelpArticleLink(id: 'not_receiving_orders', title: 'Not receiving orders'),
  HelpArticleLink(
    id: 'service_suspended_on_my_account',
    title: 'Service suspended on my account',
  ),
  HelpArticleLink(id: 'app_is_crashing', title: 'App is crashing'),
  HelpArticleLink(
    id: 'change_my_mobile_number',
    title: 'Change my mobile number',
  ),
  HelpArticleLink(
    id: 'update_my_vehicle_details',
    title: 'Update my vehicle details',
  ),
  HelpArticleLink(
    id: 'unable_to_upload_documents',
    title: 'Unable to upload documents',
  ),
];
