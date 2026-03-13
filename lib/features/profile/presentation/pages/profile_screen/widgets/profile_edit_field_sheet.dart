import 'package:flutter/material.dart';
import 'package:goapp/core/storage/text_field_store.dart';
import 'package:goapp/core/widgets/shadow_button.dart';

class ProfileEditFieldSheet extends StatefulWidget {
  const ProfileEditFieldSheet({
    super.key,
    required this.title,
    required this.icon,
    required this.initialValue,
    required this.storageKey,
    required this.keyboardType,
    required this.onSave,
  });

  final String title;
  final IconData icon;
  final String initialValue;
  final String storageKey;
  final TextInputType keyboardType;
  final Future<void> Function(String) onSave;

  @override
  State<ProfileEditFieldSheet> createState() => _ProfileEditFieldSheetState();
}

class _ProfileEditFieldSheetState extends State<ProfileEditFieldSheet> {
  late TextEditingController _ctrl;
  VoidCallback? _persistListener;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final stored = TextFieldStore.read(widget.storageKey) ?? '';
    _ctrl = TextEditingController(
      text: stored.isNotEmpty ? stored : widget.initialValue,
    );
    _persistListener = () {
      TextFieldStore.write(widget.storageKey, _ctrl.text);
    };
    _ctrl.addListener(_persistListener!);
  }

  @override
  void dispose() {
    if (_persistListener != null) {
      _ctrl.removeListener(_persistListener!);
    }
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_ctrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    await widget.onSave(_ctrl.text);
    if (mounted) {
      setState(() => _saving = false);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      padding: EdgeInsets.fromLTRB(20, 14, 20, bottom + 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Container(
              width: 38,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFDDDDDD),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _ctrl,
            keyboardType: widget.keyboardType,
            autofocus: true,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF1A1A1A),
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Icon(
                widget.icon,
                color: const Color(0xFF888888),
                size: 20,
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 48),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(999),
                borderSide: const BorderSide(
                  color: Color(0xFFE5E7EB),
                  width: 1.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(999),
                borderSide: const BorderSide(
                  color: Color(0xFF00A86B),
                  width: 1.6,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _saving ? null : () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Cancel'),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFF2F0ED),
                    foregroundColor: const Color(0xFF656565),
                    side: BorderSide(
                      color: Colors.black.withValues(alpha: 0.06),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ShadowButton(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save_outlined, size: 16),
                  label: Text(_saving ? 'Saving...' : 'Save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A86B),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
