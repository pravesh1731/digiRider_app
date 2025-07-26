import 'package:flutter/material.dart';
import '../global/Common.dart'; // adjust path if needed

Future<bool> showExitConfirmationDialogWhite(BuildContext context) async {
  final screenWidth = MediaQuery.of(context).size.width;

  final shouldExit = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: Common.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      titlePadding: const EdgeInsets.only(top: 20, left: 24, right: 24, bottom: 15),
      contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 15),
      actionsPadding: const EdgeInsets.only(right: 16, bottom: 16),
      title: Text(
        "Exit App",
        style: TextStyle(
          fontWeight: Common.weight,
          color: Common.secondary,
          fontSize: Common.title,
        ),
      ),
      content: SizedBox(
        width: screenWidth * 0.9,
        child: Text(
          "Are you sure you want to exit?",
          style: TextStyle(
            color: Common.secondary,
            fontWeight: Common.weight,
            fontSize: Common.h2,
          ),
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Common.secondary.withOpacity(0.4)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: Text(
            "Cancel",
            style: TextStyle(
              color: Common.secondary,
              fontWeight: Common.weight,
              fontSize: Common.h2,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Common.secondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: Text(
            "Exit",
            style: TextStyle(
              color: Common.primary,
              fontWeight: Common.weight,
              fontSize: Common.h2,
            ),
          ),
        ),
      ],
    ),
  );

  return shouldExit ?? false;
}

Future<bool> showExitConfirmationDialog(BuildContext context) async {
  final screenWidth = MediaQuery.of(context).size.width;

  final shouldExit = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: Common.secondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      titlePadding: const EdgeInsets.only(top: 20, left: 24, right: 24, bottom: 15),
      contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 15),
      actionsPadding: const EdgeInsets.only(right: 16, bottom: 16),
      title: Text(
        "Exit App",
        style: TextStyle(
          fontWeight: Common.weight,
          color: Common.primary,
          fontSize: Common.title,
        ),
      ),
      content: SizedBox(
        width: screenWidth * 0.9,
        child: Text(
          "Are you sure you want to exit?",
          style: TextStyle(
            color: Common.primary,
            fontWeight: Common.weight,
            fontSize: Common.h2,
          ),
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Common.primary.withOpacity(0.4)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: Text(
            "Cancel",
            style: TextStyle(
              color: Common.primary,
              fontWeight: Common.weight,
              fontSize: Common.h2,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Common.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: Text(
            "Exit",
            style: TextStyle(
              color: Common.secondary,
              fontWeight: Common.weight,
              fontSize: Common.h2,
            ),
          ),
        ),
      ],
    ),
  );

  return shouldExit ?? false;
}
