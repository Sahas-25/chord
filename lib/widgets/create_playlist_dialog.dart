import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Shows a dialog and returns the playlist name (or null if cancelled).
Future<String?> showCreatePlaylistDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (_) => const _CreatePlaylistDialog(),
  );
}

class _CreatePlaylistDialog extends StatefulWidget {
  const _CreatePlaylistDialog();

  @override
  State<_CreatePlaylistDialog> createState() => _CreatePlaylistDialogState();
}

class _CreatePlaylistDialogState extends State<_CreatePlaylistDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, _controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.card,
      title: const Text('New playlist'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          maxLength: 30,
          decoration: AppTheme.inputDecoration(hint: 'Playlist name'),
          validator: (value) {
            final text = value?.trim() ?? '';
            if (text.isEmpty) return 'Please enter a name';
            if (text.length < 3) return 'Use at least 3 characters';
            return null;
          },
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Create')),
      ],
    );
  }
}
