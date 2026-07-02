import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../l10n/l10n_extensions.dart';
import '../atoms/custom_button.dart';
import '../organisms/flippable_person_card.dart';

typedef CardColorPickerPreviewBuilder = Widget Function(
  String? backgroundColor,
  String? accentColor,
);

/// Özel kart / metin rengi seçimi — bottom sheet içinde canlı kart önizlemesi.
class CardColorPickerSheet {
  CardColorPickerSheet._();

  static String colorToHex(Color c) {
    final r = (c.r * 255).round().clamp(0, 255);
    final g = (c.g * 255).round().clamp(0, 255);
    final b = (c.b * 255).round().clamp(0, 255);
    return '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}';
  }

  static Future<Color?> show(
    BuildContext context, {
    required String title,
    required Color initialColor,
    required bool editingBackground,
    String? previewBackgroundColor,
    String? previewAccentColor,
    CardColorPickerPreviewBuilder? previewBuilder,
  }) async {
    Color? result;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return _CardColorPickerSheetContent(
          title: title,
          initialColor: initialColor,
          editingBackground: editingBackground,
          previewBackgroundColor: previewBackgroundColor,
          previewAccentColor: previewAccentColor,
          previewBuilder: previewBuilder,
          onSaved: (color) => result = color,
        );
      },
    );

    return result;
  }
}

class _CardColorPickerSheetContent extends StatefulWidget {
  const _CardColorPickerSheetContent({
    required this.title,
    required this.initialColor,
    required this.editingBackground,
    required this.previewBackgroundColor,
    required this.previewAccentColor,
    required this.onSaved,
    this.previewBuilder,
  });

  final String title;
  final Color initialColor;
  final bool editingBackground;
  final String? previewBackgroundColor;
  final String? previewAccentColor;
  final CardColorPickerPreviewBuilder? previewBuilder;
  final ValueChanged<Color> onSaved;

  @override
  State<_CardColorPickerSheetContent> createState() =>
      _CardColorPickerSheetContentState();
}

class _CardColorPickerSheetContentState
    extends State<_CardColorPickerSheetContent> {
  static const _previewThrottle = Duration(milliseconds: 48);

  late Color _selectedColor;
  late final ValueNotifier<String?> _liveBackground;
  late final ValueNotifier<String?> _liveAccent;
  Timer? _previewTimer;
  String? _pendingPreviewHex;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
    _liveBackground = ValueNotifier(widget.previewBackgroundColor);
    _liveAccent = ValueNotifier(widget.previewAccentColor);
  }

  @override
  void dispose() {
    _previewTimer?.cancel();
    _liveBackground.dispose();
    _liveAccent.dispose();
    super.dispose();
  }

  void _handleColorChanged(Color color) {
    if (color.toARGB32() == _selectedColor.toARGB32()) return;
    _selectedColor = color;

    _pendingPreviewHex = CardColorPickerSheet.colorToHex(color);
    if (_previewTimer?.isActive ?? false) return;

    _flushPreview();
    _previewTimer = Timer(_previewThrottle, () {
      if (!mounted) return;
      if (_pendingPreviewHex != null) {
        _flushPreview();
      }
    });
  }

  void _flushPreview() {
    final hex = _pendingPreviewHex;
    if (hex == null) return;
    _pendingPreviewHex = null;

    if (widget.editingBackground) {
      if (_liveBackground.value == hex) return;
      _liveBackground.value = hex;
    } else {
      if (_liveAccent.value == hex) return;
      _liveAccent.value = hex;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final media = MediaQuery.of(context);
    final availableWidth = media.size.width - 40;
    const pickerAreaRatio = 1.0;
    const maxPickerSize = 260.0;
    final pickerSize = math.min(availableWidth, maxPickerSize);
    const sectionGap = 16.0;
    final hasPreview = widget.previewBuilder != null;
    final previewWidth = math.min(420.0, availableWidth);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: sectionGap),
              decoration: BoxDecoration(
                color: colorScheme.outline.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            widget.title,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (hasPreview) ...[
            const SizedBox(height: sectionGap),
            RepaintBoundary(
              child: ValueListenableBuilder<String?>(
                valueListenable: widget.editingBackground
                    ? _liveBackground
                    : _liveAccent,
                builder: (context, _, __) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: previewWidth),
                      child: AspectRatio(
                        aspectRatio: FlippablePersonCard.cardAspectRatio,
                        child: widget.previewBuilder!(
                          widget.editingBackground
                              ? _liveBackground.value
                              : widget.previewBackgroundColor,
                          widget.editingBackground
                              ? widget.previewAccentColor
                              : _liveAccent.value,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: sectionGap),
          ],
          Center(
            child: RepaintBoundary(
              child: _IsolatedColorPicker(
                initialColor: widget.initialColor,
                pickerWidth: pickerSize,
                pickerAreaHeightPercent: pickerAreaRatio,
                onColorChanged: _handleColorChanged,
              ),
            ),
          ),
          const SizedBox(height: sectionGap),
          CustomButton(
            label: context.l10n.kaydet,
            onPressed: () {
              _previewTimer?.cancel();
              widget.onSaved(_selectedColor);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

/// Renk seçimi sırasında yalnızca picker alt ağacını yeniden çizer.
class _IsolatedColorPicker extends StatefulWidget {
  const _IsolatedColorPicker({
    required this.initialColor,
    required this.pickerWidth,
    required this.pickerAreaHeightPercent,
    required this.onColorChanged,
  });

  final Color initialColor;
  final double pickerWidth;
  final double pickerAreaHeightPercent;
  final ValueChanged<Color> onColorChanged;

  @override
  State<_IsolatedColorPicker> createState() => _IsolatedColorPickerState();
}

class _IsolatedColorPickerState extends State<_IsolatedColorPicker> {
  late Color _pickerColor;

  @override
  void initState() {
    super.initState();
    _pickerColor = widget.initialColor;
  }

  void _onColorChanged(Color color) {
    if (color.toARGB32() == _pickerColor.toARGB32()) return;
    _pickerColor = color;
    widget.onColorChanged(color);
  }

  @override
  Widget build(BuildContext context) {
    return ColorPicker(
      pickerColor: _pickerColor,
      onColorChanged: _onColorChanged,
      enableAlpha: false,
      hexInputBar: true,
      labelTypes: const [],
      displayThumbColor: false,
      portraitOnly: true,
      colorPickerWidth: widget.pickerWidth,
      pickerAreaHeightPercent: widget.pickerAreaHeightPercent,
      pickerAreaBorderRadius: const BorderRadius.all(Radius.circular(12)),
    );
  }
}
