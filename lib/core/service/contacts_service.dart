import 'package:flutter/services.dart';

class AppContactPhone {
  const AppContactPhone({required this.number});

  final String number;
}

class AppContact {
  const AppContact({
    required this.id,
    required this.displayName,
    required this.phones,
  });

  final String id;
  final String displayName;
  final List<AppContactPhone> phones;
}

class ContactsService {
  const ContactsService();

  static const MethodChannel _channel = MethodChannel('app/contacts_service');

  Future<List<AppContact>> getContacts({bool withProperties = true}) async {
    final List<Object?>? raw = await _channel.invokeMethod<List<Object?>>(
      'getContacts',
      <String, Object>{'withProperties': withProperties},
    );
    if (raw == null) return const <AppContact>[];

    return raw
        .whereType<Map>()
        .map((m) => _mapContact(m))
        .whereType<AppContact>()
        .toList(growable: false);
  }

  AppContact? _mapContact(Map raw) {
    final String? id = raw['id'] as String?;
    final String? displayName = raw['displayName'] as String?;
    final List<Object?>? phonesRaw = raw['phones'] as List<Object?>?;
    if (id == null || displayName == null) return null;
    final phones = (phonesRaw ?? const <Object?>[])
        .whereType<Map>()
        .map((p) => (p['number'] as String?)?.trim())
        .whereType<String>()
        .where((n) => n.isNotEmpty)
        .map((n) => AppContactPhone(number: n))
        .toList(growable: false);
    return AppContact(id: id, displayName: displayName, phones: phones);
  }
}
