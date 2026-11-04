import 'package:flutter/material.dart';
import '../global/l10n.dart';
import '../ui/widgets.dart';

/// Asks before leaving the app on back press.
Future<bool> showExitConfirmationDialogWhite(BuildContext context) => showExitConfirmationDialog(context);

Future<bool> showExitConfirmationDialog(BuildContext context) {
  return showConfirmDialog(
    context,
    title: context.l10n.exitApp,
    message: context.l10n.exitPrompt,
    confirmLabel: context.l10n.exit,
    cancelLabel: context.l10n.cancel,
  );
}
