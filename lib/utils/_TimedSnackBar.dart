import 'package:flutter/material.dart';

import '../ui/widgets.dart';

/// Shows [message] as the website's glass toast for [duration]. [place] is kept for older callers.
void showTimedSnackBar(BuildContext context, String message, Duration duration, String place) {
  showCapToast(context, message, duration: duration);
}
