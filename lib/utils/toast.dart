import 'package:flutter/material.dart';

import '../theme.dart';

/// Bottom-right toast, auto-dismisses.
class Toast {
  Toast._();

  static OverlayEntry? _currentEntry;
  static DateTime? _showTime;

  /// Shows a toast message at the bottom-right of the screen.
  ///
  /// [message] - The text to display
  /// [duration] - How long to show the toast (default: 3 seconds)
  /// [backgroundColor] - Background color of the toast
  /// [textColor] - Text color of the toast
  static void show(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    Color backgroundColor = const Color(0xFF1E1E1E),
    Color textColor = Colors.white,
  }) {
    // Remove any existing toast
    _hide();

    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        backgroundColor: backgroundColor,
        textColor: textColor,
        onDismiss: () => _hide(),
      ),
    );

    _currentEntry = entry;
    _showTime = DateTime.now();
    overlay.insert(entry);

    // Auto-dismiss after duration
    Future.delayed(duration, () {
      if (_currentEntry == entry && _showTime != null) {
        // Only dismiss if it's still the same toast and enough time has passed
        final elapsed = DateTime.now().difference(_showTime!);
        if (elapsed >= duration) {
          _hide();
        }
      }
    });
  }

  static void _hide() {
    _currentEntry?.remove();
    _currentEntry = null;
    _showTime = null;
  }
}

class _ToastWidget extends StatefulWidget {
  const _ToastWidget({
    required this.message,
    required this.backgroundColor,
    required this.textColor,
    required this.onDismiss,
  });

  final String message;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onDismiss;

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      right: 24,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              constraints: const BoxConstraints(maxWidth: 320),
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      widget.message,
                      style: TextStyle(
                        color: widget.textColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _dismiss,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension ToastContext on BuildContext {
  void showToast(
    String message, {
    Duration duration = const Duration(seconds: 3),
    Color backgroundColor = const Color(0xFF1E1E1E),
    Color textColor = Colors.white,
  }) {
    Toast.show(
      this,
      message: message,
      duration: duration,
      backgroundColor: backgroundColor,
      textColor: textColor,
    );
  }
}
