import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:goapp/core/storage/text_field_store.dart';

class PersistentTextController extends TextEditingController {
  PersistentTextController({required this.storageKey, String? initialText})
    : super(text: initialText ?? TextFieldStore.read(storageKey) ?? '');

  final String storageKey;
  bool _attached = false;

  void attach() {
    if (_attached) return;
    _attached = true;
    addListener(_persist);
  }

  void _persist() {
    unawaited(TextFieldStore.write(storageKey, text));
  }

  @override
  void dispose() {
    removeListener(_persist);
    super.dispose();
  }
}
