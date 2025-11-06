import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../channel/params.dart';
import '../style/sf_symbol.dart';
import '../utils/version_detector.dart';
import '../utils/theme_helper.dart';

/// A Cupertino-native segmented control.
///
/// Embeds a native UISegmentedControl/NSSegmentedControl for pixel-perfect
/// fidelity on iOS and macOS.
class CNSegmentedControl extends StatefulWidget {
  /// Creates a Cupertino-native segmented control.
  const CNSegmentedControl({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onValueChanged,
    this.enabled = true,
    this.color,
    this.height = 32.0,
    this.shrinkWrap = false,
    this.sfSymbols,
    this.iconSize,
    this.iconColor,
    this.iconPaletteColors,
    this.iconGradientEnabled,
    this.iconRenderingMode,
  });

  /// Segment labels to display, in order.
  final List<String> labels;

  /// The index of the selected segment.
  final int selectedIndex;

  /// Called when the user selects a segment.
  final ValueChanged<int> onValueChanged;

  /// Whether the control is interactive.
  final bool enabled;

  /// Accent/tint color used for the control.
  final Color? color;

  /// Control height.
  final double height;

  /// If true, sizes the control to its intrinsic width.
  final bool shrinkWrap;

  /// Optional SF Symbols for segments; complements [labels].
  final List<CNSymbol>? sfSymbols;

  /// Overrides the symbol size (for all segments).
  final double? iconSize;

  /// Global icon color override.
  final Color? iconColor;

  /// Global icon palette colors override.
  final List<Color>? iconPaletteColors;

  /// Enables gradient rendering where supported.
  final bool? iconGradientEnabled;

  /// Global icon rendering mode.
  final CNSymbolRenderingMode? iconRenderingMode;

  @override
  State<CNSegmentedControl> createState() => _CNSegmentedControlState();
}

class _CNSegmentedControlState extends State<CNSegmentedControl> {
  MethodChannel? _channel;

  int? _lastSelected;
  bool? _lastEnabled;
  bool? _lastIsDark;
  int? _lastTint;
  double? _intrinsicWidth;

  bool get _isDark => ThemeHelper.isDark(context);

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CNSegmentedControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPropsToNativeIfNeeded();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncBrightnessIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    // Check if we should use native platform view
    final isIOSOrMacOS = defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
    final shouldUseNative = isIOSOrMacOS && PlatformVersion.shouldUseNativeGlass;

    // Fallback to Flutter widgets for non-iOS/macOS or iOS/macOS < 26
    if (!shouldUseNative) {
      // For both non-iOS/macOS and iOS/macOS < 26, use CupertinoSegmentedControl
      return SizedBox(
        height: widget.height,
        child: CupertinoSegmentedControl<int>(
          children: {
            for (var i = 0; i < widget.labels.length; i++)
              i: Text(widget.labels[i]),
          },
          groupValue: widget.selectedIndex,
          onValueChanged: widget.enabled
              ? (i) => widget.onValueChanged(i)
              : (_) {},
        ),
      );
    }

    const viewType = 'CupertinoNativeSegmentedControl';
    final creationParams = <String, dynamic>{
      'labels': widget.labels,
      'selectedIndex': widget.selectedIndex,
      'enabled': widget.enabled,
      'isDark': _isDark,
      'style': encodeStyle(context, tint: widget.color)
        ..addAll({
          if (widget.iconSize != null) 'iconSize': widget.iconSize,
          if (widget.iconColor != null)
            'iconColor': resolveColorToArgb(widget.iconColor, context),
          if (widget.iconPaletteColors != null)
            'iconPaletteColors': widget.iconPaletteColors!
                .map((c) => resolveColorToArgb(c, context))
                .toList(),
          if (widget.iconGradientEnabled != null)
            'iconGradientEnabled': widget.iconGradientEnabled,
          if (widget.iconRenderingMode != null)
            'iconRenderingMode': widget.iconRenderingMode!.name,
        }),
      if (widget.sfSymbols != null)
        'sfSymbols': widget.sfSymbols!.map((e) => e.name).toList(),
      if (widget.sfSymbols != null)
        'sfSymbolSizes': widget.sfSymbols!.map((e) => e.size).toList(),
      if (widget.sfSymbols != null)
        'sfSymbolColors': widget.sfSymbols!
            .map((e) => resolveColorToArgb(e.color, context))
            .toList(),
      if (widget.sfSymbols != null)
        'sfSymbolPaletteColors': widget.sfSymbols!
            .map(
              (e) => (e.paletteColors ?? [])
                  .map((c) => resolveColorToArgb(c, context))
                  .toList(),
            )
            .toList(),
      if (widget.sfSymbols != null)
        'sfSymbolRenderingModes': widget.sfSymbols!
            .map((e) => e.mode?.name)
            .toList(),
      if (widget.sfSymbols != null)
        'sfSymbolGradientEnabled': widget.sfSymbols!
            .map((e) => e.gradient)
            .toList(),
    };

    Widget platformView;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      platformView = UiKitView(
        viewType: viewType,
        creationParamsCodec: const StandardMessageCodec(),
        creationParams: creationParams,
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    } else {
      platformView = AppKitView(
        viewType: viewType,
        creationParamsCodec: const StandardMessageCodec(),
        creationParams: creationParams,
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    }

    if (widget.shrinkWrap) {
      final width = _intrinsicWidth;
      return Center(
        child: ClipRect(
          child: SizedBox(
            height: widget.height,
            width: width, // if null, stretches initially until measured
            child: platformView,
          ),
        ),
      );
    }

    return ClipRect(
      child: SizedBox(height: widget.height, child: platformView),
    );
  }

  void _onPlatformViewCreated(int id) {
    final channel = MethodChannel('CupertinoNativeSegmentedControl_$id');
    _channel = channel;
    channel.setMethodCallHandler(_onMethodCall);
    _cacheCurrentProps();
    _syncBrightnessIfNeeded();
    _requestIntrinsicSize();
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    if (call.method == 'valueChanged') {
      final args = call.arguments as Map?;
      final idx = (args?['index'] as num?)?.toInt();
      if (idx != null) {
        widget.onValueChanged(idx);
        _lastSelected = idx;
      }
    }
    return null;
  }

  void _cacheCurrentProps() {
    _lastSelected = widget.selectedIndex;
    _lastEnabled = widget.enabled;
    _lastIsDark = _isDark;
    _lastTint = resolveColorToArgb(widget.color, context);
  }

  Future<void> _syncPropsToNativeIfNeeded() async {
    final channel = _channel;
    if (channel == null) return;

    final tint = resolveColorToArgb(widget.color, context);

    if (_lastEnabled != widget.enabled) {
      await channel.invokeMethod('setEnabled', {'enabled': widget.enabled});
      _lastEnabled = widget.enabled;
    }
    if (_lastSelected != widget.selectedIndex) {
      await channel.invokeMethod('setSelectedIndex', {
        'index': widget.selectedIndex,
      });
      _lastSelected = widget.selectedIndex;
    }
    if (_lastTint != tint && tint != null) {
      await channel.invokeMethod('setStyle', {'tint': tint});
      _lastTint = tint;
    }
  }

  Future<void> _requestIntrinsicSize() async {
    final channel = _channel;
    if (channel == null) return;
    try {
      final size = await channel.invokeMethod<Map>('getIntrinsicSize');
      final w = (size?['width'] as num?)?.toDouble();
      if (w != null && mounted) {
        setState(() => _intrinsicWidth = w);
      }
    } catch (_) {}
  }

  Future<void> _syncBrightnessIfNeeded() async {
    final channel = _channel;
    if (channel == null) return;
    final isDark = _isDark;
    final tint = resolveColorToArgb(widget.color, context);
    if (_lastIsDark != isDark) {
      await channel.invokeMethod('setBrightness', {'isDark': isDark});
      _lastIsDark = isDark;
    }
    if (_lastTint != tint && tint != null) {
      await channel.invokeMethod('setStyle', {'tint': tint});
      _lastTint = tint;
    }
  }
}
