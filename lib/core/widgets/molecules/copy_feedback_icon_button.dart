import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../utils/clipboard_feedback.dart';

/// Kopyala ikonu — tıklanınca panoya yazar, snackbar gösterir, check ikonuna döner.
class CopyFeedbackIconButton extends StatefulWidget {
  const CopyFeedbackIconButton({
    super.key,
    required this.value,
    this.tooltip,
    this.iconSize = 20,
    this.iconColor,
    this.copyIcon = Icons.copy_all_rounded,
    this.checkIcon = Icons.check_rounded,
    this.visualDensity = VisualDensity.compact,
  });

  final String value;
  final String? tooltip;
  final double iconSize;
  final Color? iconColor;
  final IconData copyIcon;
  final IconData checkIcon;
  final VisualDensity visualDensity;

  @override
  State<CopyFeedbackIconButton> createState() => _CopyFeedbackIconButtonState();
}

class _CopyFeedbackIconButtonState extends State<CopyFeedbackIconButton> {
  bool _copied = false;
  Timer? _resetTimer;

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  Future<void> _copy() async {
    await copyTextWithClipboardFeedback(context, value: widget.value);
    if (!mounted) return;
    _resetTimer?.cancel();
    setState(() => _copied = true);
    _resetTimer = Timer(kClipboardCopyIconDuration, () {
      if (!mounted) return;
      setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.iconColor ?? AppColors.textSecondary;

    return IconButton(
      tooltip: widget.tooltip,
      visualDensity: widget.visualDensity,
      onPressed: _copy,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: Icon(
          _copied ? widget.checkIcon : widget.copyIcon,
          key: ValueKey(_copied),
          size: widget.iconSize,
          color: color,
        ),
      ),
    );
  }
}
