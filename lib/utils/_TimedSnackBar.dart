import 'package:digirider/global/Common.dart';
import 'package:flutter/material.dart';

void showTimedSnackBar(BuildContext context, String message, Duration duration, String place) {
  final overlay = Overlay.of(context);

  late OverlayEntry overlayEntry; // Declare it late

  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: place=='top'? 50 : 100,
      left: 12,
      right: 12,
      child: _TimedSnackBar(
        message: message,
        duration: duration,
        onComplete: () => overlayEntry.remove(), // Now it's defined
      ),
    ),
  );

  overlay.insert(overlayEntry);
}

class _TimedSnackBar extends StatefulWidget {
  final String message;
  final Duration duration;
  final VoidCallback onComplete;

  const _TimedSnackBar({
    required this.message,
    required this.duration,
    required this.onComplete,
  });

  @override
  State<_TimedSnackBar> createState() => _TimedSnackBarState();
}

class _TimedSnackBarState extends State<_TimedSnackBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..forward().whenComplete(widget.onComplete);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Common.secondary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.message,
                    style: TextStyle(color: Common.primary, fontFamily: 'bold', fontSize: Common.h2, fontWeight: Common.weight),
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  ),
                ),
                SizedBox(width: 10,),
                GestureDetector(
                  onTap: () {
                    _controller.stop();
                    widget.onComplete();
                  },
                  child: Icon(Icons.close, size: 22, color: Common.primary),
                ),
              ],
            ),
            SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => LinearProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  backgroundColor: Colors.white.withOpacity(0.2),
                  value: _controller.value,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
