import 'package:flutter/material.dart';

import '../../core/l10n/language.dart';
import '../../core/theme/tokens.dart';
import 'inputs.dart';
import 'pill_button.dart';

/// Bottom sheet that grows with the keyboard and scrolls when tall.
Future<T?> showAppSheet<T>(BuildContext context, {required WidgetBuilder builder}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(sheetContext).bottom),
      child: builder(sheetContext),
    ),
  );
}

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// Confirmation that names what will happen. Returns true when confirmed.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
}) async {
  final s = context.s;
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actionsPadding: const EdgeInsets.fromLTRB(AppSpace.lg, 0, AppSpace.lg, AppSpace.lg),
      actions: [
        PillButton(
          label: s.cancel,
          variant: PillVariant.ghost,
          onPressed: () => Navigator.of(dialogContext).pop(false),
        ),
        PillButton(
          label: confirmLabel,
          onPressed: () => Navigator.of(dialogContext).pop(true),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Asks for a short reason (required). Returns null when cancelled.
Future<String?> showReasonDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
}) {
  return showDialog<String>(
    context: context,
    builder: (dialogContext) => _ReasonDialog(title: title, message: message, confirmLabel: confirmLabel),
  );
}

class _ReasonDialog extends StatefulWidget {
  const _ReasonDialog({required this.title, required this.message, required this.confirmLabel});

  final String title;
  final String message;
  final String confirmLabel;

  @override
  State<_ReasonDialog> createState() => _ReasonDialogState();
}

class _ReasonDialogState extends State<_ReasonDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final canConfirm = _controller.text.trim().isNotEmpty;
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.message),
            const SizedBox(height: AppSpace.lg),
            AppTextField(
              label: s.reason,
              controller: _controller,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(AppSpace.lg, 0, AppSpace.lg, AppSpace.lg),
      actions: [
        PillButton(label: s.cancel, variant: PillVariant.ghost, onPressed: () => Navigator.of(context).pop()),
        PillButton(
          label: widget.confirmLabel,
          onPressed: canConfirm ? () => Navigator.of(context).pop(_controller.text.trim()) : null,
        ),
      ],
    );
  }
}
