import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'document_model.dart';

class DocumentProgressStore {
  DocumentProgressStore._();

  static const String _prefsKey = 'document_progress_store_v1';
  static SharedPreferences? _prefs;
  static bool _loaded = false;

  static final Map<DocumentType, bool> _completed = {
    DocumentType.drivingLicense: false,
    DocumentType.vehicleRC: false,
    DocumentType.aadhaarCard: false,
    DocumentType.panCard: false,
    DocumentType.bankDetails: false,
  };

  static final Map<DocumentType, String?> _frontImagePath = {
    DocumentType.drivingLicense: null,
    DocumentType.vehicleRC: null,
    DocumentType.aadhaarCard: null,
    DocumentType.panCard: null,
    DocumentType.bankDetails: null,
  };

  static final Map<DocumentType, String?> _backImagePath = {
    DocumentType.drivingLicense: null,
    DocumentType.vehicleRC: null,
    DocumentType.aadhaarCard: null,
    DocumentType.panCard: null,
    DocumentType.bankDetails: null,
  };

  static final Map<DocumentType, String?> _documentNumber = {
    DocumentType.drivingLicense: null,
    DocumentType.vehicleRC: null,
    DocumentType.aadhaarCard: null,
    DocumentType.panCard: null,
    DocumentType.bankDetails: null,
  };

  static final Map<String, String> _bankDraft = <String, String>{
    'accountHolderName': '',
    'bankName': '',
    'accountNumber': '',
    'confirmAccountNumber': '',
    'ifscCode': '',
  };

  static String? _profileImagePath;

  static Future<void> init() async {
    if (_loaded) return;
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs!.getString(_prefsKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          _readBoolMap(decoded['completed'], _completed);
          _readStringMap(decoded['frontImagePath'], _frontImagePath);
          _readStringMap(decoded['backImagePath'], _backImagePath);
          _readStringMap(decoded['documentNumber'], _documentNumber);
          _readBankDraft(decoded['bankDraft']);
          final profile = decoded['profileImagePath'];
          _profileImagePath = profile is String && profile.trim().isNotEmpty
              ? profile
              : null;
        }
      } catch (_) {}
    }
    _loaded = true;
  }

  static bool isCompleted(DocumentType type) {
    return _completed[type] ?? false;
  }

  static void setCompleted(DocumentType type, bool completed) {
    _completed[type] = completed;
    unawaited(_persist());
  }

  static String? frontImagePath(DocumentType type) {
    return _frontImagePath[type];
  }

  static String? backImagePath(DocumentType type) {
    return _backImagePath[type];
  }

  static void setFrontImagePath(DocumentType type, String? path) {
    _frontImagePath[type] = path;
    unawaited(_persist());
  }

  static void setBackImagePath(DocumentType type, String? path) {
    _backImagePath[type] = path;
    unawaited(_persist());
  }

  static String? documentNumber(DocumentType type) {
    return _documentNumber[type];
  }

  static void setDocumentNumber(DocumentType type, String? number) {
    _documentNumber[type] = number;
    unawaited(_persist());
  }

  static String bankDraftValue(String field) {
    return _bankDraft[field] ?? '';
  }

  static void setBankDraftValue(String field, String value) {
    _bankDraft[field] = value;
    unawaited(_persist());
  }

  static void clearBankDraft() {
    _bankDraft.updateAll((_, _) => '');
    unawaited(_persist());
  }

  static String? profileImagePath() {
    return _profileImagePath;
  }

  static bool isProfileImageUploaded() {
    return _profileImagePath != null && _profileImagePath!.trim().isNotEmpty;
  }

  static void setProfileImagePath(String? path) {
    _profileImagePath = path;
    unawaited(_persist());
  }

  static void reset() {
    _completed.updateAll((_, _) => false);
    _frontImagePath.updateAll((_, _) => null);
    _backImagePath.updateAll((_, _) => null);
    _documentNumber.updateAll((_, _) => null);
    clearBankDraft();
    _profileImagePath = null;
    unawaited(_persist());
  }

  static Future<void> _persist() async {
    if (!_loaded) return;
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setString(_prefsKey, jsonEncode(_toJson()));
  }

  static Map<String, dynamic> _toJson() {
    return <String, dynamic>{
      'completed': _completed.map((k, v) => MapEntry(_docTypeKey(k), v)),
      'frontImagePath': _frontImagePath.map(
        (k, v) => MapEntry(_docTypeKey(k), v),
      ),
      'backImagePath': _backImagePath.map(
        (k, v) => MapEntry(_docTypeKey(k), v),
      ),
      'documentNumber': _documentNumber.map(
        (k, v) => MapEntry(_docTypeKey(k), v),
      ),
      'bankDraft': Map<String, String>.from(_bankDraft),
      'profileImagePath': _profileImagePath,
    };
  }

  static void _readBoolMap(dynamic raw, Map<DocumentType, bool> target) {
    if (raw is! Map) return;
    for (final entry in raw.entries) {
      final type = _docTypeFromKey(entry.key?.toString());
      if (type == null) continue;
      final value = entry.value;
      target[type] = value is bool ? value : value?.toString() == 'true';
    }
  }

  static void _readStringMap(dynamic raw, Map<DocumentType, String?> target) {
    if (raw is! Map) return;
    for (final entry in raw.entries) {
      final type = _docTypeFromKey(entry.key?.toString());
      if (type == null) continue;
      final value = entry.value?.toString();
      target[type] = value == null || value.trim().isEmpty ? null : value;
    }
  }

  static void _readBankDraft(dynamic raw) {
    if (raw is! Map) return;
    for (final field in _bankDraft.keys) {
      _bankDraft[field] = raw[field]?.toString() ?? '';
    }
  }

  static String _docTypeKey(DocumentType type) {
    return type.name;
  }

  static DocumentType? _docTypeFromKey(String? key) {
    if (key == null || key.isEmpty) return null;
    for (final type in DocumentType.values) {
      if (type.name == key) return type;
    }
    return null;
  }
}
