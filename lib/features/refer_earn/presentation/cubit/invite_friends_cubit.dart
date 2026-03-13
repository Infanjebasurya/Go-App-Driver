import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goapp/core/service/contacts_service.dart';
import 'package:goapp/core/service/permission_service.dart';
import 'package:goapp/core/service/url_launcher_service.dart';

class InviteContact extends Equatable {
  const InviteContact({
    required this.id,
    required this.name,
    required this.phone,
    this.isMember = false,
  });

  final String id;
  final String name;
  final String phone;
  final bool isMember;

  String get initial {
    final String trimmed = name.trim();
    return trimmed.isEmpty ? '?' : trimmed[0].toUpperCase();
  }

  @override
  List<Object?> get props => [id, name, phone, isMember];
}

sealed class InviteFriendsState extends Equatable {
  const InviteFriendsState();

  @override
  List<Object?> get props => [];
}

class InviteFriendsLoading extends InviteFriendsState {
  const InviteFriendsLoading();
}

class InviteFriendsPermissionDenied extends InviteFriendsState {
  const InviteFriendsPermissionDenied({required this.permanentlyDenied});

  final bool permanentlyDenied;

  @override
  List<Object?> get props => [permanentlyDenied];
}

class InviteFriendsFailure extends InviteFriendsState {
  const InviteFriendsFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class InviteFriendsLoaded extends InviteFriendsState {
  const InviteFriendsLoaded({
    required this.contacts,
    required this.query,
    this.invitingContactId,
  });

  final List<InviteContact> contacts;
  final String query;
  final String? invitingContactId;

  InviteFriendsLoaded copyWith({
    List<InviteContact>? contacts,
    String? query,
    String? invitingContactId,
    bool clearInvitingContactId = false,
  }) {
    return InviteFriendsLoaded(
      contacts: contacts ?? this.contacts,
      query: query ?? this.query,
      invitingContactId: clearInvitingContactId
          ? null
          : (invitingContactId ?? this.invitingContactId),
    );
  }

  @override
  List<Object?> get props => [contacts, query, invitingContactId];
}

class InviteFriendsCubit extends Cubit<InviteFriendsState> {
  InviteFriendsCubit({
    required String referralCode,
    required PermissionService permissionService,
    required ContactsService contactsService,
    required UrlLauncherService urlLauncherService,
  }) : _referralCode = referralCode,
       _permissionService = permissionService,
       _contactsService = contactsService,
       _urlLauncherService = urlLauncherService,
       super(const InviteFriendsLoading());

  final String _referralCode;
  final PermissionService _permissionService;
  final ContactsService _contactsService;
  final UrlLauncherService _urlLauncherService;
  List<InviteContact> _all = const [];

  Future<void> initialize() async {
    emit(const InviteFriendsLoading());

    final AppPermissionStatus current = await _permissionService.status(
      AppPermission.contacts,
    );
    final AppPermissionStatus resolved = current == AppPermissionStatus.granted
        ? current
        : await _permissionService.request(AppPermission.contacts);

    if (resolved != AppPermissionStatus.granted) {
      emit(
        InviteFriendsPermissionDenied(
          permanentlyDenied: resolved == AppPermissionStatus.permanentlyDenied,
        ),
      );
      return;
    }

    await _loadContacts();
  }

  void setQuery(String query) {
    final InviteFriendsState current = state;
    if (current is! InviteFriendsLoaded) return;
    final String q = query.trim();
    emit(current.copyWith(query: q, contacts: _filterContacts(q)));
  }

  Future<void> invite(InviteContact contact) async {
    final InviteFriendsState current = state;
    if (current is! InviteFriendsLoaded) return;
    if (current.invitingContactId != null) return;

    emit(current.copyWith(invitingContactId: contact.id));
    try {
      final String message = _inviteMessage();

      final String waPhoneDigits = _whatsAppPhoneDigits(contact.phone);
      final Uri waUri = Uri.parse(
        'whatsapp://send?phone=$waPhoneDigits&text=${Uri.encodeComponent(message)}',
      );

      final bool waLaunched = await _urlLauncherService.launch(
        waUri.toString(),
      );

      if (waLaunched) return;

      final Uri smsUri = Uri(
        scheme: 'sms',
        path: contact.phone,
        queryParameters: <String, String>{'body': message},
      );
      await _urlLauncherService.launch(smsUri.toString());
    } catch (_) {
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: contact.phone,
        queryParameters: <String, String>{'body': _inviteMessage()},
      );
      await _urlLauncherService.launch(smsUri.toString());
    } finally {
      final InviteFriendsState updated = state;
      if (updated is InviteFriendsLoaded) {
        emit(updated.copyWith(clearInvitingContactId: true));
      }
    }
  }

  Future<void> _loadContacts() async {
    try {
      final List<AppContact> contacts = await _contactsService.getContacts(
        withProperties: true,
      );

      final List<InviteContact> mapped =
          contacts
              .where((c) => c.phones.isNotEmpty)
              .map((c) {
                final String name = c.displayName.trim();
                final String phone = c.phones.first.number.trim();
                return InviteContact(
                  id: c.id,
                  name: name.isEmpty ? phone : name,
                  phone: phone,
                );
              })
              .toList(growable: false)
            ..sort(
              (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
            );

      _all = mapped;
      emit(InviteFriendsLoaded(contacts: mapped, query: ''));
    } catch (e) {
      emit(InviteFriendsFailure('Failed to load contacts. ${e.toString()}'));
    }
  }

  List<InviteContact> _filterContacts(String query) {
    if (query.isEmpty) return _all;
    final String q = query.toLowerCase();
    final String qDigits = _onlyDigits(query);
    return _all
        .where((c) {
          final bool nameMatch = c.name.toLowerCase().contains(q);
          if (nameMatch) return true;
          if (qDigits.isEmpty) return false;
          return _onlyDigits(c.phone).contains(qDigits);
        })
        .toList(growable: false);
  }

  String _inviteMessage() {
    return 'Join GoApp using my referral code: $_referralCode';
  }

  String _onlyDigits(String input) => input.replaceAll(RegExp(r'[^0-9]'), '');

  String _whatsAppPhoneDigits(String phoneRaw) {
    String digits = _onlyDigits(phoneRaw);
    if (digits.startsWith('00')) digits = digits.substring(2);
    if (digits.length == 10) {
      // Default to India if a 10-digit local mobile number is detected.
      digits = '91$digits';
    }
    return digits;
  }
}
