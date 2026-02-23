import 'package:flutter/material.dart';

enum TicketStatus { resolved, closed, open, pending }

class SupportTicket {
  final String id;
  final String title;
  final String description;
  final TicketStatus status;
  final DateTime createdAt;

  const SupportTicket({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
  });
}

class ComplaintCategory {
  final String id;
  final String name;

  const ComplaintCategory({required this.id, required this.name});
}

class IssueCategory {
  final IconData icon;
  final String name;

  const IssueCategory({required this.icon, required this.name});
}

const List<ComplaintCategory> kComplaintCategories = <ComplaintCategory>[
  ComplaintCategory(id: 'passenger_behavior', name: 'Passenger Behavior'),
  ComplaintCategory(id: 'fare_payment', name: 'Fare & Payment Issues'),
  ComplaintCategory(id: 'safety', name: 'Safety Concerns'),
  ComplaintCategory(id: 'app_technical', name: 'App & Technical Issues'),
  ComplaintCategory(id: 'wait_time', name: 'Wait Time Disputes'),
];

const List<IssueCategory> kIssueCategories = <IssueCategory>[
  IssueCategory(icon: Icons.phone_android_outlined, name: 'App Issues'),
  IssueCategory(icon: Icons.account_balance_wallet_outlined, name: 'Earnings'),
  IssueCategory(icon: Icons.settings_outlined, name: 'Service Management'),
  IssueCategory(icon: Icons.person_outline, name: 'Problem with Customer'),
  IssueCategory(icon: Icons.shield_outlined, name: 'Accidental Insurance'),
];
