import 'package:flutter/material.dart';
import '../ui/widgets.dart';

/// Shows [message] as the website's glass toast. [status]: 0 = success, 1 = error, anything else = info.
/// The callers' raw colours (green/orange/red) only tint the text for errors.
void getSnackBar(BuildContext context, String message, Color color, int status) {
  final p = context.cap;
  final isError = status == 1 || color == Colors.red || color == Colors.redAccent;
  showCapToast(context, message, color: isError ? p.rd : null, duration: const Duration(milliseconds: 2400));
}
